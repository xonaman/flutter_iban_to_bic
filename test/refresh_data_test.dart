import 'dart:convert';

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

  group('refreshCountries', () {
    final Map<String, CountryAdapter?> registry = <String, CountryAdapter?>{
      'AT': null,
      'BE': () async => <String, BankEntry>{
        '001': BankEntry(
          bic: 'GEBABEBBXXX',
          bankName: 'BNP',
          bankShortName: 'BNP',
        ),
      },
      'DE': () async => throw AdapterSkipped('upstream URL needs rotating'),
      'NL': () async => throw StateError('GET failed: HTTP 404\nmore | detail'),
    };

    test('records each country and writes only refreshed ones', () async {
      final Map<String, int> written = <String, int>{};
      final RefreshSummary summary = await refreshCountries(
        <String>['AT', 'BE', 'DE', 'NL', 'XX'],
        registry,
        write: (String cc, Map<String, BankEntry> e) => written[cc] = e.length,
      );

      expect(written, <String, int>{'BE': 1});
      expect(summary.needsAttention, isTrue);
      expect(jsonDecode(jsonEncode(summary.toJson())), <String, Object?>{
        'needsAttention': true,
        'counts': <String, int>{
          'refreshed': 1,
          'skipped': 1,
          'failed': 1,
          'notImplemented': 2,
        },
        'countries': <Map<String, Object?>>[
          <String, Object?>{
            'country': 'AT',
            'status': 'notImplemented',
            'reason': 'no adapter yet',
          },
          <String, Object?>{
            'country': 'BE',
            'status': 'refreshed',
            'entries': 1,
          },
          <String, Object?>{
            'country': 'DE',
            'status': 'skipped',
            'reason': 'upstream URL needs rotating',
          },
          <String, Object?>{
            'country': 'NL',
            'status': 'failed',
            'reason': 'Bad state: GET failed: HTTP 404\nmore | detail',
          },
          <String, Object?>{
            'country': 'XX',
            'status': 'notImplemented',
            'reason': 'unknown country',
          },
        ],
      });
    });

    test('countries without an adapter do not need attention', () async {
      final RefreshSummary summary = await refreshCountries(
        <String>['AT', 'BE'],
        registry,
        write: (_, _) {},
      );
      expect(summary.needsAttention, isFalse);
      expect(summary.toJson()['needsAttention'], isFalse);
    });

    test('renders a Markdown table with escaped reasons', () async {
      final RefreshSummary summary = await refreshCountries(
        <String>['BE', 'DE', 'NL'],
        registry,
        write: (_, _) {},
      );
      expect(
        summary.toMarkdown(),
        '| Country | Status | Details |\n'
        '| --- | --- | --- |\n'
        '| BE | refreshed | 1 entries |\n'
        '| DE | skipped | upstream URL needs rotating |\n'
        '| NL | failed | Bad state: GET failed: HTTP 404 more \\| detail |\n',
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
