// Storage formats for the bundled bank-code datasets.
//
// Each country has two files:
//
//   data/bank_codes/<cc>.jsonl   Canonical source, checked in and reviewed.
//                                One JSON object per line, sorted by bank
//                                code, so a refresh diff shows exactly which
//                                codes were added, removed or changed.
//   assets/bank_codes/<cc>.json  Runtime asset the library loads. Generated
//                                from the source by `tool/build_assets.dart`;
//                                never edit it by hand.
//
// The runtime asset is a compact, normalized form of the source. Bank codes
// that share every field are grouped into one row, field names are replaced
// by positions, and trailing absent fields are dropped:
//
//   {"v":1,"banks":[[codes, bic, bankName, bankShortName, bankAddress,
//                    bankPostcode, bankLocation], ...]}
//
// `codes` is a list of bank codes. `bankShortName` is `null` when it equals
// `bankName`; the optional fields are `null` when absent. Rows are ordered
// by their first bank code. `lib/src/asset_resolver.dart` decodes it.

import 'dart:convert';
import 'dart:io';

/// Version tag of the runtime asset format written by [encodeAsset].
const int assetFormatVersion = 1;

/// Directory holding the canonical `<cc>.jsonl` sources.
const String sourceDir = 'data/bank_codes';

/// Directory holding the generated `<cc>.json` runtime assets.
const String assetDir = 'assets/bank_codes';

String sourcePath(String cc) => '$sourceDir/${cc.toLowerCase()}.jsonl';

String assetPath(String cc) => '$assetDir/${cc.toLowerCase()}.json';

class BankEntry {
  final String bic;
  final String bankName;
  final String bankShortName;
  final String? bankAddress;
  final String? bankPostcode;
  final String? bankLocation;

  BankEntry({
    required this.bic,
    required this.bankName,
    required this.bankShortName,
    this.bankAddress,
    this.bankPostcode,
    this.bankLocation,
  });

  factory BankEntry.fromJson(Map<String, dynamic> m) => BankEntry(
    bic: m['bic'] as String,
    bankName: m['bankName'] as String,
    bankShortName: m['bankShortName'] as String,
    bankAddress: m['bankAddress'] as String?,
    bankPostcode: m['bankPostcode'] as String?,
    bankLocation: m['bankLocation'] as String?,
  );

  Map<String, String?> toJson() => <String, String?>{
    'bic': bic,
    'bankName': bankName,
    'bankShortName': bankShortName,
    if (bankAddress != null) 'bankAddress': bankAddress,
    if (bankPostcode != null) 'bankPostcode': bankPostcode,
    if (bankLocation != null) 'bankLocation': bankLocation,
  };

  /// Positional form used in the runtime asset, without the leading codes.
  List<String?> _toRow() {
    final List<String?> row = <String?>[
      bic,
      bankName,
      bankShortName == bankName ? null : bankShortName,
      bankAddress,
      bankPostcode,
      bankLocation,
    ];
    while (row.last == null) {
      row.removeLast();
    }
    return row;
  }

  @override
  bool operator ==(Object other) =>
      other is BankEntry &&
      other.bic == bic &&
      other.bankName == bankName &&
      other.bankShortName == bankShortName &&
      other.bankAddress == bankAddress &&
      other.bankPostcode == bankPostcode &&
      other.bankLocation == bankLocation;

  @override
  int get hashCode => Object.hash(
    bic,
    bankName,
    bankShortName,
    bankAddress,
    bankPostcode,
    bankLocation,
  );
}

/// Bank codes in canonical order: plain string order, which is numeric
/// order for the fixed-width numeric codes most countries use.
List<String> sortedCodes(Iterable<String> codes) =>
    codes.toList()..sort((String a, String b) => a.compareTo(b));

/// Encodes [entries] as the canonical JSON Lines source.
String encodeSource(Map<String, BankEntry> entries) {
  final StringBuffer out = StringBuffer();
  for (final String code in sortedCodes(entries.keys)) {
    out.writeln(
      jsonEncode(<String, String?>{'code': code, ...entries[code]!.toJson()}),
    );
  }
  return out.toString();
}

/// Parses the canonical JSON Lines source written by [encodeSource].
Map<String, BankEntry> decodeSource(String text) {
  final Map<String, BankEntry> entries = <String, BankEntry>{};
  final List<String> lines = const LineSplitter().convert(text);
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim().isEmpty) continue;
    final Map<String, dynamic> m = jsonDecode(lines[i]) as Map<String, dynamic>;
    final String code = m['code'] as String;
    if (entries.containsKey(code)) {
      throw FormatException('duplicate bank code $code', text, i + 1);
    }
    entries[code] = BankEntry.fromJson(m);
  }
  return entries;
}

Map<String, BankEntry> readSource(String cc) =>
    decodeSource(File(sourcePath(cc)).readAsStringSync());

/// Encodes [entries] as the minified runtime asset described at the top of
/// this file. Deterministic: equal inputs give byte-identical output.
String encodeAsset(Map<String, BankEntry> entries) {
  final Map<BankEntry, List<String>> groups = <BankEntry, List<String>>{};
  for (final String code in sortedCodes(entries.keys)) {
    (groups[entries[code]!] ??= <String>[]).add(code);
  }
  final List<List<Object?>> banks = <List<Object?>>[
    for (final MapEntry<BankEntry, List<String>> g in groups.entries)
      <Object?>[g.value, ...g.key._toRow()],
  ];
  return '${jsonEncode(<String, Object>{'v': assetFormatVersion, 'banks': banks})}\n';
}

/// Writes both the source and the runtime asset for [cc].
void writeCountry(String cc, Map<String, BankEntry> entries) {
  File(sourcePath(cc)).writeAsStringSync(encodeSource(entries));
  File(assetPath(cc)).writeAsStringSync(encodeAsset(entries));
}

/// Country codes that have a canonical source, sorted.
List<String> sourceCountries() =>
    Directory(sourceDir)
        .listSync()
        .whereType<File>()
        .map((File f) => f.uri.pathSegments.last)
        .where((String name) => name.endsWith('.jsonl'))
        .map((String name) => name.split('.').first.toUpperCase())
        .toList()
      ..sort();
