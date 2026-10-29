// Generates `lib/src/iban_registry.g.dart` from the SWIFT IBAN Registry.
//
// The registry is published by SWIFT, the ISO 13616 registration authority,
// as a tab-separated text file with one column per country:
//   https://www.swift.com/standards/data-standards/iban-international-bank-account-number
//   ("IBAN Registry (TXT)", https://www.swift.com/swift-resource/11971/download)
//
// swift.com rejects scripted downloads, so fetch the file in a browser and
// pass its path:
//   dart run tool/generate_iban_registry.dart path/to/iban-registry.txt
//   dart format lib/src/iban_registry.g.dart
//
// Only the registry's own data goes into the generated file. Per-country
// metadata that we maintain by hand belongs in `lib/src/iban_to_bic.dart`.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

const String registryUrl =
    'https://www.swift.com/swift-resource/11971/download';
const String outputPath = 'lib/src/iban_registry.g.dart';

/// One country's column of the IBAN Registry, reduced to what we generate.
class RegistryCountry {
  final String countryCode;
  final int ibanLength;
  final String bbanFormat;

  /// 1-based, inclusive positions within the BBAN, as the registry prints
  /// them.
  final int bankIdFrom;
  final int bankIdTo;
  final int? branchIdFrom;
  final int? branchIdTo;
  final String example;
  final String lastUpdate;

  const RegistryCountry({
    required this.countryCode,
    required this.ibanLength,
    required this.bbanFormat,
    required this.bankIdFrom,
    required this.bankIdTo,
    required this.branchIdFrom,
    required this.branchIdTo,
    required this.example,
    required this.lastUpdate,
  });
}

/// Splits tab-separated [text] into rows of cells. Cells may be wrapped in
/// double quotes, in which case they can contain tabs, line breaks and
/// doubled `""` quotes (the registry's contact addresses do).
List<List<String>> parseTsv(String text) {
  final List<List<String>> rows = <List<String>>[];
  List<String> row = <String>[];
  final StringBuffer cell = StringBuffer();
  bool quoted = false;
  bool atCellStart = true;
  for (int i = 0; i < text.length; i++) {
    final String ch = text[i];
    if (quoted) {
      if (ch == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        cell.write(ch);
      }
      continue;
    }
    if (ch == '"' && atCellStart) {
      quoted = true;
      atCellStart = false;
    } else if (ch == '\t') {
      row.add(cell.toString());
      cell.clear();
      atCellStart = true;
    } else if (ch == '\r' || ch == '\n') {
      if (ch == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(cell.toString());
      cell.clear();
      rows.add(row);
      row = <String>[];
      atCellStart = true;
    } else {
      cell.write(ch);
      atCellStart = false;
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString());
    rows.add(row);
  }
  return rows;
}

/// Parses the registry text into one entry per country, sorted by code.
///
/// Throws [FormatException] when a row is missing or a column contradicts
/// itself (for example, an IBAN length that is not the BBAN length + 4), so
/// a format change upstream fails loudly instead of generating bad data.
List<RegistryCountry> parseIbanRegistry(String text) {
  final Map<String, List<String>> byLabel = <String, List<String>>{
    for (final List<String> row in parseTsv(text))
      if (row.isNotEmpty) row.first.trim(): row,
  };
  List<String> rowFor(String label) =>
      byLabel[label] ??
      (throw FormatException('Registry row "$label" missing'));

  final List<String> codes = rowFor('IBAN prefix country code (ISO 3166)');
  final List<String> bbanStructure = rowFor('BBAN structure');
  final List<String> bbanLength = rowFor('BBAN length');
  final List<String> bankPos = rowFor(
    'Bank identifier position within the BBAN',
  );
  final List<String> branchPos = rowFor(
    'Branch identifier position within the BBAN',
  );
  final List<String> ibanStructure = rowFor('IBAN structure');
  final List<String> ibanLength = rowFor('IBAN length');
  final List<String> example = rowFor('IBAN electronic format example');
  final List<String> lastUpdate = rowFor('Last update date');

  String cell(List<String> row, int i) => i < row.length ? row[i].trim() : '';

  final List<RegistryCountry> countries = <RegistryCountry>[];
  for (int i = 1; i < codes.length; i++) {
    final String cc = cell(codes, i);
    if (cc.isEmpty) continue;
    String where(String what) => '$cc: $what';

    if (!RegExp(r'^[A-Z]{2}$').hasMatch(cc)) {
      throw FormatException(where('bad country code'));
    }
    final int length = int.parse(cell(ibanLength, i));
    // The IBAN structure row spells the BBAN out in the most detail (CZ's
    // BBAN row says `4!n16!n`, its IBAN row `CZ2!n4!n6!n10!n`), so take the
    // format from there and only require both rows to describe the same
    // characters.
    final String iban = cell(ibanStructure, i);
    if (!iban.startsWith('${cc}2!n')) {
      throw FormatException(where('IBAN structure must start with ${cc}2!n'));
    }
    final String bban = iban.substring(5);
    if (expandBbanFormat(bban) != expandBbanFormat(cell(bbanStructure, i))) {
      throw FormatException(where('IBAN and BBAN structures disagree'));
    }
    if (int.parse(cell(bbanLength, i)) != length - 4 ||
        expandBbanFormat(bban).length != length - 4) {
      throw FormatException(where('IBAN/BBAN lengths disagree'));
    }
    final (int, int)? bank = _parseRange(cell(bankPos, i));
    if (bank == null || bank.$2 > length - 4) {
      throw FormatException(where('bad bank identifier position'));
    }
    final (int, int)? branch = _parseRange(cell(branchPos, i));
    final String ex = cell(example, i);
    if (ex.length != length || !ex.startsWith(cc)) {
      throw FormatException(where('example does not match length'));
    }
    countries.add(
      RegistryCountry(
        countryCode: cc,
        ibanLength: length,
        bbanFormat: bban,
        bankIdFrom: bank.$1,
        bankIdTo: bank.$2,
        branchIdFrom: branch?.$1,
        branchIdTo: branch?.$2,
        example: ex,
        lastUpdate: cell(lastUpdate, i),
      ),
    );
  }
  if (countries.isEmpty) throw const FormatException('No countries found');
  countries.sort(
    (RegistryCountry a, RegistryCountry b) =>
        a.countryCode.compareTo(b.countryCode),
  );
  return countries;
}

/// Parses `"1-4"` into `(1, 4)`; blank or `N/A` cells yield `null`.
(int, int)? _parseRange(String raw) {
  final RegExpMatch? m = RegExp(r'^(\d+)-(\d+)$').firstMatch(raw);
  if (m == null) return null;
  final int from = int.parse(m.group(1)!);
  final int to = int.parse(m.group(2)!);
  return from >= 1 && to >= from ? (from, to) : null;
}

/// Expands a fixed-length BBAN format into one class letter per character,
/// e.g. `2!n1!a` becomes `nna`.
String expandBbanFormat(String format) {
  final RegExp token = RegExp(r'(\d+)!([nac])');
  if (format.replaceAll(token, '').isNotEmpty) {
    throw FormatException('Unsupported BBAN format "$format"');
  }
  return token
      .allMatches(format)
      .map((RegExpMatch m) => m.group(2)! * int.parse(m.group(1)!))
      .join();
}

/// Renders the generated Dart library for [countries].
String renderIbanRegistry(List<RegistryCountry> countries) {
  final StringBuffer out = StringBuffer()
    ..writeln('// GENERATED by tool/generate_iban_registry.dart. Do not edit.')
    ..writeln('//')
    ..writeln('// Source: SWIFT IBAN Registry (TXT), $registryUrl')
    ..writeln(
      '// ${countries.length} countries, last updated ${_latestUpdate(countries)}.',
    )
    ..writeln()
    ..writeln("import 'iban_registry.dart';")
    ..writeln()
    ..writeln('/// IBAN Registry entries by ISO 3166 country code.')
    ..writeln('const Map<String, IbanRegistryEntry> ibanRegistry =')
    ..writeln('    <String, IbanRegistryEntry>{');
  for (final RegistryCountry c in countries) {
    // Registry positions are 1-based within the BBAN; the generated offsets
    // are 0-based, end-exclusive and relative to the whole IBAN.
    out
      ..writeln("  '${c.countryCode}': IbanRegistryEntry(")
      ..writeln('    ibanLength: ${c.ibanLength},')
      ..writeln("    bbanFormat: '${c.bbanFormat}',")
      ..writeln('    bankCodeStart: ${c.bankIdFrom + 3},')
      ..writeln('    bankCodeEnd: ${c.bankIdTo + 4},');
    if (c.branchIdFrom != null) {
      out
        ..writeln('    branchCodeStart: ${c.branchIdFrom! + 3},')
        ..writeln('    branchCodeEnd: ${c.branchIdTo! + 4},');
    }
    out
      ..writeln("    example: '${c.example}',")
      ..writeln('  ),');
  }
  out.writeln('};');
  return out.toString();
}

const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// The newest `Mon-YY` "Last update date" across [countries].
String _latestUpdate(List<RegistryCountry> countries) {
  int key(String s) {
    final RegExpMatch? m = RegExp(r'^([A-Za-z]{3})-(\d{2})$').firstMatch(s);
    if (m == null) return -1;
    return int.parse(m.group(2)!) * 12 + _months.indexOf(m.group(1)!);
  }

  String best = 'unknown';
  int bestKey = -1;
  for (final RegistryCountry c in countries) {
    final int k = key(c.lastUpdate);
    if (k > bestKey) {
      bestKey = k;
      best = c.lastUpdate;
    }
  }
  return best;
}

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stderr.writeln(
      'Usage: dart run tool/generate_iban_registry.dart <iban-registry.txt>\n'
      'Download the TXT from $registryUrl first.',
    );
    exitCode = 64;
    return;
  }
  // The registry is Windows-1252; every field we read is ASCII, so latin1
  // decodes it losslessly enough and never throws.
  final String text = latin1.decode(await File(args.single).readAsBytes());
  final List<RegistryCountry> countries = parseIbanRegistry(text);
  await File(outputPath).writeAsString(renderIbanRegistry(countries));
  print('Wrote ${countries.length} countries to $outputPath');
}
