// Provenance metadata for the bundled datasets, kept in
// `assets/bank_codes/meta.json` and exposed at runtime by `dataInfo()`.
//
// Each country's entry records the upstream publisher and URL, when the
// file was retrieved, its validity period where the source states one, and
// the SHA-256 of the generated runtime asset `assets/bank_codes/<cc>.json`.
// `tool/refresh_data.dart` writes the entry on refresh;
// `tool/build_assets.dart` updates the hash after a hand edit.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;

import 'bank_codes.dart' show assetDir;

const String metaPath = '$assetDir/meta.json';

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

/// Updates [cc]'s entry in `meta.json` for a freshly written dataset.
///
/// The entry is left alone when neither the content hash nor the source
/// changed, so a refresh that finds nothing new doesn't produce a diff.
void writeMeta(String cc, String body, DatasetSource? source, {DateTime? now}) {
  final Map<String, dynamic> meta = _readMeta();
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

/// The `meta.json` entry for a dataset whose runtime asset content is
/// [body].
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
  'sha256': assetSha256(body),
  'notes': source?.notes,
};

/// Combines a country's existing `meta.json` entry ([old]) with a freshly
/// built one ([fresh]). Returns `null` when nothing worth recording
/// changed, so an unchanged refresh doesn't bump `retrievedOn`.
///
/// When the source URL is the same as before, fields the adapter left
/// unknown keep their recorded values: the dates (e.g. `BUNDESBANK_BLZ_URL`
/// pins a file, so the download page isn't read) and hand-written `notes`.
/// A different source URL means a different file, so stale dates and notes
/// are dropped unless the adapter supplies new ones.
Map<String, dynamic>? mergeMetaEntry(
  Map<String, dynamic>? old,
  Map<String, dynamic> fresh,
) {
  if (old == null) return fresh;
  final Map<String, dynamic> next = Map<String, dynamic>.of(fresh);
  if (next['sourceUrl'] != null && next['sourceUrl'] == old['sourceUrl']) {
    for (final String k in <String>['effectiveFrom', 'validUntil', 'notes']) {
      next[k] ??= old[k];
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
  if (tracked.every((String k) => old[k] == next[k])) return null;
  return next;
}

String? _day(DateTime? d) => d?.toIso8601String().substring(0, 10);

/// Lowercase hex SHA-256 of a runtime asset's content.
String assetSha256(String body) => sha256.convert(utf8.encode(body)).toString();

/// Sets only [cc]'s `sha256` in `meta.json`, for an asset regenerated from
/// a hand-edited source. Retrieval and validity dates stay as they are,
/// since nothing was downloaded.
void updateMetaHash(String cc, String body) {
  final Map<String, dynamic> meta = _readMeta();
  final Map<String, dynamic> entry = Map<String, dynamic>.of(
    meta[cc] as Map<String, dynamic>? ?? _unknownEntry,
  );
  final String hash = assetSha256(body);
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

Map<String, dynamic> _readMeta() {
  final File file = File(metaPath);
  return file.existsSync()
      ? json.decode(file.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};
}

void _writeMeta(Map<String, dynamic> meta) {
  final List<String> keys = meta.keys.toList()..sort();
  File(metaPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, dynamic>{for (final String k in keys) k: meta[k]})}\n',
  );
}
