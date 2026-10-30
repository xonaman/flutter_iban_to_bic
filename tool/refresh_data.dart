// Refreshes `data/bank_codes/<cc>.jsonl` (the reviewed source) and the
// generated `assets/bank_codes/<cc>.json` (the runtime asset) from each
// country's authoritative source. Run manually or via the `refresh-data`
// GitHub Action. See `tool/bank_codes.dart` for both formats.
//
// Adding a new country:
//   1. Register it under `adapters` below.
//   2. Implement a function `Future<Map<String, BankEntry>> fetchXX()` that
//      returns `{ bankCode: BankEntry(bic, bankName, bankShortName, ...) }`.
//      Fetch from the central bank / competent authority — no scraping of
//      third-party aggregators.
//   3. Record where the data came from with `recordSource(...)` so the
//      provenance in `assets/bank_codes/meta.json` stays current.
//   4. Run the refresh for it, which creates `data/bank_codes/<cc>.jsonl`
//      and `assets/bank_codes/<cc>.json`, and add the asset to
//      `pubspec.yaml`'s flutter.assets list.
//   5. Register the country and its bank-code range (the IBAN character
//      offsets) in `_buildDefaultCountries` in `lib/src/iban_to_bic.dart`.
//
// To fix an entry by hand, edit `data/bank_codes/<cc>.jsonl` and run
// `dart run tool/build_assets.dart` to regenerate the asset (it also
// updates the asset's hash in `meta.json`).
//
// Run with:
//   dart run tool/refresh_data.dart           # refresh everything
//   dart run tool/refresh_data.dart DE NL     # refresh only these countries
//
// Options:
//   --summary-json=<path>      write a per-country status summary as JSON
//   --summary-markdown=<path>  write the same summary as a Markdown table

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'bank_codes.dart';
import 'dataset_meta.dart';

export 'bank_codes.dart' show BankEntry;
export 'dataset_meta.dart';

typedef CountryAdapter = Future<Map<String, BankEntry>> Function();

/// Thrown by an adapter when a refresh can't proceed for a benign,
/// configuration-level reason (e.g. an upstream URL that needs to be
/// rotated by a maintainer). Treated as "skipped" rather than "failed"
/// so the scheduled workflow stays green between rotations.
class AdapterSkipped implements Exception {
  AdapterSkipped(this.reason);
  final String reason;
  @override
  String toString() => reason;
}

/// Sources recorded by adapters during this run, keyed by country code.
final Map<String, DatasetSource> _sources = <String, DatasetSource>{};

/// Called by an adapter once it knows which upstream file it is reading.
void recordSource(String countryCode, DatasetSource source) {
  _sources[countryCode] = source;
}

/// Registry of per-country adapters. `null` means there is no adapter and
/// the refresh script leaves the existing data untouched.
///
/// ES, FR and LT have no scriptable authoritative source, so their datasets
/// are unmaintained:
///   - ES: the Banco de España entity register (app.bde.es/rbe_spa) lists
///     the 4-digit entity codes but no BICs.
///   - FR: the ACPR register REGAFI (regafi.fr, OpenDataSoft API) has the
///     5-digit CIB codes but no BICs. The Banque de France FIB file has
///     both but is only available to paying subscribers.
///   - LT: every page on lb.lt sits behind a Cloudflare bot challenge, so
///     the Bank of Lithuania's code list can't be downloaded from CI.
final Map<String, CountryAdapter?> adapters = <String, CountryAdapter?>{
  'AT': fetchAt,
  'BE': fetchBe,
  'DE': fetchDe,
  'ES': null,
  'FR': null,
  'LT': null,
  'LU': fetchLu,
  'NL': fetchNl,
};

Future<void> main(List<String> args) async {
  String? summaryJsonPath;
  String? summaryMarkdownPath;
  final List<String> countries = <String>[];
  for (final String arg in args) {
    if (arg.startsWith('--summary-json=')) {
      summaryJsonPath = arg.substring('--summary-json='.length);
    } else if (arg.startsWith('--summary-markdown=')) {
      summaryMarkdownPath = arg.substring('--summary-markdown='.length);
    } else if (arg.startsWith('--')) {
      stderr.writeln('Unknown option: $arg');
      exit(64);
    } else {
      countries.add(arg.toUpperCase());
    }
  }

  final RefreshSummary summary = await refreshCountries(
    countries.isEmpty ? adapters.keys : countries,
    adapters,
    write: (String cc, Map<String, BankEntry> entries) {
      checkPlausibleSize(
        entries.length,
        File(sourcePath(cc)).existsSync() ? readSource(cc).length : 0,
      );
      writeCountry(cc, entries);
      print(
        '[$cc] wrote ${sourcePath(cc)} and ${assetPath(cc)} '
        '(${entries.length} entries)',
      );
      writeMeta(cc, File(assetPath(cc)).readAsStringSync(), _sources[cc]);
    },
  );

  if (summaryJsonPath != null) {
    File(summaryJsonPath).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(summary.toJson())}\n',
    );
  }
  if (summaryMarkdownPath != null) {
    File(summaryMarkdownPath).writeAsStringSync(summary.toMarkdown());
  }

  print('---');
  print(
    'refreshed: ${summary.count(RefreshStatus.refreshed)}  '
    'skipped: ${summary.count(RefreshStatus.skipped)}  '
    'failed: ${summary.count(RefreshStatus.failed)}  '
    'no adapter: ${summary.count(RefreshStatus.notImplemented)}',
  );
  if (summary.count(RefreshStatus.failed) > 0) exit(1);
}

/// Outcome of refreshing a single country.
enum RefreshStatus {
  /// The adapter ran and the dataset was written.
  refreshed,

  /// The adapter threw [AdapterSkipped].
  skipped,

  /// The adapter threw anything else.
  failed,

  /// No adapter is registered for the country; its data is left untouched.
  notImplemented,
}

class CountryResult {
  CountryResult(this.country, this.status, {this.entries, this.reason});

  final String country;
  final RefreshStatus status;

  /// Number of entries written, for [RefreshStatus.refreshed].
  final int? entries;

  /// Why the country wasn't refreshed, for every other status.
  final String? reason;

  Map<String, Object?> toJson() => <String, Object?>{
    'country': country,
    'status': status.name,
    if (entries != null) 'entries': entries,
    if (reason != null) 'reason': reason,
  };
}

/// Machine-readable result of a refresh run, consumed by the
/// `refresh-data` workflow to open or close its tracking issue.
class RefreshSummary {
  RefreshSummary(this.results);

  final List<CountryResult> results;

  int count(RefreshStatus status) =>
      results.where((CountryResult r) => r.status == status).length;

  /// Whether an implemented adapter skipped or failed. Countries without an
  /// adapter don't count: there is nothing to fix until one is written.
  bool get needsAttention => results.any(
    (CountryResult r) =>
        r.status == RefreshStatus.skipped || r.status == RefreshStatus.failed,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'needsAttention': needsAttention,
    'counts': <String, int>{
      for (final RefreshStatus s in RefreshStatus.values) s.name: count(s),
    },
    'countries': <Map<String, Object?>>[
      for (final CountryResult r in results) r.toJson(),
    ],
  };

  String toMarkdown() {
    final StringBuffer sb = StringBuffer()
      ..writeln('| Country | Status | Details |')
      ..writeln('| --- | --- | --- |');
    for (final CountryResult r in results) {
      final String details = r.status == RefreshStatus.refreshed
          ? '${r.entries} ${r.entries == 1 ? 'entry' : 'entries'}'
          : _escapeMarkdownCell(r.reason ?? '');
      sb.writeln('| ${r.country} | ${r.status.name} | $details |');
    }
    return sb.toString();
  }

  static String _escapeMarkdownCell(String s) =>
      s.replaceAll(RegExp(r'\s*\n\s*'), ' ').replaceAll('|', r'\|').trim();
}

/// Runs the adapters in [registry] for each of [targets], passing every
/// successful result to [write], and records each country's outcome.
Future<RefreshSummary> refreshCountries(
  Iterable<String> targets,
  Map<String, CountryAdapter?> registry, {
  required void Function(String cc, Map<String, BankEntry> entries) write,
}) async {
  final List<CountryResult> results = <CountryResult>[];
  for (final String cc in targets) {
    final CountryAdapter? adapter = registry[cc];
    if (adapter == null) {
      final String reason = registry.containsKey(cc)
          ? 'no adapter yet'
          : 'unknown country';
      print('[$cc] $reason — skipping');
      results.add(
        CountryResult(cc, RefreshStatus.notImplemented, reason: reason),
      );
      continue;
    }
    try {
      print('[$cc] fetching…');
      final Map<String, BankEntry> entries = await adapter();
      write(cc, entries);
      results.add(
        CountryResult(cc, RefreshStatus.refreshed, entries: entries.length),
      );
    } on AdapterSkipped catch (e) {
      print('[$cc] skipped: $e');
      results.add(CountryResult(cc, RefreshStatus.skipped, reason: e.reason));
    } catch (e, st) {
      stderr.writeln('[$cc] failed: $e\n$st');
      results.add(CountryResult(cc, RefreshStatus.failed, reason: '$e'));
    }
  }
  return RefreshSummary(results);
}

// ---------------------------------------------------------------------------
// DE — Deutsche Bundesbank
// ---------------------------------------------------------------------------
//
// Bundesbank publishes the Bankleitzahlen (BLZ) directory quarterly as a
// fixed-width text file in ISO-8859-1. Columns (1-indexed, 1-based bytes):
//
//   1-8    BLZ (bank code)
//   9      marker '1' = the BLZ's main record, '2' = additional branch
//          rows sharing that BLZ
//   10-67  full bank name
//   68-72  postal code
//   73-107 city
//   108-134 short name
//   135-139 PAN (card institution number, may be blank)
//   140-150 BIC (may be blank)
//   ...
//
// Docs: https://www.bundesbank.de/en/tasks/payment-systems/services/bank-sort-codes
//
// The download URL changes with every release, so we look up the current
// TXT link on the download page instead of hardcoding it. Setting
// `BUNDESBANK_BLZ_URL` overrides the lookup (e.g. to pin a specific file).

const String bundesbankDownloadPage =
    'https://www.bundesbank.de/en/tasks/payment-systems/services/'
    'bank-sort-codes/download-bank-sort-codes-626218';

Future<Map<String, BankEntry>> fetchDe() async {
  final HttpClient client = HttpClient();
  try {
    String? url = Platform.environment['BUNDESBANK_BLZ_URL'];
    ({DateTime from, DateTime until})? validity;
    if (url == null || url.isEmpty) {
      final String page = latin1.decode(
        await _get(client, Uri.parse(bundesbankDownloadPage)),
        allowInvalid: true,
      );
      url = findBundesbankBlzTxtUrl(page);
      validity = findBundesbankBlzValidity(page);
      if (url == null) {
        throw StateError(
          'No blz-aktuell TXT link found on $bundesbankDownloadPage — '
          'the page layout may have changed. Set BUNDESBANK_BLZ_URL to '
          'refresh manually.',
        );
      }
    }
    print('[DE] downloading $url');
    recordSource(
      'DE',
      DatasetSource(
        publisher: 'Deutsche Bundesbank',
        url: url,
        effectiveFrom: validity?.from,
        validUntil: validity?.until,
      ),
    );
    return parseBundesbankBlz(
      latin1.decode(await _get(client, Uri.parse(url))),
    );
  } finally {
    client.close(force: true);
  }
}

/// Throws a [StateError] if a refresh returned no entries, or fewer than
/// half the [previous] dataset's, so a truncated or placeholder download
/// can't wipe a country's data. A genuine drop that large needs a
/// maintainer to look at the source and update the JSON by hand.
void checkPlausibleSize(int fresh, int previous) {
  if (fresh == 0) {
    throw StateError('refresh returned no entries; keeping existing data');
  }
  if (fresh * 2 < previous) {
    throw StateError(
      'refresh returned $fresh entries, less than half of the existing '
      '$previous; keeping existing data',
    );
  }
}

Future<List<int>> _get(HttpClient client, Uri uri) async {
  final HttpClientRequest req = await client.getUrl(uri);
  final HttpClientResponse res = await req.close();
  if (res.statusCode != 200) {
    throw StateError('GET $uri failed: HTTP ${res.statusCode}');
  }
  final List<int> bytes = <int>[];
  await res.forEach(bytes.addAll);
  return bytes;
}

/// Returns the absolute URL of the currently valid, unpacked fixed-width
/// BLZ file linked from the Bundesbank download page, or `null` if the
/// page doesn't link one. The upcoming file (`blz-neu-…`) is ignored so
/// the dataset only changes once the new file is actually in force.
String? findBundesbankBlzTxtUrl(String html) {
  final RegExpMatch? match = RegExp(
    r'href="([^"]*/blz-aktuell-txt-data\.txt)"',
  ).firstMatch(html);
  if (match == null) return null;
  return Uri.parse(bundesbankDownloadPage).resolve(match.group(1)!).toString();
}

/// Reads the validity period ("gültig vom 07.09.2026 bis 06.12.2026")
/// printed next to the current TXT link on the Bundesbank download page,
/// or `null` if it isn't there.
({DateTime from, DateTime until})? findBundesbankBlzValidity(String html) {
  final RegExpMatch? match = RegExp(
    r'/blz-aktuell-txt-data\.txt"[\s\S]{0,800}?'
    r'vom\s+(\d{2})\.(\d{2})\.(\d{4})\s+bis\s+(\d{2})\.(\d{2})\.(\d{4})',
  ).firstMatch(html);
  if (match == null) return null;
  DateTime at(int i) => DateTime.utc(
    int.parse(match.group(i + 2)!),
    int.parse(match.group(i + 1)!),
    int.parse(match.group(i)!),
  );
  return (from: at(1), until: at(4));
}

/// Pure parser: turns a Bundesbank BLZ fixed-width dump (already decoded
/// from ISO-8859-1) into the same map shape the refresh pipeline writes.
///
/// Exposed at top level so the parser can be unit-tested against a
/// checked-in fixture without hitting the network.
Map<String, BankEntry> parseBundesbankBlz(String text) {
  final Map<String, BankEntry> result = <String, BankEntry>{};
  for (final String line in const LineSplitter().convert(text)) {
    if (line.length < 150) continue;
    if (line.substring(8, 9) != '1') continue; // only main records

    final String blz = line.substring(0, 8).trim();
    final String name = line.substring(9, 67).trim();
    final String postcode = line.substring(67, 72).trim();
    final String city = line.substring(72, 107).trim();
    final String shortName = line.substring(107, 134).trim();
    final String bic = line.substring(139, 150).trim();

    if (blz.isEmpty || bic.isEmpty) continue;
    result[blz] = BankEntry(
      bic: bic,
      bankName: name,
      bankShortName: shortName.isEmpty ? name : shortName,
      bankPostcode: postcode.isEmpty ? null : postcode,
      bankLocation: city.isEmpty ? null : city,
    );
  }
  return result;
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/// Returns [override] if it's set, otherwise the first link on [pageUrl]
/// that [find] picks out. Throws if the page doesn't link the file, so a
/// changed page layout fails the refresh loudly instead of silently.
Future<String> _resolveUrl(
  HttpClient client, {
  required String? override,
  required String pageUrl,
  required String? Function(String html) find,
  required String envName,
}) async {
  if (override != null && override.isNotEmpty) return override;
  final String page = utf8.decode(
    await _get(client, Uri.parse(pageUrl)),
    allowMalformed: true,
  );
  final String? url = find(page);
  if (url == null) {
    throw StateError(
      'No download link found on $pageUrl — the page layout may have '
      'changed. Set $envName to refresh manually.',
    );
  }
  return url;
}

/// Returns the first `href` on [html] matching [pattern] (which must
/// capture the link in group 1), resolved against [pageUrl].
String? _findLink(String html, RegExp pattern, String pageUrl) {
  final RegExpMatch? match = pattern.firstMatch(html);
  if (match == null) return null;
  final String href = match.group(1)!.replaceAll('&amp;', '&');
  return Uri.parse(pageUrl).resolve(href).toString();
}

final RegExp _bicPattern = RegExp(r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');

/// Normalises a BIC as published (e.g. `GEBA BE BB`) and returns `null`
/// for placeholders such as `VRIJ`, `N/A` or `None`.
String? _normaliseBic(String raw) {
  final String bic = raw.replaceAll(RegExp(r'\s'), '').toUpperCase();
  return _bicPattern.hasMatch(bic) ? bic : null;
}

/// Finds the first row of [rows] whose cells contain every header in
/// [required] (compared trimmed and case-insensitively) and returns its
/// index together with a header → column map. Throws a [FormatException]
/// if there is no such row, i.e. the upstream layout changed.
(int, Map<String, int>) _findHeader(
  List<List<String>> rows,
  List<String> required,
  String source,
) {
  for (int i = 0; i < rows.length; i++) {
    final Map<String, int> columns = <String, int>{};
    for (int c = 0; c < rows[i].length; c++) {
      columns.putIfAbsent(rows[i][c].trim().toLowerCase(), () => c);
    }
    if (required.every((String h) => columns.containsKey(h.toLowerCase()))) {
      return (
        i,
        <String, int>{
          for (final String h in required) h: columns[h.toLowerCase()]!,
        },
      );
    }
  }
  throw FormatException('$source: header row ${required.join(', ')} not found');
}

/// Splits one CSV line on [delimiter], honouring double-quoted fields
/// (which may contain the delimiter) and `""` escapes inside them.
List<String> splitCsvLine(String line, String delimiter) {
  final List<String> fields = <String>[];
  final StringBuffer field = StringBuffer();
  bool quoted = false;
  for (int i = 0; i < line.length; i++) {
    final String ch = line[i];
    if (quoted) {
      if (ch == '"' && i + 1 < line.length && line[i + 1] == '"') {
        field.write('"');
        i++;
      } else if (ch == '"') {
        quoted = false;
      } else {
        field.write(ch);
      }
    } else if (ch == '"') {
      quoted = true;
    } else if (ch == delimiter) {
      fields.add(field.toString());
      field.clear();
    } else {
      field.write(ch);
    }
  }
  fields.add(field.toString());
  return fields;
}

String _cell(List<String> row, int column) =>
    column < row.length ? row[column].trim() : '';

/// Left-pads purely numeric bank codes to [width] digits (spreadsheets may
/// store `001` as the number 1). Returns `null` for anything else.
String? _bankCode(String raw, int width) {
  final String code = raw.trim();
  if (code.isEmpty || code.length > width || !RegExp(r'^\d+$').hasMatch(code)) {
    return null;
  }
  return code.padLeft(width, '0');
}

/// Minimal reader for the first worksheet of an `.xlsx` file: returns its
/// rows as lists of cell strings, with gaps filled by empty strings.
///
/// Handles what the NBB, ABBL and Betaalvereniging files use (shared and
/// inline strings, numbers, stored or deflated zip entries) without pulling
/// in an archive/XML dependency. Formatting, formulas and dates aren't
/// interpreted.
List<List<String>> readXlsxRows(List<int> bytes) {
  final Map<String, List<int>> files = _unzip(bytes);
  final List<int>? sheet = files['xl/worksheets/sheet1.xml'];
  if (sheet == null) {
    throw const FormatException('xlsx: xl/worksheets/sheet1.xml not found');
  }

  final List<String> shared = <String>[];
  final List<int>? sst = files['xl/sharedStrings.xml'];
  if (sst != null) {
    for (final RegExpMatch si in RegExp(
      r'<si>(.*?)</si>',
      dotAll: true,
    ).allMatches(utf8.decode(sst))) {
      shared.add(_xmlText(si.group(1)!));
    }
  }

  final List<List<String>> rows = <List<String>>[];
  final RegExp cellPattern = RegExp(
    r'<c\s([^>]*?)(?:/>|>(.*?)</c>)',
    dotAll: true,
  );
  for (final RegExpMatch row in RegExp(
    r'<row\b[^>]*?(?:/>|>(.*?)</row>)',
    dotAll: true,
  ).allMatches(utf8.decode(sheet))) {
    final List<String> cells = <String>[];
    for (final RegExpMatch cell in cellPattern.allMatches(row.group(1) ?? '')) {
      final String attrs = cell.group(1)!;
      final String body = cell.group(2) ?? '';
      final String? ref = RegExp(
        r'\br="([A-Z]+)\d*"',
      ).firstMatch(attrs)?.group(1);
      final String? type = RegExp(r'\bt="(\w+)"').firstMatch(attrs)?.group(1);
      final String? raw = RegExp(
        r'<v>(.*?)</v>',
        dotAll: true,
      ).firstMatch(body)?.group(1);

      final String value = switch (type) {
        's' when raw != null => shared[int.parse(raw)],
        'inlineStr' => _xmlText(body),
        _ => raw == null ? '' : _xmlUnescape(raw),
      };
      final int column = ref == null ? cells.length : _columnIndex(ref);
      while (cells.length < column) {
        cells.add('');
      }
      if (column < cells.length) {
        cells[column] = value;
      } else {
        cells.add(value);
      }
    }
    rows.add(cells);
  }
  return rows;
}

int _columnIndex(String letters) {
  int index = 0;
  for (final int unit in letters.codeUnits) {
    index = index * 26 + (unit - 0x40);
  }
  return index - 1;
}

/// Concatenates the `<t>` runs of a shared/inline string, skipping
/// phonetic hints (`<rPh>`).
String _xmlText(String xml) => RegExp(r'<t(?:\s[^>]*)?>(.*?)</t>', dotAll: true)
    .allMatches(xml.replaceAll(RegExp(r'<rPh\b.*?</rPh>', dotAll: true), ''))
    .map((RegExpMatch m) => _xmlUnescape(m.group(1)!))
    .join();

String _xmlUnescape(String s) => s.replaceAllMapped(
  RegExp(r'&(#x[0-9a-fA-F]+|#\d+|lt|gt|quot|apos|amp);'),
  (Match m) => switch (m.group(1)!) {
    'lt' => '<',
    'gt' => '>',
    'quot' => '"',
    'apos' => "'",
    'amp' => '&',
    final String n when n.startsWith('#x') => String.fromCharCode(
      int.parse(n.substring(2), radix: 16),
    ),
    final String n => String.fromCharCode(int.parse(n.substring(1))),
  },
);

/// Extracts every entry of a (non-zip64) zip archive via its central
/// directory.
Map<String, List<int>> _unzip(List<int> bytes) {
  final ByteData data = ByteData.sublistView(Uint8List.fromList(bytes));
  int eocd = -1;
  for (int i = data.lengthInBytes - 22; i >= 0; i--) {
    if (data.getUint32(i, Endian.little) == 0x06054b50) {
      eocd = i;
      break;
    }
  }
  if (eocd < 0) throw const FormatException('xlsx: not a zip archive');

  final int count = data.getUint16(eocd + 10, Endian.little);
  int offset = data.getUint32(eocd + 16, Endian.little);
  final Map<String, List<int>> files = <String, List<int>>{};
  for (int i = 0; i < count; i++) {
    if (data.getUint32(offset, Endian.little) != 0x02014b50) {
      throw const FormatException('xlsx: corrupt central directory');
    }
    final int method = data.getUint16(offset + 10, Endian.little);
    final int size = data.getUint32(offset + 20, Endian.little);
    final int nameLength = data.getUint16(offset + 28, Endian.little);
    final int extraLength = data.getUint16(offset + 30, Endian.little);
    final int commentLength = data.getUint16(offset + 32, Endian.little);
    final int local = data.getUint32(offset + 42, Endian.little);
    final String name = utf8.decode(
      bytes.sublist(offset + 46, offset + 46 + nameLength),
    );

    final int start =
        local +
        30 +
        data.getUint16(local + 26, Endian.little) +
        data.getUint16(local + 28, Endian.little);
    final List<int> raw = bytes.sublist(start, start + size);
    files[name] = switch (method) {
      0 => raw,
      8 => ZLibDecoder(raw: true).convert(raw),
      _ => throw FormatException('xlsx: unsupported compression $method'),
    };
    offset += 46 + nameLength + extraLength + commentLength;
  }
  return files;
}

// ---------------------------------------------------------------------------
// AT — Oesterreichische Nationalbank (OeNB)
// ---------------------------------------------------------------------------
//
// OeNB publishes its SEPA directory of Austrian payment service providers
// daily as a semicolon-separated CSV in ISO-8859-1, at a fixed URL:
// a few disclaimer lines, then a header row (`Kennzeichen;Identnummer;
// Bankleitzahl;…;Bankenname;Straße;PLZ;Ort;…;SWIFT-Code;…`) and one row per
// bank code.
//
// Docs: https://www.oenb.at/Statistik/Klassifikationen/SEPA-Zahlungsverkehrs-Verzeichnis.html
//
// `OENB_SEPA_URL` overrides the download URL.

const String oenbSepaUrl =
    'https://www.oenb.at/docroot/downloads_observ/sepa-zv-vz_gesamt.csv';

Future<Map<String, BankEntry>> fetchAt() async {
  final HttpClient client = HttpClient();
  try {
    final String? override = Platform.environment['OENB_SEPA_URL'];
    final String url = override == null || override.isEmpty
        ? oenbSepaUrl
        : override;
    print('[AT] downloading $url');
    recordSource(
      'AT',
      DatasetSource(
        publisher: 'Oesterreichische Nationalbank (OeNB), SEPA directory',
        url: url,
        notes:
            'The file is a live query ("SEPA-Verzeichnis-Abfrage vom '
            '<date>") and states no validity date.',
      ),
    );
    return parseOenbSepa(latin1.decode(await _get(client, Uri.parse(url))));
  } finally {
    client.close(force: true);
  }
}

/// Pure parser for the OeNB SEPA directory CSV (already decoded from
/// ISO-8859-1). Bank codes are padded to the 5 digits used in IBANs (the
/// file lists e.g. the OeNB itself as `100`); rows without a valid BIC are
/// skipped.
Map<String, BankEntry> parseOenbSepa(String text) {
  final List<List<String>> rows = <List<String>>[
    for (final String line in const LineSplitter().convert(text))
      splitCsvLine(line, ';'),
  ];
  final (int header, Map<String, int> col) = _findHeader(rows, const <String>[
    'Bankleitzahl',
    'Bankenname',
    'Straße',
    'PLZ',
    'Ort',
    'SWIFT-Code',
  ], 'OeNB SEPA directory');

  final Map<String, BankEntry> result = <String, BankEntry>{};
  for (final List<String> row in rows.skip(header + 1)) {
    final String? code = _bankCode(_cell(row, col['Bankleitzahl']!), 5);
    final String? bic = _normaliseBic(_cell(row, col['SWIFT-Code']!));
    final String name = _cell(row, col['Bankenname']!);
    if (code == null || bic == null || name.isEmpty) continue;
    final String address = _cell(row, col['Straße']!);
    final String postcode = _cell(row, col['PLZ']!);
    final String city = _cell(row, col['Ort']!);
    result.putIfAbsent(
      code,
      () => BankEntry(
        bic: bic,
        bankName: name,
        bankShortName: name,
        bankAddress: address.isEmpty ? null : address,
        bankPostcode: postcode.isEmpty ? null : postcode,
        bankLocation: city.isEmpty ? null : city,
      ),
    );
  }
  return result;
}

// ---------------------------------------------------------------------------
// BE — National Bank of Belgium (NBB)
// ---------------------------------------------------------------------------
//
// NBB publishes the full list of Belgian bank identification codes as an
// xlsx at a fixed "current" URL. After a version line, the header is
// `T_Identification_Number | Biccode | T_Institutions_Dutch | …_French |
// …_German | …_English`, one row per 3-digit code. Unassigned codes carry
// placeholders such as `VRIJ` or `N/A` instead of a BIC.
//
// Docs: https://www.nbb.be/en/payments-and-securities/payment-standards/bank-identification-codes
//
// `NBB_BIC_URL` overrides the download URL.

const String nbbBicUrl =
    'https://www.nbb.be/doc/be/be/protocol/full_list_current.xlsx';

Future<Map<String, BankEntry>> fetchBe() async {
  final HttpClient client = HttpClient();
  try {
    final String? override = Platform.environment['NBB_BIC_URL'];
    final String url = override == null || override.isEmpty
        ? nbbBicUrl
        : override;
    print('[BE] downloading $url');
    recordSource(
      'BE',
      DatasetSource(publisher: 'National Bank of Belgium (NBB)', url: url),
    );
    return parseNbbBic(readXlsxRows(await _get(client, Uri.parse(url))));
  } finally {
    client.close(force: true);
  }
}

/// Pure parser for the NBB bank identification code list. The name is
/// taken in Dutch, falling back to French, German, then English.
Map<String, BankEntry> parseNbbBic(List<List<String>> rows) {
  const List<String> names = <String>[
    'T_Institutions_Dutch',
    'T_Institutions_French',
    'T_Institutions_German',
    'T_Institutions_English',
  ];
  final (int header, Map<String, int> col) = _findHeader(rows, const <String>[
    'T_Identification_Number',
    'Biccode',
    ...names,
  ], 'NBB bank identification codes');

  final Map<String, BankEntry> result = <String, BankEntry>{};
  for (final List<String> row in rows.skip(header + 1)) {
    final String? code = _bankCode(
      _cell(row, col['T_Identification_Number']!),
      3,
    );
    final String? bic = _normaliseBic(_cell(row, col['Biccode']!));
    final String name = names
        .map((String h) => _cell(row, col[h]!))
        .firstWhere((String n) => n.isNotEmpty, orElse: () => '');
    if (code == null || bic == null || name.isEmpty) continue;
    result.putIfAbsent(
      code,
      () => BankEntry(bic: bic, bankName: name, bankShortName: name),
    );
  }
  return result;
}

// ---------------------------------------------------------------------------
// LU — Luxembourg Bankers' Association (ABBL)
// ---------------------------------------------------------------------------
//
// ABBL publishes the Luxembourg register of IBAN/BIC codes as an xlsx
// whose URL changes with every revision, so we look it up on the
// publication page. After a title row, the header is `Credit institution |
// IBAN Code | BICCode`, one row per 3-digit code.
//
// `ABBL_IBAN_BIC_URL` overrides the lookup.

const String abblRegisterPage =
    'https://www.abbl.lu/publications/abbl-luxembourg-register-of-iban-bic-codes/';

Future<Map<String, BankEntry>> fetchLu() async {
  final HttpClient client = HttpClient();
  try {
    final String url = await _resolveUrl(
      client,
      override: Platform.environment['ABBL_IBAN_BIC_URL'],
      pageUrl: abblRegisterPage,
      find: findAbblRegisterUrl,
      envName: 'ABBL_IBAN_BIC_URL',
    );
    print('[LU] downloading $url');
    recordSource(
      'LU',
      DatasetSource(
        publisher: 'ABBL, Luxembourg register of IBAN/BIC codes',
        url: url,
        notes: 'The spreadsheet states no date.',
      ),
    );
    return parseAbblRegister(readXlsxRows(await _get(client, Uri.parse(url))));
  } finally {
    client.close(force: true);
  }
}

/// Returns the absolute URL of the register xlsx linked from the ABBL
/// publication page, or `null` if the page doesn't link one.
String? findAbblRegisterUrl(String html) => _findLink(
  html,
  RegExp(r'href="([^"]*IBAN[^"]*\.xlsx)"', caseSensitive: false),
  abblRegisterPage,
);

/// Pure parser for the ABBL IBAN/BIC register.
Map<String, BankEntry> parseAbblRegister(List<List<String>> rows) {
  final (int header, Map<String, int> col) = _findHeader(rows, const <String>[
    'Credit institution',
    'IBAN Code',
    'BICCode',
  ], 'ABBL IBAN/BIC register');

  final Map<String, BankEntry> result = <String, BankEntry>{};
  for (final List<String> row in rows.skip(header + 1)) {
    final String? code = _bankCode(_cell(row, col['IBAN Code']!), 3);
    final String? bic = _normaliseBic(_cell(row, col['BICCode']!));
    final String name = _cell(row, col['Credit institution']!);
    if (code == null || bic == null || name.isEmpty) continue;
    result.putIfAbsent(
      code,
      () => BankEntry(bic: bic, bankName: name, bankShortName: name),
    );
  }
  return result;
}

// ---------------------------------------------------------------------------
// NL — Betaalvereniging Nederland
// ---------------------------------------------------------------------------
//
// The Dutch Payments Association publishes the BIC list for Dutch IBANs as
// an xlsx uploaded under a dated WordPress path (`/uploads/YYYY/MM/`), so
// we look it up on the knowledge-base page. After a title row, the header
// is `BIC | Identifier | Betaaldienstverlener / Payment Service Provider`,
// one row per 4-letter bank identifier.
//
// `BETAALVERENIGING_BIC_URL` overrides the lookup.

const String betaalverenigingPage =
    'https://www.betaalvereniging.nl/kennisbank/iban-en-bic/';

Future<Map<String, BankEntry>> fetchNl() async {
  final HttpClient client = HttpClient();
  try {
    final String url = await _resolveUrl(
      client,
      override: Platform.environment['BETAALVERENIGING_BIC_URL'],
      pageUrl: betaalverenigingPage,
      find: findBetaalverenigingBicUrl,
      envName: 'BETAALVERENIGING_BIC_URL',
    );
    print('[NL] downloading $url');
    recordSource(
      'NL',
      DatasetSource(publisher: 'Betaalvereniging Nederland', url: url),
    );
    return parseBetaalverenigingBic(
      readXlsxRows(await _get(client, Uri.parse(url))),
    );
  } finally {
    client.close(force: true);
  }
}

/// Returns the absolute URL of the BIC list xlsx linked from the
/// Betaalvereniging knowledge-base page, or `null` if it isn't linked.
String? findBetaalverenigingBicUrl(String html) => _findLink(
  html,
  RegExp(r'href="([^"]*BIC-lijst-NL[^"]*\.xlsx)"', caseSensitive: false),
  betaalverenigingPage,
);

/// Pure parser for the Betaalvereniging BIC list.
Map<String, BankEntry> parseBetaalverenigingBic(List<List<String>> rows) {
  const String nameHeader = 'Betaaldienstverlener / Payment Service Provider';
  final (int header, Map<String, int> col) = _findHeader(rows, const <String>[
    'BIC',
    'Identifier',
    nameHeader,
  ], 'Betaalvereniging BIC list');

  final Map<String, BankEntry> result = <String, BankEntry>{};
  for (final List<String> row in rows.skip(header + 1)) {
    final String code = _cell(row, col['Identifier']!).toUpperCase();
    final String? bic = _normaliseBic(_cell(row, col['BIC']!));
    final String name = _cell(row, col[nameHeader]!);
    if (!RegExp(r'^[A-Z]{4}$').hasMatch(code) || bic == null || name.isEmpty) {
      continue;
    }
    result.putIfAbsent(
      code,
      () => BankEntry(bic: bic, bankName: name, bankShortName: name),
    );
  }
  return result;
}
