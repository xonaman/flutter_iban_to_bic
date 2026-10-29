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
//   3. Run the refresh for it, which creates `data/bank_codes/<cc>.jsonl`
//      and `assets/bank_codes/<cc>.json`, and add the asset to
//      `pubspec.yaml`'s flutter.assets list.
//
// To fix an entry by hand, edit `data/bank_codes/<cc>.jsonl` and run
// `dart run tool/build_assets.dart` to regenerate the asset.
//
// Run with:
//   dart run tool/refresh_data.dart           # refresh everything
//   dart run tool/refresh_data.dart DE NL     # refresh only these countries

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'bank_codes.dart';

export 'bank_codes.dart' show BankEntry;

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
      writeCountry(cc, entries);
      print(
        '[$cc] wrote ${sourcePath(cc)} and ${assetPath(cc)} '
        '(${entries.length} entries)',
      );
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
    if (url == null || url.isEmpty) {
      final String page = latin1.decode(
        await _get(client, Uri.parse(bundesbankDownloadPage)),
        allowInvalid: true,
      );
      url = findBundesbankBlzTxtUrl(page);
      if (url == null) {
        throw StateError(
          'No blz-aktuell TXT link found on $bundesbankDownloadPage — '
          'the page layout may have changed. Set BUNDESBANK_BLZ_URL to '
          'refresh manually.',
        );
      }
    }
    print('[DE] downloading $url');
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
