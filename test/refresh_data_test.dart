@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../tool/refresh_data.dart';

void main() {
  group('renderBankCodesLibrary', () {
    test('embeds rows as JSON, one bank per line', () {
      final String source = renderBankCodesLibrary(
        'nl',
        <String, Map<String, String?>>{
          'ABNA': <String, String?>{
            'bic': 'ABNANL2A',
            'bankName': r"ABN AMRO's \$ bank",
            'bankShortName': 'ABN AMRO',
          },
          'INGB': <String, String?>{
            'bic': 'INGBNL2A',
            'bankName': 'ING',
            'bankShortName': 'ING',
          },
        },
      );
      expect(source, contains('dart run tool/refresh_data.dart NL'));
      expect(
        source,
        contains(
          "r'''\n{\n"
          '"ABNA":{"bic":"ABNANL2A","bankName":"ABN AMRO\'s \\\\\$ bank",'
          '"bankShortName":"ABN AMRO"},\n'
          '"INGB":{"bic":"INGBNL2A","bankName":"ING","bankShortName":"ING"}\n'
          "}\n''';\n",
        ),
      );
    });

    test("rejects data containing '''", () {
      expect(
        () => renderBankCodesLibrary('NL', <String, Map<String, String?>>{
          'ABNA': <String, String?>{'bankName': "a'''b"},
        }),
        throwsStateError,
      );
    });

    // Re-renders each file from its own data, so this checks layout (one
    // bank per line, header, path), not the values: a hand-edited BIC in
    // the generated format still passes. Values are checked against the
    // upstream sources by the refresh workflow.
    test('checked-in datasets are in the generator format', () {
      final List<File> files = Directory('lib/src/data')
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.g.dart'))
          .toList();
      expect(files, isNotEmpty);
      for (final File file in files) {
        final String cc = file.uri.pathSegments.last.split('.').first;
        final String source = file.readAsStringSync();
        final int start = source.indexOf("r'''") + 4;
        final int end = source.lastIndexOf("'''");
        final Map<String, dynamic> decoded =
            json.decode(source.substring(start, end)) as Map<String, dynamic>;
        final Map<String, Map<String, String?>> rows =
            <String, Map<String, String?>>{
              for (final MapEntry<String, dynamic> e in decoded.entries)
                e.key: (e.value as Map<String, dynamic>)
                    .cast<String, String?>(),
            };
        expect(
          renderBankCodesLibrary(cc, rows),
          source,
          reason: '${file.path} is not in the format the generator writes',
        );
        expect(file.path, bankCodesLibraryPath(cc));
      }
    });
  });

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

    test('reads the BIC after the PAN column of a real file row', () {
      // Row for 50070010 from the Bundesbank file valid 2026-09-07 to
      // 2026-12-06, split at field boundaries. The PAN (27100) sits in
      // columns 135-139, directly in front of the BIC.
      const String row =
          '50070010'
          '1'
          'Deutsche Bank                                             '
          '60254'
          'Frankfurt am Main                  '
          'Deutsche Bank              '
          '27100'
          'DEUTDEFFXXX'
          '63004807U000000000';
      expect(row.length, 168);

      final BankEntry entry = parseBundesbankBlz(row)['50070010']!;
      expect(entry.bic, 'DEUTDEFFXXX');
      expect(entry.bankName, 'Deutsche Bank');
      expect(entry.bankShortName, 'Deutsche Bank');
      expect(entry.bankPostcode, '60254');
      expect(entry.bankLocation, 'Frankfurt am Main');
    });
  });

  group('findBundesbankBlzTxtUrl', () {
    test('picks the current unpacked TXT file', () {
      const String html =
          '<a href="https://www.bundesbank.de/resource/blob/1/a/X/blz-neu-txt-data.txt">new</a>'
          '<a href="https://www.bundesbank.de/resource/blob/2/b/X/blz-aktuell-txt-zip-data.zip">zip</a>'
          '<a href="https://www.bundesbank.de/resource/blob/3/c/X/blz-aktuell-txt-data.txt">txt</a>';
      expect(
        findBundesbankBlzTxtUrl(html),
        'https://www.bundesbank.de/resource/blob/3/c/X/blz-aktuell-txt-data.txt',
      );
    });

    test('resolves site-relative links', () {
      expect(
        findBundesbankBlzTxtUrl(
          '<a href="/resource/blob/3/c/X/blz-aktuell-txt-data.txt">txt</a>',
        ),
        'https://www.bundesbank.de/resource/blob/3/c/X/blz-aktuell-txt-data.txt',
      );
    });

    test('returns null when no current TXT link is present', () {
      expect(
        findBundesbankBlzTxtUrl('<a href="/blz-neu-txt-data.txt">'),
        isNull,
      );
    });
  });
}

/// Constructs a Bundesbank BLZ row up to and including the BIC (150
/// chars), with a blank PAN. See column layout in `tool/refresh_data.dart`.
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
    ..write(''.padRight(5)) // PAN
    ..write(bic.padRight(11).substring(0, 11));
  return sb.toString();
}
