import 'dart:convert';
import 'dart:io';

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

    test('records a first retrieval date on an entry without one', () {
      final Map<String, dynamic> legacy = entry()..['retrievedOn'] = null;
      expect(mergeMetaEntry(legacy, entry())?['retrievedOn'], '2026-10-29');
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
    });

    test('drops dates for new content at the same URL', () {
      // A fixed-URL source (e.g. NBB) published a new file.
      final Map<String, dynamic>? changed = mergeMetaEntry(
        entry(),
        entry(effectiveFrom: null, validUntil: null, sha: 'def'),
      );
      expect(changed?['effectiveFrom'], isNull);
      expect(changed?['validUntil'], isNull);
    });

    test('keeps hand-written notes while the source is unchanged', () {
      final Map<String, dynamic> noted = entry()..['notes'] = 'by hand';
      final Map<String, dynamic>? changed = mergeMetaEntry(
        noted,
        entry(sha: 'def'),
      );
      expect(changed?['notes'], 'by hand');
      expect(
        mergeMetaEntry(
          noted,
          entry(sha: 'def')..['notes'] = 'from adapter',
        )?['notes'],
        'from adapter',
      );
      expect(
        mergeMetaEntry(
          noted,
          entry(url: 'https://example.com/other.txt'),
        )?['notes'],
        isNull,
      );
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

  // The fixtures under test/fixtures/ hold a handful of real rows from each
  // publisher's file (October 2026). The xlsx fixtures are minimal
  // hand-built workbooks with the same header layout as the originals.

  group('readXlsxRows', () {
    test('reads shared, rich-text, inline and numeric cells', () {
      final List<List<String>> rows = readXlsxRows(
        File('test/fixtures/nbb_full_list.xlsx').readAsBytesSync(),
      );
      expect(rows, hasLength(8));
      expect(rows[0], <String>['Version 01/09/2026']);
      // Rich text split over two runs.
      expect(rows[4][2], 'Nationale Bank van België');
      // Number cell.
      expect(rows[3][0], '50');
      // An omitted cell (C8) leaves a gap rather than shifting columns.
      expect(rows[7].sublist(0, 4), <String>[
        '171',
        'CPHB BE 75',
        '',
        'Banque CPH',
      ]);
      // Inline strings and XML entities.
      expect(
        readXlsxRows(
          File('test/fixtures/betaalvereniging_bic.xlsx').readAsBytesSync(),
        )[4],
        <String>['INGBNL2A', 'INGB', 'ING BANK N.V.'],
      );
      expect(
        readXlsxRows(
          File('test/fixtures/abbl_iban_bic.xlsx').readAsBytesSync(),
        )[2][0],
        "Banque et Caisse d'Epargne de l'Etat, Luxembourg",
      );
    });

    test('rejects non-zip input', () {
      expect(
        () => readXlsxRows(utf8.encode('not a zip')),
        throwsFormatException,
      );
    });
  });

  group('parseOenbSepa', () {
    final Map<String, BankEntry> parsed = parseOenbSepa(
      latin1.decode(File('test/fixtures/oenb_sepa.csv').readAsBytesSync()),
    );

    test('pads bank codes and skips rows without a BIC', () {
      expect(
        parsed.keys,
        unorderedEquals(<String>['00100', '01000', '10000', '14000']),
      );
      expect(parsed['01000']!.bic, 'BUNDATWWXXX');
    });

    test('maps name and address, decoding ISO-8859-1', () {
      final BankEntry bawag = parsed['14000']!;
      expect(bawag.bic, 'BAWAATWWXXX');
      expect(
        bawag.bankName,
        'BAWAG P.S.K. Bank für Arbeit und Wirtschaft und '
        'Österreichische Postsparkasse Aktiengesellschaft',
      );
      expect(bawag.bankShortName, bawag.bankName);
      expect(bawag.bankAddress, 'Wiedner Gürtel 11');
      expect(bawag.bankPostcode, '1100');
      expect(bawag.bankLocation, 'Wien');
    });

    test('fails when the header row is missing', () {
      expect(() => parseOenbSepa('a;b;c\n1;2;3'), throwsFormatException);
    });
  });

  group('splitCsvLine', () {
    test('splits plain fields', () {
      expect(splitCsvLine('a;;b', ';'), <String>['a', '', 'b']);
    });

    test('unquotes fields, keeping delimiters and escaped quotes', () {
      expect(splitCsvLine('"52300";"Bank; ""Nord""";X', ';'), <String>[
        '52300',
        'Bank; "Nord"',
        'X',
      ]);
    });

    test('lets parseOenbSepa read quoted rows', () {
      const String text =
          'Kennzeichen;Identnummer;Bankleitzahl;Bankenname;Straße;PLZ;Ort;'
          'SWIFT-Code\n'
          '"Hauptanstalt";"1";"52300";"Bank; Nord";"Weg 1";"1010";"Wien";'
          '"ABCDATWWXXX"';
      final BankEntry entry = parseOenbSepa(text)['52300']!;
      expect(entry.bic, 'ABCDATWWXXX');
      expect(entry.bankName, 'Bank; Nord');
    });
  });

  group('checkPlausibleSize', () {
    test('accepts normal churn and new countries', () {
      checkPlausibleSize(860, 866);
      checkPlausibleSize(10, 0);
    });

    test('rejects empty or truncated results', () {
      expect(() => checkPlausibleSize(0, 0), throwsStateError);
      expect(() => checkPlausibleSize(400, 866), throwsStateError);
    });
  });

  group('parseNbbBic', () {
    final Map<String, BankEntry> parsed = parseNbbBic(
      readXlsxRows(File('test/fixtures/nbb_full_list.xlsx').readAsBytesSync()),
    );

    test('skips placeholder BICs and pads numeric codes', () {
      expect(
        parsed.keys,
        unorderedEquals(<String>['000', '050', '100', '171']),
      );
    });

    test('strips spaces from BICs and prefers the Dutch name', () {
      expect(parsed['000']!.bic, 'GEBABEBB');
      expect(parsed['100']!.bic, 'NBBEBEBB203');
      expect(parsed['100']!.bankName, 'Nationale Bank van België');
      expect(parsed['100']!.bankAddress, isNull);
    });

    test('falls back to the French name', () {
      expect(parsed['171']!.bankName, 'Banque CPH');
      expect(parsed['171']!.bankShortName, 'Banque CPH');
    });
  });

  group('parseAbblRegister', () {
    final Map<String, BankEntry> parsed = parseAbblRegister(
      readXlsxRows(File('test/fixtures/abbl_iban_bic.xlsx').readAsBytesSync()),
    );

    test('reads codes and BICs, skipping rows without a BIC', () {
      expect(
        parsed.keys,
        unorderedEquals(<String>['001', '002', '810', '999']),
      );
      expect(parsed['002']!.bic, 'BILLLULL');
      expect(parsed['002']!.bankName, 'Banque Internationale à Luxembourg');
      expect(parsed['810']!.bic, 'SATYLUL1XXX');
    });
  });

  group('parseBetaalverenigingBic', () {
    final Map<String, BankEntry> parsed = parseBetaalverenigingBic(
      readXlsxRows(
        File('test/fixtures/betaalvereniging_bic.xlsx').readAsBytesSync(),
      ),
    );

    test('keys by identifier and trims names', () {
      expect(
        parsed.keys,
        unorderedEquals(<String>['ABNA', 'AEGO', 'INGB', 'ZWLB']),
      );
      expect(parsed['AEGO']!.bic, 'AEGONL2U');
      expect(parsed['AEGO']!.bankName, 'AEGON BANK');
    });
  });

  group('download link lookup', () {
    test('finds the ABBL register xlsx', () {
      expect(
        findAbblRegisterUrl(
          '<a href="https://www.abbl.lu/app/uploads/logo.png">x</a>'
          '<a href="https://office-membernet.abbl.lu/newDocRequest/ABC123/'
          'ABBL_LuxembourgRegisterofIBANBICCodes392.xlsx">Download</a>',
        ),
        'https://office-membernet.abbl.lu/newDocRequest/ABC123/'
        'ABBL_LuxembourgRegisterofIBANBICCodes392.xlsx',
      );
      expect(findAbblRegisterUrl('<a href="/other.xlsx">'), isNull);
    });

    test('finds the Betaalvereniging BIC list, resolving relative links', () {
      expect(
        findBetaalverenigingBicUrl(
          '<a href="https://www.europeanpaymentscouncil.eu/rules.pdf">x</a>'
          '<a href="/wp-content/uploads/2026/10/BIC-lijst-NL.xlsx">BIC</a>',
        ),
        'https://www.betaalvereniging.nl/wp-content/uploads/2026/10/'
        'BIC-lijst-NL.xlsx',
      );
      expect(findBetaalverenigingBicUrl('<p>no link</p>'), isNull);
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
        '| BE | refreshed | 1 entry |\n'
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
