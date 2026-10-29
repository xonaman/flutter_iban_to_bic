// Refreshes `assets/bank_codes/<cc>.json` from each country's authoritative
// source. Run manually or via the `refresh-data` GitHub Action.
//
// Adding a new country:
//   1. Register it under `adapters` below.
//   2. Implement a function `Future<Map<String, BankEntry>> fetchXX()` that
//      returns `{ bankCode: BankEntry(bic, bankName, bankShortName, ...) }`.
//      Fetch from the central bank / competent authority — no scraping of
//      third-party aggregators.
//   3. Record where the data came from with `recordSource(...)` so the
//      provenance in `assets/bank_codes/meta.json` stays current.
//   4. Add the country to `pubspec.yaml`'s flutter.assets list if new.
//
// Run with:
//   dart run tool/refresh_data.dart           # refresh everything
//   dart run tool/refresh_data.dart DE NL     # refresh only these countries

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;

class BankEntry {
  final String bic;
  final String bankName;
  final String bankShortName;
  final String? bankAddress;
  final String? bankPostcode;
  final String? bankLocation;

  BankEntry({
    required this.bic,
    required this.bankName,
    required this.bankShortName,
    this.bankAddress,
    this.bankPostcode,
    this.bankLocation,
  });

  Map<String, String?> toJson() => <String, String?>{
    'bic': bic,
    'bankName': bankName,
    'bankShortName': bankShortName,
    if (bankAddress != null) 'bankAddress': bankAddress,
    if (bankPostcode != null) 'bankPostcode': bankPostcode,
    if (bankLocation != null) 'bankLocation': bankLocation,
  };
}

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

/// Provenance of a freshly fetched dataset, as reported by its adapter.
class DatasetSource {
  DatasetSource({
    required this.publisher,
    required this.url,
    this.effectiveFrom,
    this.validUntil,
  });

  final String publisher;
  final String url;

  /// Day the upstream file took effect (or was published), if stated.
  final DateTime? effectiveFrom;

  /// Last day the upstream file is valid, if stated.
  final DateTime? validUntil;
}

/// Sources recorded by adapters during this run, keyed by country code.
final Map<String, DatasetSource> _sources = <String, DatasetSource>{};

/// Called by an adapter once it knows which upstream file it is reading.
void recordSource(String countryCode, DatasetSource source) {
  _sources[countryCode] = source;
}

const String metaPath = 'assets/bank_codes/meta.json';

/// Registry of per-country adapters. `null` means "not yet implemented" and
/// the refresh script leaves the existing JSON untouched.
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
  final Iterable<String> targets = args.isEmpty
      ? adapters.keys
      : args.map((String a) => a.toUpperCase());

  int refreshed = 0;
  int skipped = 0;
  int failed = 0;

  for (final String cc in targets) {
    final CountryAdapter? adapter = adapters[cc];
    if (adapter == null) {
      print('[$cc] no adapter yet — skipping');
      skipped++;
      continue;
    }
    try {
      print('[$cc] fetching…');
      final Map<String, BankEntry> entries = await adapter();
      final String path = 'assets/bank_codes/${cc.toLowerCase()}.json';
      final Map<String, Map<String, String?>> asJson =
          <String, Map<String, String?>>{
            for (final MapEntry<String, BankEntry> e in entries.entries)
              e.key: e.value.toJson(),
          };
      final String body = '${jsonEncode(asJson)}\n';
      File(path).writeAsStringSync(body);
      print('[$cc] wrote $path (${entries.length} entries)');
      writeMeta(cc, body, _sources[cc]);
      refreshed++;
    } on AdapterSkipped catch (e) {
      print('[$cc] skipped: $e');
      skipped++;
    } catch (e, st) {
      stderr.writeln('[$cc] failed: $e\n$st');
      failed++;
    }
  }

  print('---');
  print('refreshed: $refreshed  skipped: $skipped  failed: $failed');
  if (failed > 0) exit(1);
}

/// Updates [cc]'s entry in `meta.json` for a freshly written dataset.
///
/// The entry is left alone when neither the content hash nor the source
/// changed, so a refresh that finds nothing new doesn't produce a diff.
void writeMeta(String cc, String body, DatasetSource? source, {DateTime? now}) {
  final File file = File(metaPath);
  final Map<String, dynamic> meta = file.existsSync()
      ? json.decode(file.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};
  final Map<String, dynamic>? old = meta[cc] as Map<String, dynamic>?;
  final Map<String, dynamic> next = buildMetaEntry(
    body,
    source,
    now ?? DateTime.now(),
  );
  if (old != null && _sameProvenance(old, next)) return;
  meta[cc] = next;
  final List<String> keys = meta.keys.toList()..sort();
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, dynamic>{for (final String k in keys) k: meta[k]})}\n',
  );
  print('[$cc] updated $metaPath');
}

/// The `meta.json` entry for a dataset whose file content is [body].
Map<String, dynamic> buildMetaEntry(
  String body,
  DatasetSource? source,
  DateTime now,
) => <String, dynamic>{
  'publisher': source?.publisher,
  'sourceUrl': source?.url,
  'retrievedOn': _day(now.toUtc()),
  'effectiveFrom': _day(source?.effectiveFrom),
  'validUntil': _day(source?.validUntil),
  'sha256': sha256.convert(utf8.encode(body)).toString(),
  'notes': null,
};

bool _sameProvenance(Map<String, dynamic> a, Map<String, dynamic> b) =>
    a['sha256'] == b['sha256'] &&
    a['sourceUrl'] == b['sourceUrl'] &&
    a['effectiveFrom'] == b['effectiveFrom'] &&
    a['validUntil'] == b['validUntil'];

String? _day(DateTime? d) => d?.toIso8601String().substring(0, 10);

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
