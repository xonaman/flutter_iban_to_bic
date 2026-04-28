import 'package:flutter_test/flutter_test.dart';

import '../tool/refresh_data.dart';

void main() {
  group('parseBundesbankBlz', () {
    test('extracts active rows and skips inactive or BIC-less', () {
      final String text = <String>[
        _row(
          blz: '10010010',
          active: true,
          name: 'Postbank Ndl der Deutsche Bank',
          postcode: '10916',
          city: 'Berlin',
          shortName: 'Postbank/DSL Bln',
          bic: 'PBNKDEFFXXX',
        ),
        // Same BLZ inactive — should be ignored.
        _row(
          blz: '10010011',
          active: false,
          name: 'Old Bank',
          postcode: '10000',
          city: 'Nowhere',
          shortName: 'Old',
          bic: 'OLDBDEXXX',
        ),
        // Active but BIC empty — skipped (not resolvable).
        _row(
          blz: '10010012',
          active: true,
          name: 'No BIC Bank',
          postcode: '10000',
          city: 'Nowhere',
          shortName: 'No BIC',
          bic: '',
        ),
        _row(
          blz: '50010517',
          active: true,
          name: 'ING-DiBa',
          postcode: '60628',
          city: 'Frankfurt am Main',
          shortName: 'ING-DiBa',
          bic: 'INGDDEFFXXX',
        ),
      ].join('\n');

      final Map<String, BankEntry> parsed = parseBundesbankBlz(text);

      expect(parsed.keys, unorderedEquals(<String>['10010010', '50010517']));

      final BankEntry ing = parsed['50010517']!;
      expect(ing.bic, 'INGDDEFFXXX');
      expect(ing.bankName, 'ING-DiBa');
      expect(ing.bankShortName, 'ING-DiBa');
      expect(ing.bankPostcode, '60628');
      expect(ing.bankLocation, 'Frankfurt am Main');
    });

    test('tolerates short/garbled lines without crashing', () {
      final String text = <String>[
        'too short',
        '',
        _row(
          blz: '12345678',
          active: true,
          name: 'Valid Bank',
          postcode: '11111',
          city: 'Somewhere',
          shortName: 'Valid',
          bic: 'VALDDEMMXXX',
        ),
      ].join('\n');
      final Map<String, BankEntry> parsed = parseBundesbankBlz(text);
      expect(parsed, hasLength(1));
      expect(parsed['12345678']!.bic, 'VALDDEMMXXX');
    });

    test('falls back to long name when short name is blank', () {
      final String text = _row(
        blz: '87654321',
        active: true,
        name: 'Bank With Only A Long Name',
        postcode: '22222',
        city: 'Anywhere',
        shortName: '',
        bic: 'LONGDEMMXXX',
      );
      final BankEntry entry = parseBundesbankBlz(text)['87654321']!;
      expect(entry.bankShortName, 'Bank With Only A Long Name');
    });
  });
}

/// Constructs a 145-char Bundesbank BLZ row. See column layout in
/// `tool/refresh_data.dart`.
String _row({
  required String blz,
  required bool active,
  required String name,
  required String postcode,
  required String city,
  required String shortName,
  required String bic,
}) {
  assert(blz.length == 8);
  final StringBuffer sb = StringBuffer()
    ..write(blz)
    ..write(active ? '1' : '2')
    ..write(name.padRight(58).substring(0, 58))
    ..write(postcode.padRight(5).substring(0, 5))
    ..write(city.padRight(35).substring(0, 35))
    ..write(shortName.padRight(27).substring(0, 27))
    ..write(bic.padRight(11).substring(0, 11));
  return sb.toString();
}
