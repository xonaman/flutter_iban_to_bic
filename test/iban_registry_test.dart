import 'package:flutter_test/flutter_test.dart';
import 'package:iban_to_bic/iban_to_bic.dart';
import 'package:iban_to_bic/src/iban.dart';
import 'package:iban_to_bic/src/iban_registry.dart';
import 'package:iban_to_bic/src/iban_to_bic.dart' show buildDefaultCountries;

void main() {
  group('ibanRegistry', () {
    // Copied by hand from the SWIFT IBAN Registry (IBAN length, then the
    // bank identifier's 1-based position within the BBAN), so a regenerated
    // table that moves a supported country's bank code fails here.
    const Map<String, (int, int, int)> registry = <String, (int, int, int)>{
      'AT': (20, 1, 5),
      'BE': (16, 1, 3),
      'DE': (22, 1, 8),
      'ES': (24, 1, 4),
      'FR': (27, 1, 5),
      'LT': (20, 1, 5),
      'LU': (20, 1, 3),
      'NL': (18, 1, 4),
    };

    test('matches the registry for every supported country', () {
      for (final MapEntry<String, (int, int, int)> e in registry.entries) {
        final IbanRegistryEntry entry = ibanRegistry[e.key]!;
        final (int length, int from, int to) = e.value;
        expect(entry.ibanLength, length, reason: e.key);
        expect(entry.bankCodeStart, from + 3, reason: e.key);
        expect(entry.bankCodeEnd, to + 4, reason: e.key);
      }
    });

    test('built-in country specs are derived from it', () {
      final Map<String, CountrySpec> specs = buildDefaultCountries();
      expect(specs.keys, unorderedEquals(registry.keys));
      for (final MapEntry<String, CountrySpec> e in specs.entries) {
        final IbanRegistryEntry entry = ibanRegistry[e.key]!;
        expect(e.value.bankCodeStart, entry.bankCodeStart, reason: e.key);
        expect(e.value.bankCodeEnd, entry.bankCodeEnd, reason: e.key);
        expect(
          e.value.accuracy,
          e.key == 'ES' || e.key == 'FR'
              ? BicAccuracy.institution
              : BicAccuracy.exact,
          reason: e.key,
        );
      }
      expect(IbanToBic().supportedCountries, unorderedEquals(registry.keys));
    });

    test('every entry is self-consistent and its example validates', () {
      expect(ibanRegistry.length, greaterThanOrEqualTo(89));
      for (final MapEntry<String, IbanRegistryEntry> e
          in ibanRegistry.entries) {
        final IbanRegistryEntry entry = e.value;
        expect(entry.example.length, entry.ibanLength, reason: e.key);
        expect(entry.example.substring(0, 2), e.key);
        expect(entry.bankCodeStart, greaterThanOrEqualTo(4), reason: e.key);
        expect(entry.bankCodeEnd, greaterThan(entry.bankCodeStart));
        expect(entry.bankCodeEnd, lessThanOrEqualTo(entry.ibanLength));
        expect(validateIban(entry.example), isA<IbanOk>(), reason: e.key);
      }
    });
  });

  group('IbanRegistryEntry.matchesBban', () {
    const IbanRegistryEntry nl = IbanRegistryEntry(
      ibanLength: 18,
      bbanFormat: '4!a10!n',
      bankCodeStart: 4,
      bankCodeEnd: 8,
      example: 'NL91ABNA0417164300',
    );

    test('accepts the format and rejects wrong classes or lengths', () {
      expect(nl.matchesBban('ABNA0417164300'), isTrue);
      expect(nl.matchesBban('AB1A0417164300'), isFalse);
      expect(nl.matchesBban('ABNA041716430X'), isFalse);
      expect(nl.matchesBban('ABNA041716430'), isFalse);
      expect(nl.matchesBban('ABNA04171643000'), isFalse);
    });

    test('c accepts letters and digits', () {
      const IbanRegistryEntry lu = IbanRegistryEntry(
        ibanLength: 20,
        bbanFormat: '3!n13!c',
        bankCodeStart: 4,
        bankCodeEnd: 7,
        example: 'LU280019400644750000',
      );
      expect(lu.matchesBban('001ABC4006447500'), isTrue);
      expect(lu.matchesBban('00A9400644750000'), isFalse);
    });
  });

  group('per-country validation', () {
    final IbanToBic resolver = IbanToBic();

    InvalidIbanReason? reasonOf(String iban) {
      final IbanLookupResult result = resolver.lookupSync(iban);
      return result is InvalidIban ? result.reason : null;
    }

    test('rejects a supported country IBAN that is one char too long or '
        'short', () {
      for (final String cc in resolver.supportedCountries) {
        final String example = ibanRegistry[cc]!.example;
        final String body = example.substring(4);
        final String longer = _withValidChecksum('${cc}00${body}0');
        final String shorter = _withValidChecksum(
          '${cc}00${body.substring(0, body.length - 1)}',
        );
        expect(reasonOf(longer), InvalidIbanReason.tooLong, reason: longer);
        expect(reasonOf(shorter), InvalidIbanReason.tooShort, reason: shorter);
      }
    });

    test('rejects a German IBAN with 21 characters', () {
      // DE IBANs are 22 characters; this one has a valid mod-97 checksum,
      // so only the registry length catches it.
      final String iban = _withValidChecksum('DE0037040044053201300');
      expect(iban.length, 21);
      expect(reasonOf(iban), InvalidIbanReason.tooShort);
    });

    test('rejects a BBAN that breaks the country format', () {
      // NL bank codes are four letters; DE BBANs are all digits.
      expect(
        reasonOf(_withValidChecksum('NL00AB1A0417164300')),
        InvalidIbanReason.badShape,
      );
      expect(
        reasonOf(_withValidChecksum('DE0037040044053201300X')),
        InvalidIbanReason.badShape,
      );
    });

    test('countries missing from the registry keep the generic rules', () {
      // `ZZ` isn't a registered IBAN country, so any 15..34 length passes.
      expect(
        validateIban(_withValidChecksum('ZZ001234567890123')),
        isA<IbanOk>(),
      );
    });
  });
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
