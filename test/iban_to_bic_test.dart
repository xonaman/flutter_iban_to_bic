import 'package:flutter_test/flutter_test.dart';
import 'package:iban_to_bic/iban_to_bic.dart';

void main() {
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

    test('rejects invalid checksum', () {
      final IbanLookupResult result = ibanToBic('DE00 5001 0517 9423 8144 35');
      expect(result, isA<InvalidIban>());
    });

    test('rejects junk input', () {
      expect(ibanToBic(''), isA<InvalidIban>());
      expect(ibanToBic('not an iban'), isA<InvalidIban>());
      expect(ibanToBic('DE12'), isA<InvalidIban>());
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
  });

  group('IbanToBic (custom)', () {
    test('custom resolver overrides the built-in data', () {
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
          custom.lookup('DE64 5001 0517 9423 8144 35');
      expect(result, isA<BicFound>());
      expect((result as BicFound).bic.value, 'TESTDE00');
    });

    test('reports unsupported country when not registered', () {
      final IbanToBic custom =
          IbanToBic(countries: const <String, CountrySpec>{});
      expect(custom.lookup('DE64 5001 0517 9423 8144 35'),
          isA<UnsupportedCountry>());
    });
  });
}

class _FixedResolver implements BicResolver {
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
