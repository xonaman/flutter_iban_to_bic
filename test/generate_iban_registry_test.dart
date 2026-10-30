@TestOn('vm')
library;

import 'package:test/test.dart';

import '../tool/generate_iban_registry.dart';

void main() {
  group('parseTsv', () {
    test('handles quoted cells with tabs, newlines and doubled quotes', () {
      final List<List<String>> rows = parseTsv(
        'a\t"x\ty"\tb\r\n'
        'c\t"line 1\nline 2 ""q"""\r\n'
        'd',
      );
      expect(rows, <List<String>>[
        <String>['a', 'x\ty', 'b'],
        <String>['c', 'line 1\nline 2 "q"'],
        <String>['d'],
      ]);
    });
  });

  group('parseIbanRegistry', () {
    test('reads lengths, formats and positions per country', () {
      final List<RegistryCountry> countries = parseIbanRegistry(_registry());
      expect(countries.map((RegistryCountry c) => c.countryCode), <String>[
        'CZ',
        'DE',
        'IT',
      ]);

      final RegistryCountry cz = countries[0];
      // The IBAN structure row is more detailed than the BBAN row.
      expect(cz.bbanFormat, '4!n6!n10!n');
      expect(cz.ibanLength, 24);

      final RegistryCountry de = countries[1];
      expect(de.bbanFormat, '8!n10!n');
      expect((de.bankIdFrom, de.bankIdTo), (1, 8));
      expect(de.branchIdFrom, isNull);

      final RegistryCountry it = countries[2];
      expect((it.bankIdFrom, it.bankIdTo), (2, 6));
      expect((it.branchIdFrom, it.branchIdTo), (7, 11));
    });

    test('renders 0-based IBAN offsets', () {
      final String out = renderIbanRegistry(parseIbanRegistry(_registry()));
      expect(out, contains('3 countries, last updated Oct-25.'));
      expect(
        out,
        contains(
          "  'IT': IbanRegistryEntry(\n"
          '    ibanLength: 27,\n'
          "    bbanFormat: '1!a5!n5!n12!c',\n"
          '    bankCodeStart: 5,\n'
          '    bankCodeEnd: 10,\n'
          '    branchCodeStart: 10,\n'
          '    branchCodeEnd: 15,\n',
        ),
      );
    });

    test('fails loudly on inconsistent data', () {
      expect(
        () => parseIbanRegistry(_registry(deIbanLength: '23')),
        throwsFormatException,
      );
      expect(
        () => parseIbanRegistry(_registry(deBban: '8!n10!a')),
        throwsFormatException,
      );
      expect(
        () => parseIbanRegistry(_registry(deBankPos: '1-19')),
        throwsFormatException,
      );
      expect(
        () => parseIbanRegistry('Name of country\tGermany\n'),
        throwsFormatException,
      );
    });
  });
}

/// A three-country excerpt in the registry's layout: one column per
/// country, plus a quoted multi-line contact cell like the real file has.
String _registry({
  String deIbanLength = '22',
  String deBban = '8!n10!n',
  String deBankPos = '1-8',
}) => <String>[
  'Data element\tCZ\tDE\tIT',
  'IBAN prefix country code (ISO 3166)\tCZ\tDE\tIT',
  'BBAN structure\t4!n16!n\t$deBban\t1!a5!n5!n12!c',
  'BBAN length\t20\t18\t23',
  'Bank identifier position within the BBAN\t1-4\t$deBankPos\t2-6',
  'Branch identifier position within the BBAN\t\t\t7-11',
  'IBAN structure\tCZ2!n4!n6!n10!n\tDE2!n8!n10!n\tIT2!n1!a5!n5!n12!c',
  'IBAN length\t24\t$deIbanLength\t27',
  'IBAN electronic format example\tCZ6508000000192000145399\t'
      'DE89370400440532013000\tIT60X0542811101000000123456',
  'Street Address\t"Na Prikope 28,\nPraha"\t\t',
  'Last update date\tJun-25\tJan-11\tOct-25',
].join('\r\n');
