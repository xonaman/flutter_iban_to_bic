import 'dart:convert';

import 'package:iban_to_bic/iban_to_bic.dart';
import 'package:iban_to_bic/src/data/bank_codes.dart';
import 'package:test/test.dart';

void main() {
  // Sync entry points require datasets to be preloaded. Do it once for the
  // whole suite so individual tests don't each pay the I/O.
  setUpAll(() async {
    await preloadIbanToBic(sharedIbanToBic.supportedCountries);
  });

  group('ibanToBic', () {
    test('resolves a German IBAN to the expected BIC', () {
      final IbanLookupResult result = ibanToBic('DE64 5001 0517 9423 8144 35');
      expect(result, isA<BicFound>());
      final Bic bic = (result as BicFound).bic;
      expect(bic.value, 'INGDDEFFXXX');
      expect(bic.bankName, 'ING-DiBa');
    });

    test('resolves across every built-in country', () {
      // (countryCode, known bank code, total IBAN length) — bank codes are
      // taken from the actual built-in datasets so the lookup must succeed.
      const List<List<Object>> cases = <List<Object>>[
        <Object>['AT', '11000', 20],
        <Object>['BE', '310', 16],
        <Object>['DE', '50010517', 22],
        <Object>['ES', '2100', 24],
        <Object>['FR', '20041', 27],
        <Object>['LT', '30300', 20],
        <Object>['LU', '001', 20],
        <Object>['NL', 'ABNA', 18],
      ];
      for (final List<Object> row in cases) {
        final String country = row[0] as String;
        final String bank = row[1] as String;
        final int length = row[2] as int;
        final String iban = _buildValidIban(country, bank, length);
        final IbanLookupResult result = ibanToBic(iban);
        expect(result, isA<BicFound>(), reason: 'country $country ($iban)');
      }
    });

    test('rejects invalid checksum with a specific reason', () {
      final IbanLookupResult result = ibanToBic('DE00 5001 0517 9423 8144 35');
      expect(result, isA<InvalidIban>());
      expect((result as InvalidIban).reason, InvalidIbanReason.badChecksum);
    });

    test('classifies junk input with specific reasons', () {
      expect((ibanToBic('') as InvalidIban).reason, InvalidIbanReason.empty);
      expect(
        (ibanToBic('DE12') as InvalidIban).reason,
        InvalidIbanReason.tooShort,
      );
      expect(
        (ibanToBic('DE12345678901234567890123456789012345') as InvalidIban)
            .reason,
        InvalidIbanReason.tooLong,
      );
      // Long enough to pass the length gate, but leading digits violate shape
      // (IBANs must start with two letters).
      expect(
        (ibanToBic('1234567890ABCDEF') as InvalidIban).reason,
        InvalidIbanReason.badShape,
      );
    });

    test('flags unsupported country', () {
      final IbanLookupResult result = ibanToBic('GB82 WEST 1234 5698 7654 32');
      expect(result, isA<UnsupportedCountry>());
      expect((result as UnsupportedCountry).countryCode, 'GB');
    });

    test('flags unknown bank code', () {
      final String valid = _withValidChecksum('NL00ZZZZ0123456789');
      final IbanLookupResult result = ibanToBic(valid);
      expect(result, isA<UnknownBank>());
      final UnknownBank unknown = result as UnknownBank;
      expect(unknown.countryCode, 'NL');
      expect(unknown.bankCode, 'ZZZZ');
    });

    test('tolerates whitespace and lower-case input', () {
      final IbanLookupResult a = ibanToBic('de64 5001 0517 9423 8144 35');
      final IbanLookupResult b = ibanToBic('DE64500105179423814435');
      expect(a, isA<BicFound>());
      expect(b, isA<BicFound>());
      expect((a as BicFound).bic.value, (b as BicFound).bic.value);
    });

    test('tolerates non-breaking spaces (pasted from bank PDFs)', () {
      const String nbsp = ' ';
      final IbanLookupResult result = ibanToBic(
        'DE64${nbsp}5001${nbsp}0517${nbsp}9423${nbsp}8144${nbsp}35',
      );
      expect(result, isA<BicFound>());
      expect((result as BicFound).bic.value, 'INGDDEFFXXX');
    });

    test('custom spec with an out-of-range bankCodeEnd reports badShape '
        'instead of crashing', () async {
      // A malicious/wrong custom spec says the bank code lives at [4,30)
      // but the IBAN is only 20 chars long (still passes validateIban's
      // 15..34 range + shape regex). extractBankCode must NOT throw.
      final IbanToBic custom = IbanToBic(
        countries: <String, CountrySpec>{
          'AT': const CountrySpec(
            bankCodeStart: 4,
            bankCodeEnd: 30, // wider than any real AT IBAN (20 chars).
            resolver: _FixedResolver(
              Bic(value: 'TESTAT00', bankName: 'Test', bankShortName: 'Test'),
            ),
          ),
        },
      );
      // AT IBAN, 20 chars, checksum valid — but length 20 < bankCodeEnd 30.
      final String iban = _withValidChecksum(
        'AT0011000'
        '00000000000',
      );
      final IbanLookupResult result = await custom.lookup(iban);
      expect(result, isA<InvalidIban>());
      expect((result as InvalidIban).reason, InvalidIbanReason.badShape);
    });
  });

  group('Bic structural getters', () {
    test('parses an 11-char BIC into its ISO 9362 parts', () {
      const Bic bic = Bic(
        value: 'INGDDEFFXXX',
        bankName: 'ING-DiBa',
        bankShortName: 'ING-DiBa',
      );
      expect(bic.institutionCode, 'INGD');
      expect(bic.countryCode, 'DE');
      expect(bic.locationCode, 'FF');
      expect(bic.branchCode, 'XXX');
      expect(bic.isWellFormed, isTrue);
    });

    test('treats 8-char BIC as having no branch code', () {
      const Bic bic = Bic(
        value: 'ABNANL2A',
        bankName: 'ABN AMRO BANK',
        bankShortName: 'ABN AMRO',
      );
      expect(bic.institutionCode, 'ABNA');
      expect(bic.countryCode, 'NL');
      expect(bic.locationCode, '2A');
      expect(bic.branchCode, isNull);
      expect(bic.isWellFormed, isTrue);
    });

    test('flags malformed values as not well-formed', () {
      const Bic bic = Bic(
        value: '',
        bankName: 'Unknown',
        bankShortName: 'Unknown',
      );
      expect(bic.isWellFormed, isFalse);
      expect(bic.institutionCode, '');
      expect(bic.branchCode, isNull);
    });
  });

  group('IbanToBic (custom)', () {
    test('custom sync resolver overrides the built-in data', () {
      final IbanToBic custom = IbanToBic(
        countries: <String, CountrySpec>{
          'DE': const CountrySpec(
            bankCodeStart: 4,
            bankCodeEnd: 12,
            resolver: _FixedResolver(
              Bic(
                value: 'TESTDE00',
                bankName: 'Test Bank',
                bankShortName: 'Test',
              ),
            ),
          ),
        },
      );
      final IbanLookupResult result = custom.lookupSync(
        'DE64 5001 0517 9423 8144 35',
      );
      expect(result, isA<BicFound>());
      expect((result as BicFound).bic.value, 'TESTDE00');
    });

    test('reports unsupported country when not registered', () async {
      final IbanToBic custom = IbanToBic(
        countries: const <String, CountrySpec>{},
      );
      expect(
        await custom.lookup('DE64 5001 0517 9423 8144 35'),
        isA<UnsupportedCountry>(),
      );
    });
  });

  group('asset-backed defaults', () {
    test('async lookup works without explicit preload', () async {
      // A fresh instance — no preload() called — still resolves via async.
      final IbanToBic fresh = IbanToBic();
      final IbanLookupResult result = await fresh.lookup(
        'DE64 5001 0517 9423 8144 35',
      );
      expect((result as BicFound).bic.value, 'INGDDEFFXXX');
    });

    test('lookupSync without preload returns NotPreloaded', () {
      final IbanToBic fresh = IbanToBic();
      final IbanLookupResult result = fresh.lookupSync(
        'DE64 5001 0517 9423 8144 35',
      );
      expect(result, isA<NotPreloaded>());
      expect((result as NotPreloaded).countryCode, 'DE');
    });

    test('lookupSync works after preload', () async {
      final IbanToBic fresh = IbanToBic();
      await fresh.preload(<String>['DE']);
      final IbanLookupResult result = fresh.lookupSync(
        'DE64 5001 0517 9423 8144 35',
      );
      expect((result as BicFound).bic.value, 'INGDDEFFXXX');
    });

    test('preload tolerates unknown country codes', () async {
      final IbanToBic fresh = IbanToBic();
      await fresh.preload(<String>['ZZ', 'de']); // case-insensitive + junk
      expect(fresh.lookupSync('DE64 5001 0517 9423 8144 35'), isA<BicFound>());
    });

    test('repeated preload on the same country is a cheap no-op', () async {
      final IbanToBic fresh = IbanToBic();
      await fresh.preload(<String>['DE']);
      final Bic first =
          (fresh.lookupSync('DE64 5001 0517 9423 8144 35') as BicFound).bic;
      await fresh.preload(<String>['DE']);
      await fresh.preload(<String>['de']); // case-insensitive dup too
      final Bic second =
          (fresh.lookupSync('DE64 5001 0517 9423 8144 35') as BicFound).bic;
      // Map is reused — same Bic instance, no churn from redundant preloads.
      expect(identical(first, second), isTrue);
    });

    test(
      'evict drops the preloaded dataset and flips lookupSync back',
      () async {
        final IbanToBic fresh = IbanToBic();
        await fresh.preload(<String>['DE']);
        expect(
          fresh.lookupSync('DE64 5001 0517 9423 8144 35'),
          isA<BicFound>(),
        );

        fresh.evict('DE');
        final IbanLookupResult afterEvict = fresh.lookupSync(
          'DE64 5001 0517 9423 8144 35',
        );
        expect(afterEvict, isA<NotPreloaded>());
        expect((afterEvict as NotPreloaded).countryCode, 'DE');

        // Async path still serves it; it just re-reads the asset.
        final IbanLookupResult asyncResult = await fresh.lookup(
          'DE64 5001 0517 9423 8144 35',
        );
        expect((asyncResult as BicFound).bic.value, 'INGDDEFFXXX');

        // Preloading again restores the sync fast path.
        await fresh.preload(<String>['DE']);
        expect(
          fresh.lookupSync('DE64 5001 0517 9423 8144 35'),
          isA<BicFound>(),
        );
      },
    );

    test('constructor copies the injected countries map defensively', () {
      final Map<String, CountrySpec> external = <String, CountrySpec>{
        'DE': const CountrySpec(
          bankCodeStart: 4,
          bankCodeEnd: 12,
          resolver: _FixedResolver(
            Bic(value: 'BEFOREXX', bankName: 'Before', bankShortName: 'Before'),
          ),
        ),
      };
      final IbanToBic custom = IbanToBic(countries: external);

      // Mutate the caller's map *after* construction — must not bleed in.
      external['DE'] = const CountrySpec(
        bankCodeStart: 4,
        bankCodeEnd: 12,
        resolver: _FixedResolver(
          Bic(value: 'AFTERXXX', bankName: 'After', bankShortName: 'After'),
        ),
      );
      external.remove('DE');

      final IbanLookupResult result = custom.lookupSync(
        'DE64 5001 0517 9423 8144 35',
      );
      expect((result as BicFound).bic.value, 'BEFOREXX');
    });

    test(
      'evict is a no-op for unknown, non-asset, and never-loaded countries',
      () {
        final IbanToBic fresh = IbanToBic();
        // Unknown country.
        fresh.evict('ZZ');
        // Case-insensitive + never preloaded — still a no-op, no throw.
        fresh.evict('de');

        final IbanToBic custom = IbanToBic(
          countries: <String, CountrySpec>{
            'DE': const CountrySpec(
              bankCodeStart: 4,
              bankCodeEnd: 12,
              resolver: _FixedResolver(
                Bic(
                  value: 'TESTDE00',
                  bankName: 'Test Bank',
                  bankShortName: 'Test',
                ),
              ),
            ),
          },
        );
        // Custom sync resolver is not asset-backed — evict must leave it alone.
        custom.evict('DE');
        final IbanLookupResult result = custom.lookupSync(
          'DE64 5001 0517 9423 8144 35',
        );
        expect((result as BicFound).bic.value, 'TESTDE00');
      },
    );
  });

  group('LazyJsonResolver error handling', () {
    test('transient load error does not latch a rejected future', () async {
      final _FlakyLoader loader = _FlakyLoader();
      final LazyJsonResolver resolver = LazyJsonResolver(loader.load);

      loader.mode = _FlakyMode.fail;
      await expectLater(resolver.resolve('anything'), throwsStateError);

      // Without the whenComplete-style reset, this second call would
      // re-await the same rejected future and throw the original error.
      loader.mode = _FlakyMode.succeed;
      final Bic? bic = await resolver.resolve('10010010');
      expect(bic, isNotNull);
      expect(bic!.value, 'PBNKDEFFXXX');
      expect(loader.calls, 2, reason: 'should have retried the load');
    });
  });

  group('LazyJsonResolver rows without a BIC', () {
    // Mirrors the shape of real dataset rows that carry a bank name but
    // no BIC, plus a whitespace-only BIC and one valid row as a control.
    const String rows =
        '{'
        '"50010517":{"bic":"","bankName":"ING-DiBa","bankShortName":"ING"},'
        '"12030000":{"bic":"   ","bankName":"DKB","bankShortName":"DKB"},'
        '"10010010":{"bic":"PBNKDEFFXXX","bankName":"Postbank",'
        '"bankShortName":"Postbank"}'
        '}';

    IbanToBic withRows() => IbanToBic(
      countries: <String, CountrySpec>{
        'DE': CountrySpec(
          bankCodeStart: 4,
          bankCodeEnd: 12,
          resolver: LazyJsonResolver(() async => rows),
        ),
      },
    );

    final String emptyBic = _buildValidIban('DE', '50010517', 22);
    final String blankBic = _buildValidIban('DE', '12030000', 22);
    final String validBic = _buildValidIban('DE', '10010010', 22);

    test('lookup reports UnknownBank', () async {
      final IbanToBic custom = withRows();
      for (final String iban in <String>[emptyBic, blankBic]) {
        final IbanLookupResult result = await custom.lookup(iban);
        expect(result, isA<UnknownBank>(), reason: iban);
      }
      final IbanLookupResult control = await custom.lookup(validBic);
      expect((control as BicFound).bic.value, 'PBNKDEFFXXX');
    });

    test('lookupSync reports UnknownBank after preload', () async {
      final IbanToBic custom = withRows();
      await custom.preload(<String>['DE']);
      for (final String iban in <String>[emptyBic, blankBic]) {
        expect(custom.lookupSync(iban), isA<UnknownBank>(), reason: iban);
      }
      final IbanLookupResult control = custom.lookupSync(validBic);
      expect((control as BicFound).bic.value, 'PBNKDEFFXXX');
    });
  });

  group('BIC accuracy', () {
    const Map<String, BicAccuracy> expected = <String, BicAccuracy>{
      'AT': BicAccuracy.exact,
      'BE': BicAccuracy.exact,
      'DE': BicAccuracy.exact,
      'ES': BicAccuracy.institution,
      'FR': BicAccuracy.institution,
      'LT': BicAccuracy.exact,
      'LU': BicAccuracy.exact,
      'NL': BicAccuracy.exact,
    };

    test('every built-in country declares the documented accuracy', () {
      expect(sharedIbanToBic.supportedCountries.toSet(), expected.keys.toSet());
    });

    test('sync and async results carry the country accuracy', () async {
      const Map<String, List<Object>> cases = <String, List<Object>>{
        'AT': <Object>['11000', 20],
        'BE': <Object>['310', 16],
        'DE': <Object>['50010517', 22],
        'ES': <Object>['2100', 24],
        'FR': <Object>['20041', 27],
        'LT': <Object>['30300', 20],
        'LU': <Object>['001', 20],
        'NL': <Object>['ABNA', 18],
      };
      final IbanToBic fresh = IbanToBic();
      for (final MapEntry<String, List<Object>> c in cases.entries) {
        final String iban = _buildValidIban(
          c.key,
          c.value[0] as String,
          c.value[1] as int,
        );
        final BicFound viaAsync = await fresh.lookup(iban) as BicFound;
        expect(viaAsync.accuracy, expected[c.key], reason: '${c.key} async');
        expect(viaAsync.isExact, expected[c.key] == BicAccuracy.exact);

        // preload swaps in a sync spec; accuracy must survive the swap.
        final BicFound viaSync = ibanToBic(iban) as BicFound;
        expect(viaSync.accuracy, expected[c.key], reason: '${c.key} sync');
      }
    });

    test('accuracy survives evict and re-preload', () async {
      final IbanToBic fresh = IbanToBic();
      final String iban = _buildValidIban('FR', '20041', 27);
      await fresh.preload(<String>['FR']);
      fresh.evict('FR');
      expect((await fresh.lookup(iban) as BicFound).isExact, isFalse);
      await fresh.preload(<String>['FR']);
      expect(
        (fresh.lookupSync(iban) as BicFound).accuracy,
        BicAccuracy.institution,
      );
    });

    test('custom specs default to exact and can opt into institution', () {
      const Bic bic = Bic(
        value: 'TESTDE00',
        bankName: 'Test',
        bankShortName: 'Test',
      );
      const String iban = 'DE64 5001 0517 9423 8144 35';
      final IbanToBic byDefault = IbanToBic(
        countries: <String, CountrySpec>{
          'DE': const CountrySpec(
            bankCodeStart: 4,
            bankCodeEnd: 12,
            resolver: _FixedResolver(bic),
          ),
        },
      );
      expect((byDefault.lookupSync(iban) as BicFound).isExact, isTrue);

      final IbanToBic institution = IbanToBic(
        countries: <String, CountrySpec>{
          'DE': const CountrySpec(
            bankCodeStart: 4,
            bankCodeEnd: 12,
            resolver: _FixedResolver(bic),
            accuracy: BicAccuracy.institution,
          ),
        },
      );
      expect(
        (institution.lookupSync(iban) as BicFound).accuracy,
        BicAccuracy.institution,
      );
    });

    test('BicFound defaults to exact for source compatibility', () {
      const BicFound found = BicFound(
        Bic(value: 'TESTDE00', bankName: 'Test', bankShortName: 'Test'),
      );
      expect(found.accuracy, BicAccuracy.exact);
      expect(found.isExact, isTrue);
    });
  });

  group('bundled datasets', () {
    // Runs on every platform, so on the web it also exercises the deferred
    // per-country loading. Content checks live in bank_codes_test.dart.
    test('every supported country has a non-empty dataset', () async {
      for (final String cc in sharedIbanToBic.supportedCountries) {
        final Map<String, dynamic> decoded =
            json.decode(await loadBankCodesJson(cc)) as Map<String, dynamic>;
        expect(decoded['banks'], isNotEmpty, reason: cc);
      }
    });

    test('unknown country has no dataset', () {
      expect(loadBankCodesJson('GB'), throwsArgumentError);
    });
  });

  group('AssetJsonResolver (deprecated)', () {
    const String json =
        '{"10010010":{"bic":"PBNKDEFFXXX","bankName":"Postbank",'
        '"bankShortName":"Postbank"}}';

    test('loads through any bundle with loadString', () async {
      final _FakeBundle bundle = _FakeBundle(json);
      // ignore: deprecated_member_use_from_same_package
      final AssetJsonResolver resolver = AssetJsonResolver(
        'assets/de.json',
        bundle: bundle,
      );
      expect(resolver, isA<LazyJsonResolver>());
      expect((await resolver.resolve('10010010'))!.value, 'PBNKDEFFXXX');
      expect(bundle.keys, <String>['assets/de.json']);
    });

    test('without a bundle, loading fails with a StateError', () async {
      // ignore: deprecated_member_use_from_same_package
      final AssetJsonResolver resolver = AssetJsonResolver('assets/de.json');
      await expectLater(resolver.resolve('10010010'), throwsStateError);
    });
  });

  group('async resolver', () {
    test('ibanToBicAsync works for built-in data', () async {
      final IbanLookupResult result = await ibanToBicAsync(
        'DE64 5001 0517 9423 8144 35',
      );
      expect((result as BicFound).bic.value, 'INGDDEFFXXX');
    });

    test('async resolver is awaited by lookup()', () async {
      final IbanToBic custom = IbanToBic(
        countries: <String, CountrySpec>{
          'DE': const CountrySpec(
            bankCodeStart: 4,
            bankCodeEnd: 12,
            resolver: _AsyncResolver(),
          ),
        },
      );
      final IbanLookupResult result = await custom.lookup(
        'DE64 5001 0517 9423 8144 35',
      );
      expect((result as BicFound).bic.value, 'ASYNCDE00');
    });

    test('lookupSync returns NotPreloaded when resolver is async', () {
      final IbanToBic custom = IbanToBic(
        countries: <String, CountrySpec>{
          'DE': const CountrySpec(
            bankCodeStart: 4,
            bankCodeEnd: 12,
            resolver: _AsyncResolver(),
          ),
        },
      );
      expect(
        custom.lookupSync('DE64 5001 0517 9423 8144 35'),
        isA<NotPreloaded>(),
      );
    });

    test('lookupSync still short-circuits invalid input synchronously', () {
      final IbanToBic custom = IbanToBic(
        countries: <String, CountrySpec>{
          'DE': const CountrySpec(
            bankCodeStart: 4,
            bankCodeEnd: 12,
            resolver: _AsyncResolver(),
          ),
        },
      );
      // Bad checksum — never reaches the resolver, so no throw.
      expect(
        custom.lookupSync('DE00 5001 0517 9423 8144 35'),
        isA<InvalidIban>(),
      );
    });
  });
}

enum _FlakyMode { fail, succeed }

// Fails or succeeds on demand and counts calls, so the test can check
// that LazyJsonResolver retries after a failed load.
class _FlakyLoader {
  _FlakyMode mode = _FlakyMode.succeed;
  int calls = 0;

  static const String _successJson =
      '{"10010010":{"bic":"PBNKDEFFXXX","bankName":"Postbank",'
      '"bankShortName":"Postbank"}}';

  Future<String> load() async {
    calls++;
    if (mode == _FlakyMode.fail) {
      throw StateError('simulated load failure');
    }
    return _successJson;
  }
}

// Stands in for a Flutter AssetBundle: AssetJsonResolver only needs
// loadString.
class _FakeBundle {
  _FakeBundle(this.contents);
  final String contents;
  final List<String> keys = <String>[];

  Future<String> loadString(String key, {bool cache = true}) async {
    keys.add(key);
    return contents;
  }
}

class _AsyncResolver implements BicResolver {
  const _AsyncResolver();
  @override
  Future<Bic?> resolve(String bankCode) async {
    await Future<void>.delayed(Duration.zero);
    return const Bic(
      value: 'ASYNCDE00',
      bankName: 'Async Bank',
      bankShortName: 'Async',
    );
  }
}

class _FixedResolver implements SyncBicResolver {
  final Bic bic;
  const _FixedResolver(this.bic);
  @override
  Bic? resolve(String bankCode) => bic;
}

/// Builds an IBAN of [totalLength] that starts with [country] + valid check
/// digits + [bankCode], padded with zeros.
String _buildValidIban(String country, String bankCode, int totalLength) {
  final String padded = bankCode.padRight(totalLength - 4, '0');
  return _withValidChecksum('${country}00$padded');
}

String _withValidChecksum(String iban) {
  final String body = '${iban.substring(0, 2)}00${iban.substring(4)}';
  final String rearranged = body.substring(4) + body.substring(0, 4);
  int remainder = 0;
  for (final int c in rearranged.codeUnits) {
    final int v = (c >= 0x30 && c <= 0x39) ? c - 0x30 : c - 0x41 + 10;
    remainder = v < 10 ? (remainder * 10 + v) % 97 : (remainder * 100 + v) % 97;
  }
  final String check = (98 - remainder).toString().padLeft(2, '0');
  return '${iban.substring(0, 2)}$check${iban.substring(4)}';
}
