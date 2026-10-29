import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iban_to_bic/iban_to_bic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('dataInfo', () {
    test('every supported country has metadata', () async {
      final List<String> missing = <String>[
        for (final String cc in IbanToBic().supportedCountries)
          if (await dataInfo(cc) == null) cc,
      ];
      expect(missing, isEmpty);
    });

    test('hashes match the bundled datasets', () async {
      for (final String cc in IbanToBic().supportedCountries) {
        final DatasetInfo info = (await dataInfo(cc))!;
        final List<int> bytes = File(
          'assets/bank_codes/${cc.toLowerCase()}.json',
        ).readAsBytesSync();
        expect(
          info.sha256,
          sha256.convert(bytes).toString(),
          reason:
              '$cc: assets/bank_codes/meta.json is stale. Regenerate the '
              'dataset with tool/refresh_data.dart, or update its entry.',
        );
      }
    });

    test('meta.json covers exactly the bundled datasets', () {
      final Set<String> datasets = <String>{
        for (final FileSystemEntity f in Directory(
          'assets/bank_codes',
        ).listSync())
          if (f is File &&
              f.path.endsWith('.json') &&
              f.uri.pathSegments.last != 'meta.json')
            f.uri.pathSegments.last.split('.').first.toUpperCase(),
      };
      final Map<String, dynamic> meta =
          json.decode(File('assets/bank_codes/meta.json').readAsStringSync())
              as Map<String, dynamic>;
      expect(meta.keys.toSet(), datasets);
    });

    test('is case-insensitive and null for unknown countries', () async {
      expect((await dataInfo('de'))!.countryCode, 'DE');
      expect(await dataInfo('ZZ'), isNull);
    });

    test('exposes the German source and validity', () async {
      final DatasetInfo de = (await dataInfo('DE'))!;
      expect(de.publisher, 'Deutsche Bundesbank');
      expect(de.sourceUrl!.host, 'www.bundesbank.de');
      expect(de.effectiveFrom, isNotNull);
      expect(de.validUntil!.isAfter(de.effectiveFrom!), isTrue);
    });

    test('parses dates and leaves unknowns null', () async {
      final DatasetInfo info = (await dataInfo(
        'XX',
        bundle: _StringBundle(
          '{"XX":{"publisher":"Example","sourceUrl":"https://example.com/f",'
          '"retrievedOn":"2026-10-29","effectiveFrom":null,'
          '"validUntil":null,"sha256":"abc","notes":"n"}}',
        ),
      ))!;
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

class _StringBundle extends AssetBundle {
  _StringBundle(this.contents);
  final String contents;

  @override
  Future<ByteData> load(String key) async {
    final Uint8List bytes = Uint8List.fromList(utf8.encode(contents));
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => contents;
}
