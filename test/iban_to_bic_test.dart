import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iban_to_bic/iban_to_bic.dart';

void main() {
  // Sync entry points require datasets to be preloaded. Do it once for the
  // whole suite so individual tests don't each pay the I/O.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
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
        <Object>['BE', '539', 16],
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
      expect((ibanToBic('DE12') as InvalidIban).reason,
          InvalidIbanReason.tooShort);
      expect(
          (ibanToBic('DE12345678901234567890123456789012345') as InvalidIban)
              .reason,
          InvalidIbanReason.tooLong);
      // Long enough to pass the length gate, but leading digits violate shape
      // (IBANs must start with two letters).
      expect((ibanToBic('1234567890ABCDEF') as InvalidIban).reason,
          InvalidIbanReason.badShape);
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
          'DE64${nbsp}5001${nbsp}0517${nbsp}9423${nbsp}8144${nbsp}35');
      expect(result, isA<BicFound>());
      expect((result as BicFound).bic.value, 'INGDDEFFXXX');
    });

    test(
        'custom spec with an out-of-range bankCodeEnd reports badShape '
        'instead of crashing', () async {
      // A malicious/wrong custom spec says the bank code lives at [4,30)
      // but the IBAN is only 20 chars long (still passes validateIban's
      // 15..34 range + shape regex). extractBankCode must NOT throw.
      final IbanToBic custom = IbanToBic(countries: <String, CountrySpec>{
        'AT': const CountrySpec(
          bankCodeStart: 4,
          bankCodeEnd: 30, // wider than any real AT IBAN (20 chars).
          resolver: _FixedResolver(Bic(
            value: 'TESTAT00',
            bankName: 'Test',
            bankShortName: 'Test',
          )),
        ),
      });
      // AT IBAN, 20 chars, checksum valid — but length 20 < bankCodeEnd 30.
      final String iban = _withValidChecksum('AT0011000' '00000000000');
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
      final IbanToBic custom = IbanToBic(countries: <String, CountrySpec>{
        'DE': const CountrySpec(
          bankCodeStart: 4,
          bankCodeEnd: 12,
          resolver: _FixedResolver(Bic(
            value: 'TESTDE00',
            bankName: 'Test Bank',
            bankShortName: 'Test',
          )),
        ),
      });
      final IbanLookupResult result =
          custom.lookupSync('DE64 5001 0517 9423 8144 35');
      expect(result, isA<BicFound>());
      expect((result as BicFound).bic.value, 'TESTDE00');
    });

    test('reports unsupported country when not registered', () async {
      final IbanToBic custom =
          IbanToBic(countries: const <String, CountrySpec>{});
      expect(await custom.lookup('DE64 5001 0517 9423 8144 35'),
          isA<UnsupportedCountry>());
    });
  });

  group('asset-backed defaults', () {
    test('async lookup works without explicit preload', () async {
      // A fresh instance — no preload() called — still resolves via async.
      final IbanToBic fresh = IbanToBic();
      final IbanLookupResult result =
          await fresh.lookup('DE64 5001 0517 9423 8144 35');
      expect((result as BicFound).bic.value, 'INGDDEFFXXX');
    });

    test('lookupSync without preload returns NotPreloaded', () {
      final IbanToBic fresh = IbanToBic();
      final IbanLookupResult result =
          fresh.lookupSync('DE64 5001 0517 9423 8144 35');
      expect(result, isA<NotPreloaded>());
      expect((result as NotPreloaded).countryCode, 'DE');
    });

    test('lookupSync works after preload', () async {
      final IbanToBic fresh = IbanToBic();
      await fresh.preload(<String>['DE']);
      final IbanLookupResult result =
          fresh.lookupSync('DE64 5001 0517 9423 8144 35');
      expect((result as BicFound).bic.value, 'INGDDEFFXXX');
    });

    test('preload tolerates unknown country codes', () async {
      final IbanToBic fresh = IbanToBic();
      await fresh.preload(<String>['ZZ', 'de']); // case-insensitive + junk
      expect(
        fresh.lookupSync('DE64 5001 0517 9423 8144 35'),
        isA<BicFound>(),
      );
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

    test('evict drops the preloaded dataset and flips lookupSync back',
        () async {
      final IbanToBic fresh = IbanToBic();
      await fresh.preload(<String>['DE']);
      expect(
        fresh.lookupSync('DE64 5001 0517 9423 8144 35'),
        isA<BicFound>(),
      );

      fresh.evict('DE');
      final IbanLookupResult afterEvict =
          fresh.lookupSync('DE64 5001 0517 9423 8144 35');
      expect(afterEvict, isA<NotPreloaded>());
      expect((afterEvict as NotPreloaded).countryCode, 'DE');

      // Async path still serves it; it just re-reads the asset.
      final IbanLookupResult asyncResult =
          await fresh.lookup('DE64 5001 0517 9423 8144 35');
      expect((asyncResult as BicFound).bic.value, 'INGDDEFFXXX');

      // Preloading again restores the sync fast path.
      await fresh.preload(<String>['DE']);
      expect(
        fresh.lookupSync('DE64 5001 0517 9423 8144 35'),
        isA<BicFound>(),
      );
    });

    test('constructor copies the injected countries map defensively', () {
      final Map<String, CountrySpec> external = <String, CountrySpec>{
        'DE': const CountrySpec(
          bankCodeStart: 4,
          bankCodeEnd: 12,
          resolver: _FixedResolver(Bic(
            value: 'BEFOREXX',
            bankName: 'Before',
            bankShortName: 'Before',
          )),
        ),
      };
      final IbanToBic custom = IbanToBic(countries: external);

      // Mutate the caller's map *after* construction — must not bleed in.
      external['DE'] = const CountrySpec(
        bankCodeStart: 4,
        bankCodeEnd: 12,
        resolver: _FixedResolver(Bic(
          value: 'AFTERXXX',
          bankName: 'After',
          bankShortName: 'After',
        )),
      );
      external.remove('DE');

      final IbanLookupResult result =
          custom.lookupSync('DE64 5001 0517 9423 8144 35');
      expect((result as BicFound).bic.value, 'BEFOREXX');
    });

    test('evict is a no-op for unknown, non-asset, and never-loaded countries',
        () {
      final IbanToBic fresh = IbanToBic();
      // Unknown country.
      fresh.evict('ZZ');
      // Case-insensitive + never preloaded — still a no-op, no throw.
      fresh.evict('de');

      final IbanToBic custom = IbanToBic(countries: <String, CountrySpec>{
        'DE': const CountrySpec(
          bankCodeStart: 4,
          bankCodeEnd: 12,
          resolver: _FixedResolver(Bic(
            value: 'TESTDE00',
            bankName: 'Test Bank',
            bankShortName: 'Test',
          )),
        ),
      });
      // Custom sync resolver is not asset-backed — evict must leave it alone.
      custom.evict('DE');
      final IbanLookupResult result =
          custom.lookupSync('DE64 5001 0517 9423 8144 35');
      expect((result as BicFound).bic.value, 'TESTDE00');
    });
  });

  group('AssetJsonResolver error handling', () {
    test('transient load error does not latch a rejected future', () async {
      final _FlakyBundle bundle = _FlakyBundle();
      final AssetJsonResolver resolver = AssetJsonResolver(
        'fake/path.json',
        bundle: bundle,
      );

      bundle.mode = _FlakyMode.fail;
      await expectLater(resolver.resolve('anything'), throwsStateError);

      // Without the whenComplete-style reset, this second call would
      // re-await the same rejected future and throw the original error.
      bundle.mode = _FlakyMode.succeed;
      final Bic? bic = await resolver.resolve('10010010');
      expect(bic, isNotNull);
      expect(bic!.value, 'PBNKDEFFXXX');
      expect(bundle.calls, 2, reason: 'should have retried the asset load');
    });
  });

  group('async resolver', () {
    test('ibanToBicAsync works for built-in data', () async {
      final IbanLookupResult result =
          await ibanToBicAsync('DE64 5001 0517 9423 8144 35');
      expect((result as BicFound).bic.value, 'INGDDEFFXXX');
    });

    test('async resolver is awaited by lookup()', () async {
      final IbanToBic custom = IbanToBic(countries: <String, CountrySpec>{
        'DE': const CountrySpec(
          bankCodeStart: 4,
          bankCodeEnd: 12,
          resolver: _AsyncResolver(),
        ),
      });
      final IbanLookupResult result =
          await custom.lookup('DE64 5001 0517 9423 8144 35');
      expect((result as BicFound).bic.value, 'ASYNCDE00');
    });

    test('lookupSync returns NotPreloaded when resolver is async', () {
      final IbanToBic custom = IbanToBic(countries: <String, CountrySpec>{
        'DE': const CountrySpec(
          bankCodeStart: 4,
          bankCodeEnd: 12,
          resolver: _AsyncResolver(),
        ),
      });
      expect(
        custom.lookupSync('DE64 5001 0517 9423 8144 35'),
        isA<NotPreloaded>(),
      );
    });

    test('lookupSync still short-circuits invalid input synchronously', () {
      final IbanToBic custom = IbanToBic(countries: <String, CountrySpec>{
        'DE': const CountrySpec(
          bankCodeStart: 4,
          bankCodeEnd: 12,
          resolver: _AsyncResolver(),
        ),
      });
      // Bad checksum — never reaches the resolver, so no throw.
      expect(
          custom.lookupSync('DE00 5001 0517 9423 8144 35'), isA<InvalidIban>());
    });
  });
}

enum _FlakyMode { fail, succeed }

// Non-caching bundle — CachingAssetBundle would latch the first rejected
// future, which defeats the test. We want AssetJsonResolver's own retry
// logic to be the only thing under test.
class _FlakyBundle extends AssetBundle {
  _FlakyMode mode = _FlakyMode.succeed;
  int calls = 0;

  static const String _successJson =
      '{"10010010":{"bic":"PBNKDEFFXXX","bankName":"Postbank",'
      '"bankShortName":"Postbank"}}';

  @override
  Future<ByteData> load(String key) async {
    calls++;
    if (mode == _FlakyMode.fail) {
      throw StateError('simulated asset load failure');
    }
    final Uint8List bytes = Uint8List.fromList(utf8.encode(_successJson));
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final ByteData data = await load(key);
    return utf8.decode(data.buffer.asUint8List());
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
