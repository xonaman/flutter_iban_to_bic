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

/// Registry of per-country adapters. `null` means "not yet implemented" and
/// the refresh script leaves the existing data untouched.
final Map<String, CountryAdapter?> adapters = <String, CountryAdapter?>{
  'AT': null,
  'BE': null,
  'DE': fetchDe,
  'ES': null,
  'FR': null,
  'LT': null,
  'LU': null,
  'NL': null,
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
