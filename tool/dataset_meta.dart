// Provenance metadata for the bundled datasets.
//
//   data/bank_codes/meta.json   Canonical, checked in and reviewed. One
//                               entry per country: upstream publisher and
//                               URL, when the file was retrieved, its
//                               validity period where the source states
//                               one, the SHA-256 of the dataset and notes.
//   lib/src/data/meta.g.dart    Generated from it; `dataInfo()` reads it.
//
// The hash covers the dataset's compact JSON, i.e. the `bankCodesJson`
// string in `lib/src/data/<cc>.g.dart` (see [datasetJson]).
//
// `tool/refresh_data.dart` writes the entry on refresh;
// `tool/build_assets.dart` updates the hash after a hand edit and checks
// that `meta.g.dart` is current.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;

import 'bank_codes.dart';

const String metaPath = '$sourceDir/meta.json';

const String metaLibraryPath = '$libraryDir/meta.g.dart';

/// Provenance of a freshly fetched dataset, as reported by its adapter.
class DatasetSource {
  DatasetSource({
    required this.publisher,
    required this.url,
    this.effectiveFrom,
    this.validUntil,
    this.notes,
  });

  final String publisher;
  final String url;

  /// Day the upstream file took effect (or was published), if stated.
  final DateTime? effectiveFrom;

  /// Last day the upstream file is valid, if stated.
  final DateTime? validUntil;

  /// Remarks for `meta.json`, e.g. why a date is unknown.
  final String? notes;
}

/// The JSON the package decodes for [entries]: the value of the
/// `bankCodesJson` constant in the generated `<cc>.g.dart` (a raw string
/// keeps the newline before its closing quotes, so this is exactly
/// [encodeAsset]'s output). Its hash is what `meta.json` records.
String datasetJson(Map<String, BankEntry> entries) => encodeAsset(entries);

/// Updates [cc]'s entry in `meta.json` (and `meta.g.dart`) for a freshly
/// written dataset whose JSON is [body].
///
/// The entry is left alone when neither the content hash nor the source
/// changed, so a refresh that finds nothing new doesn't produce a diff.
void writeMeta(String cc, String body, DatasetSource? source, {DateTime? now}) {
  final Map<String, dynamic> meta = readMeta();
  final Map<String, dynamic>? old = meta[cc] as Map<String, dynamic>?;
  final Map<String, dynamic>? next = mergeMetaEntry(
    old,
    buildMetaEntry(body, source, now ?? DateTime.now()),
  );
  if (next == null) return;
  meta[cc] = next;
  _writeMeta(meta);
  print('[$cc] updated $metaPath');
}

/// The `meta.json` entry for a dataset whose JSON is [body].
Map<String, dynamic> buildMetaEntry(
  String body,
  DatasetSource? source,
  DateTime now,
) => <String, dynamic>{
  'publisher': source?.publisher,
  'sourceUrl': source?.url,
  'retrievedOn': _day(now.toUtc()),
  'effectiveFrom': _day(source?.effectiveFrom),
  'validUntil': _day(source?.validUntil),
  'sha256': datasetSha256(body),
  'notes': source?.notes,
};

/// Combines a country's existing `meta.json` entry ([old]) with a freshly
/// built one ([fresh]). Returns `null` when nothing worth recording
/// changed, so an unchanged refresh doesn't bump `retrievedOn`.
///
/// Fields the adapter left unknown keep their recorded values where those
/// still describe the data:
///   - `notes` while the source URL is unchanged (they describe the
///     source, e.g. that it states no validity date);
///   - `effectiveFrom`/`validUntil` while the URL and the content hash
///     are both unchanged, i.e. it is the same file (e.g.
///     `BUNDESBANK_BLZ_URL` pins it, so the download page isn't read).
///     New content at a fixed URL is a new file whose dates are unknown.
Map<String, dynamic>? mergeMetaEntry(
  Map<String, dynamic>? old,
  Map<String, dynamic> fresh,
) {
  if (old == null) return fresh;
  final Map<String, dynamic> next = Map<String, dynamic>.of(fresh);
  final bool sameSource =
      next['sourceUrl'] != null && next['sourceUrl'] == old['sourceUrl'];
  if (sameSource) {
    next['notes'] ??= old['notes'];
    if (next['sha256'] == old['sha256']) {
      next['effectiveFrom'] ??= old['effectiveFrom'];
      next['validUntil'] ??= old['validUntil'];
    }
  }
  const List<String> tracked = <String>[
    'sha256',
    'publisher',
    'sourceUrl',
    'effectiveFrom',
    'validUntil',
    'notes',
  ];
  // A changed retrieval date alone isn't worth a diff, but a first one is.
  final bool firstRetrieval =
      old['retrievedOn'] == null && next['retrievedOn'] != null;
  if (!firstRetrieval && tracked.every((String k) => old[k] == next[k])) {
    return null;
  }
  return next;
}

String? _day(DateTime? d) => d?.toIso8601String().substring(0, 10);

/// Lowercase hex SHA-256 of a dataset's JSON.
String datasetSha256(String body) =>
    sha256.convert(utf8.encode(body)).toString();

/// Sets only [cc]'s `sha256` in `meta.json`, for a dataset regenerated from
/// a hand-edited source. Retrieval and validity dates stay as they are,
/// since nothing was downloaded.
void updateMetaHash(String cc, String body) {
  final Map<String, dynamic> meta = readMeta();
  final Map<String, dynamic> entry = Map<String, dynamic>.of(
    meta[cc] as Map<String, dynamic>? ?? _unknownEntry,
  );
  final String hash = datasetSha256(body);
  if (entry['sha256'] == hash) return;
  entry['sha256'] = hash;
  meta[cc] = entry;
  _writeMeta(meta);
  print('[$cc] updated sha256 in $metaPath');
}

const Map<String, dynamic> _unknownEntry = <String, dynamic>{
  'publisher': null,
  'sourceUrl': null,
  'retrievedOn': null,
  'effectiveFrom': null,
  'validUntil': null,
  'sha256': null,
  'notes': null,
};

/// Parses `meta.json`, or returns an empty map if it doesn't exist yet.
Map<String, dynamic> readMeta() {
  final File file = File(metaPath);
  return file.existsSync()
      ? json.decode(file.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};
}

void _writeMeta(Map<String, dynamic> meta) {
  final List<String> keys = meta.keys.toList()..sort();
  final Map<String, dynamic> sorted = <String, dynamic>{
    for (final String k in keys) k: meta[k],
  };
  File(metaPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(sorted)}\n',
  );
  File(metaLibraryPath).writeAsStringSync(encodeMetaLibrary(sorted));
}

/// The generated `meta.g.dart` for [meta]: a single `datasetMetaJson`
/// raw-string constant holding it as compact JSON.
String encodeMetaLibrary(Map<String, dynamic> meta) {
  final String body = jsonEncode(meta);
  const String quotes = "'''";
  if (body.contains(quotes)) {
    throw StateError("meta.json contains ''' and can't be embedded");
  }
  return <String>[
    '// GENERATED by tool/build_assets.dart from $metaPath.',
    '// Do not edit by hand; edit the source and rerun the tool.',
    '',
    '/// Provenance of the bundled datasets; see `tool/dataset_meta.dart`.',
    'const String datasetMetaJson = r$quotes',
    body,
    '$quotes;',
    '',
  ].join('\n');
}
