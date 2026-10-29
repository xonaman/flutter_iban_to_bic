import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iban_to_bic/iban_to_bic.dart';

import '../tool/bank_codes.dart';
import '../tool/summarize_changes.dart';

void main() {
  final BankEntry postbank = BankEntry(
    bic: 'PBNKDEFFXXX',
    bankName: 'Postbank',
    bankShortName: 'Postbank',
    bankPostcode: '10559',
  );
  final BankEntry ing = BankEntry(
    bic: 'INGDDEFFXXX',
    bankName: 'ING-DiBa',
    bankShortName: 'ING',
    bankLocation: 'Frankfurt am Main',
  );

  group('source format', () {
    test('writes one entry per line, sorted by code, and round-trips', () {
      final Map<String, BankEntry> entries = <String, BankEntry>{
        '50010517': ing,
        '10010010': postbank,
      };
      final String text = encodeSource(entries);
      expect(const LineSplitter().convert(text), <String>[
        '{"code":"10010010","bic":"PBNKDEFFXXX","bankName":"Postbank",'
            '"bankShortName":"Postbank","bankPostcode":"10559"}',
        '{"code":"50010517","bic":"INGDDEFFXXX","bankName":"ING-DiBa",'
            '"bankShortName":"ING","bankLocation":"Frankfurt am Main"}',
      ]);
      expect(decodeSource(text), entries);
    });

    test('rejects duplicate codes', () {
      final String line = encodeSource(<String, BankEntry>{'1': postbank});
      expect(() => decodeSource('$line$line'), throwsFormatException);
    });
  });

  group('asset format', () {
    test('groups identical banks and drops redundant fields', () {
      final String asset = encodeAsset(<String, BankEntry>{
        '3': postbank,
        '2': ing,
        '1': postbank,
      });
      expect(
        asset,
        '{"v":1,"banks":['
        '[["1","3"],"PBNKDEFFXXX","Postbank",null,null,"10559"],'
        '[["2"],"INGDDEFFXXX","ING-DiBa","ING",null,null,"Frankfurt am Main"]'
        ']}\n',
      );
    });

    test('AssetJsonResolver decodes it', () async {
      final AssetJsonResolver resolver = AssetJsonResolver(
        'fake.json',
        bundle: _StringBundle(
          encodeAsset(<String, BankEntry>{'3': postbank, '1': postbank}),
        ),
      );
      expect(await resolver.resolve('1'), _bicOf(postbank));
      expect(await resolver.resolve('3'), _bicOf(postbank));
      expect(await resolver.resolve('2'), isNull);
    });

    test('AssetJsonResolver rejects an unknown version', () async {
      final AssetJsonResolver resolver = AssetJsonResolver(
        'fake.json',
        bundle: _StringBundle('{"v":2,"banks":[]}'),
      );
      expect(resolver.resolve('1'), throwsFormatException);
    });
  });

  group('bundled datasets', () {
    final List<String> countries = sourceCountries();

    test('has a source and an asset for every supported country', () {
      expect(countries, sharedIbanToBic.supportedCountries.toList()..sort());
      for (final String cc in countries) {
        expect(File(assetPath(cc)).existsSync(), isTrue, reason: cc);
      }
    });

    test('sources are sorted and canonically formatted', () {
      for (final String cc in countries) {
        final String text = File(sourcePath(cc)).readAsStringSync();
        expect(encodeSource(decodeSource(text)), text, reason: cc);
      }
    });

    test('assets are up to date (run `dart run tool/build_assets.dart`)', () {
      for (final String cc in countries) {
        expect(
          File(assetPath(cc)).readAsStringSync(),
          encodeAsset(readSource(cc)),
          reason: assetPath(cc),
        );
      }
    });

    test('every entry carries a BIC', () {
      // One line per offending file, so a failure names every dataset.
      final List<String> problems = <String>[];
      for (final String cc in countries) {
        final Map<String, BankEntry> entries = readSource(cc);
        final List<String> missing = <String>[
          for (final MapEntry<String, BankEntry> e in entries.entries)
            if (e.value.bic.trim().isEmpty) e.key,
        ];
        if (missing.isNotEmpty) {
          problems.add(
            '${sourcePath(cc)}: ${missing.length} of ${entries.length} '
            'entries have no BIC (e.g. ${missing.take(5).join(', ')})',
          );
        }
      }
      expect(problems, isEmpty);
    });

    // The compact asset must resolve every code exactly like the same data
    // in the original one-object-per-code JSON shape.
    for (final String cc in countries) {
      test('$cc compact asset resolves like the per-code JSON', () async {
        final Map<String, BankEntry> source = readSource(cc);
        final String legacy = jsonEncode(<String, Object>{
          for (final MapEntry<String, BankEntry> e in source.entries)
            e.key: e.value.toJson(),
        });
        final SyncBicResolver expected = await _load(legacy);
        final SyncBicResolver actual = await _load(
          File(assetPath(cc)).readAsStringSync(),
        );
        for (final String code in source.keys) {
          final Bic? want = expected.resolve(code);
          expect(want, isNotNull, reason: '$cc $code');
          expect(actual.resolve(code), want, reason: '$cc $code');
          expect(actual.resolve(code).toString(), want.toString());
        }
        expect(actual.resolve('not-a-code'), isNull);
      });
    }
  });

  group('summarizeCountry', () {
    test('is empty when nothing changed', () {
      expect(
        summarizeCountry(
          'DE',
          <String, BankEntry>{'1': postbank},
          <String, BankEntry>{'1': postbank},
        ),
        isEmpty,
      );
    });

    test('lists added, removed and changed codes', () {
      final BankEntry moved = BankEntry(
        bic: 'PBNKDEFFXXX',
        bankName: 'Postbank',
        bankShortName: 'Postbank',
        bankPostcode: '10117',
      );
      final String summary = summarizeCountry(
        'DE',
        <String, BankEntry>{'1': postbank, '2': ing},
        <String, BankEntry>{'1': moved, '3': ing},
      );
      expect(summary, contains('### DE: 1 added, 1 removed, 1 changed'));
      expect(summary, contains('- `3` INGDDEFFXXX "ING-DiBa"'));
      expect(summary, contains('- `2` INGDDEFFXXX "ING-DiBa"'));
      expect(summary, contains('- `1` bankPostcode: "10559" → "10117"'));
    });
  });
}

Bic _bicOf(BankEntry e) => Bic(
  value: e.bic,
  bankName: e.bankName,
  bankShortName: e.bankShortName,
  bankAddress: e.bankAddress,
  bankPostcode: e.bankPostcode,
  bankLocation: e.bankLocation,
);

Future<SyncBicResolver> _load(String contents) async {
  final AssetJsonResolver resolver = AssetJsonResolver(
    'fake.json',
    bundle: _StringBundle(contents),
  );
  await resolver.preload();
  return resolver.asSync()!;
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
