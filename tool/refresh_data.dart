// Refreshes `assets/bank_codes/<cc>.json` from each country's authoritative
// source. Run manually or via the `refresh-data` GitHub Action.
//
// Adding a new country:
//   1. Register it under `adapters` below.
//   2. Implement a function `Future<Map<String, BankEntry>> fetchXX()` that
//      returns `{ bankCode: BankEntry(bic, bankName, bankShortName, ...) }`.
//      Fetch from the central bank / competent authority — no scraping of
//      third-party aggregators.
//   3. Add the country to `pubspec.yaml`'s flutter.assets list if new.
//
// Run with:
//   dart run tool/refresh_data.dart           # refresh everything
//   dart run tool/refresh_data.dart DE NL     # refresh only these countries

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

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
  final Iterable<String> targets =
      args.isEmpty ? adapters.keys : args.map((String a) => a.toUpperCase());

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
      File(path).writeAsStringSync('${jsonEncode(asJson)}\n');
      print('[$cc] wrote $path (${entries.length} entries)');
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
//   9      marker '1' = actively assigned
//   10-67  full bank name
//   68-72  postal code
//   73-107 city
//   108-134 short name
//   135-145 BIC (may be blank)
//   ...
//
// Docs: https://www.bundesbank.de/en/tasks/payment-systems/services/bank-sort-codes
//
// We expect the environment variable `BUNDESBANK_BLZ_URL` to point at the
// current quarter's download. The URL changes each quarter, which is why
// it's configured at the workflow level rather than hardcoded.

Future<Map<String, BankEntry>> fetchDe() async {
  final String? url = Platform.environment['BUNDESBANK_BLZ_URL'];
  if (url == null || url.isEmpty) {
    throw AdapterSkipped(
      'BUNDESBANK_BLZ_URL is not set — rotate it to the current quarter\'s '
      'download (see https://www.bundesbank.de/en/tasks/payment-systems/'
      'services/bank-sort-codes/download-bank-sort-codes-626218).',
    );
  }

  final HttpClient client = HttpClient();
  try {
    final HttpClientRequest req = await client.getUrl(Uri.parse(url));
    final HttpClientResponse res = await req.close();
    if (res.statusCode != 200) {
      throw StateError('BLZ download failed: HTTP ${res.statusCode}');
    }
    final List<int> bytes = <int>[];
    await res.forEach(bytes.addAll);
    return parseBundesbankBlz(latin1.decode(bytes));
  } finally {
    client.close(force: true);
  }
}

/// Pure parser: turns a Bundesbank BLZ fixed-width dump (already decoded
/// from ISO-8859-1) into the same map shape the refresh pipeline writes.
///
/// Exposed at top level so the parser can be unit-tested against a
/// checked-in fixture without hitting the network.
Map<String, BankEntry> parseBundesbankBlz(String text) {
  final Map<String, BankEntry> result = <String, BankEntry>{};
  for (final String line in const LineSplitter().convert(text)) {
    if (line.length < 145) continue;
    if (line.substring(8, 9) != '1') continue; // only active rows

    final String blz = line.substring(0, 8).trim();
    final String name = line.substring(9, 67).trim();
    final String postcode = line.substring(67, 72).trim();
    final String city = line.substring(72, 107).trim();
    final String shortName = line.substring(107, 134).trim();
    final String bic = line.substring(134, 145).trim();

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
