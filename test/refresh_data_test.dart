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

  group('findBundesbankBlzValidity', () {
    test('reads the period printed next to the current TXT link', () {
      // Trimmed from the live download page; the upcoming file is listed
      // first and must not win.
      const String html =
          '<a href="/x/blz-neu-txt-data.txt"><small>gültig vom 07.12.2026 '
          'bis 07.03.2027</small></a>'
          '<a href="https://www.bundesbank.de/x/blz-aktuell-txt-data.txt" '
          'target="_blank"><div class="h3">Bankleitzahlendateien\n'
          '<small class="d-block teasable__subtitle">gültig vom 07.09.2026 '
          'bis 06.12.2026</small></div></a>';
      final ({DateTime from, DateTime until})? v = findBundesbankBlzValidity(
        html,
      );
      expect(v?.from, DateTime.utc(2026, 9, 7));
      expect(v?.until, DateTime.utc(2026, 12, 6));
    });

    test('returns null when the page shows no period', () {
      expect(
        findBundesbankBlzValidity('<a href="/blz-aktuell-txt-data.txt">'),
        isNull,
      );
    });
  });

  group('buildMetaEntry', () {
    test('records source, dates and the content hash', () {
      final Map<String, dynamic> entry = buildMetaEntry(
        '{}\n',
        DatasetSource(
          publisher: 'Deutsche Bundesbank',
          url: 'https://example.com/blz.txt',
          effectiveFrom: DateTime.utc(2026, 9, 7),
          validUntil: DateTime.utc(2026, 12, 6),
        ),
        DateTime.utc(2026, 10, 29, 4),
      );
      expect(entry, <String, dynamic>{
        'publisher': 'Deutsche Bundesbank',
        'sourceUrl': 'https://example.com/blz.txt',
        'retrievedOn': '2026-10-29',
        'effectiveFrom': '2026-09-07',
        'validUntil': '2026-12-06',
        // sha256 of "{}\n"
        'sha256':
            'ca3d163bab055381827226140568f3bef7eaac187cebd76878e0b63e9e442356',
        'notes': null,
      });
    });

    test('leaves fields null when the adapter recorded no source', () {
      final Map<String, dynamic> entry = buildMetaEntry(
        '{}\n',
        null,
        DateTime.utc(2026, 10, 29),
      );
      expect(entry['sourceUrl'], isNull);
      expect(entry['effectiveFrom'], isNull);
      expect(entry['retrievedOn'], '2026-10-29');
    });
  });

  group('mergeMetaEntry', () {
    Map<String, dynamic> entry({
      String publisher = 'Deutsche Bundesbank',
      String url = 'https://example.com/blz.txt',
      String retrievedOn = '2026-10-29',
      String? effectiveFrom = '2026-09-07',
      String? validUntil = '2026-12-06',
      String sha = 'abc',
    }) => <String, dynamic>{
      'publisher': publisher,
      'sourceUrl': url,
      'retrievedOn': retrievedOn,
      'effectiveFrom': effectiveFrom,
      'validUntil': validUntil,
      'sha256': sha,
      'notes': null,
    };

    test('takes the fresh entry when there is none yet', () {
      expect(mergeMetaEntry(null, entry()), entry());
    });

    test('returns null when nothing but the retrieval date changed', () {
      expect(mergeMetaEntry(entry(), entry(retrievedOn: '2026-11-02')), isNull);
    });

    test('records a changed publisher', () {
      expect(
        mergeMetaEntry(entry(), entry(publisher: 'Bundesbank'))?['publisher'],
        'Bundesbank',
      );
    });

    test('keeps known dates for the same file when they are unknown now', () {
      // E.g. BUNDESBANK_BLZ_URL pins the file, so the page isn't read.
      expect(
        mergeMetaEntry(
          entry(),
          entry(
            retrievedOn: '2026-11-02',
            effectiveFrom: null,
            validUntil: null,
          ),
        ),
        isNull,
      );
      final Map<String, dynamic>? changed = mergeMetaEntry(
        entry(),
        entry(effectiveFrom: null, validUntil: null, sha: 'def'),
      );
      expect(changed?['effectiveFrom'], '2026-09-07');
      expect(changed?['validUntil'], '2026-12-06');
    });

    test('drops dates when the source file changed', () {
      final Map<String, dynamic>? changed = mergeMetaEntry(
        entry(),
        entry(url: 'https://example.com/other.txt', effectiveFrom: null),
      );
      expect(changed?['effectiveFrom'], isNull);
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
