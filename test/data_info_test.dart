import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:iban_to_bic/iban_to_bic.dart';
import 'package:iban_to_bic/src/data/bank_codes.dart';
import 'package:iban_to_bic/src/data_info.dart' show parseDatasetMeta;
import 'package:test/test.dart';

void main() {
  group('dataInfo', () {
    test('every supported country has metadata', () {
      final List<String> missing = <String>[
        for (final String cc in IbanToBic().supportedCountries)
          if (dataInfo(cc) == null) cc,
      ];
      expect(missing, isEmpty);
    });

    test('hashes match the bundled datasets', () async {
      for (final String cc in IbanToBic().supportedCountries) {
        final String dataset = await loadBankCodesJson(cc);
        expect(
          dataInfo(cc)!.sha256,
          sha256.convert(utf8.encode(dataset)).toString(),
          reason:
              '$cc: data/bank_codes/meta.json is stale. Regenerate the '
              'dataset with tool/refresh_data.dart or '
              'tool/build_assets.dart.',
        );
      }
    });

    // Reads the sources from disk, so VM only. The rest of this file runs
    // on the web too, which checks the hashes against the deferred-loaded
    // datasets there as well.
    test('meta.json covers exactly the bundled datasets', testOn: 'vm', () {
      final Set<String> sources = <String>{
        for (final FileSystemEntity f in Directory(
          'data/bank_codes',
        ).listSync())
          if (f is File && f.path.endsWith('.jsonl'))
            f.uri.pathSegments.last.split('.').first.toUpperCase(),
      };
      final Map<String, dynamic> meta =
          json.decode(File('data/bank_codes/meta.json').readAsStringSync())
              as Map<String, dynamic>;
      expect(meta.keys.toSet(), sources);
    });

    test('is case-insensitive and null for unknown countries', () {
      expect(dataInfo('de')!.countryCode, 'DE');
      expect(dataInfo('ZZ'), isNull);
    });

    test('exposes the German source and validity', () {
      final DatasetInfo de = dataInfo('DE')!;
      expect(de.publisher, 'Deutsche Bundesbank');
      expect(de.sourceUrl!.host, 'www.bundesbank.de');
      expect(de.effectiveFrom, isNotNull);
      expect(de.validUntil!.isAfter(de.effectiveFrom!), isTrue);
    });

    test('parses dates and leaves unknowns null', () {
      final DatasetInfo info = parseDatasetMeta(
        '{"XX":{"publisher":"Example","sourceUrl":"https://example.com/f",'
        '"retrievedOn":"2026-10-29","effectiveFrom":null,'
        '"validUntil":null,"sha256":"abc","notes":"n"}}',
      )['XX']!;
      expect(info.retrievedOn, DateTime.utc(2026, 10, 29));
      expect(info.effectiveFrom, isNull);
      expect(info.validUntil, isNull);
      expect(info.sourceUrl, Uri.parse('https://example.com/f'));
      expect(info.ageInDays(now: DateTime.utc(2026, 11, 8, 23)), 10);
    });

    test('ageInDays is null when the retrieval date is unknown', () {
      expect(
        const DatasetInfo(countryCode: 'ES', sha256: 'x').ageInDays(),
        isNull,
      );
    });
  });
}
