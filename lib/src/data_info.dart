import 'dart:convert';

import 'data/meta.g.dart';

/// Where a built-in country dataset came from and how old it is.
///
/// Read it with [dataInfo]. Fields the package doesn't know are `null`
/// rather than guessed; [notes] usually says why.
class DatasetInfo {
  /// ISO 3166-1 alpha-2 country code, e.g. `DE`.
  final String countryCode;

  /// The organisation that published the upstream file, e.g.
  /// `Deutsche Bundesbank`.
  final String? publisher;

  /// The file (or the page linking it) the dataset was built from.
  final Uri? sourceUrl;

  /// The day the upstream file was downloaded (UTC).
  final DateTime? retrievedOn;

  /// The day the upstream file took effect, or its publication date if
  /// the source states no validity period.
  final DateTime? effectiveFrom;

  /// The last day the upstream file is valid, where the source says so
  /// (the Bundesbank publishes a new file each quarter).
  final DateTime? validUntil;

  /// Lowercase hex SHA-256 of the bundled dataset's JSON (UTF-8).
  final String sha256;

  /// Free-text remarks, e.g. why a date is unknown.
  final String? notes;

  const DatasetInfo({
    required this.countryCode,
    required this.sha256,
    this.publisher,
    this.sourceUrl,
    this.retrievedOn,
    this.effectiveFrom,
    this.validUntil,
    this.notes,
  });

  /// Days between [retrievedOn] and [now] (defaults to today), or `null`
  /// when the retrieval date is unknown.
  int? ageInDays({DateTime? now}) {
    final DateTime? retrieved = retrievedOn;
    if (retrieved == null) return null;
    final DateTime n = (now ?? DateTime.now()).toUtc();
    return DateTime.utc(n.year, n.month, n.day).difference(retrieved).inDays;
  }

  /// Parses one country's entry from the bundled provenance metadata.
  factory DatasetInfo.fromJson(String countryCode, Map<String, dynamic> m) {
    final String? url = m['sourceUrl'] as String?;
    return DatasetInfo(
      countryCode: countryCode,
      publisher: m['publisher'] as String?,
      sourceUrl: url == null ? null : Uri.parse(url),
      retrievedOn: _date(m['retrievedOn']),
      effectiveFrom: _date(m['effectiveFrom']),
      validUntil: _date(m['validUntil']),
      sha256: m['sha256'] as String,
      notes: m['notes'] as String?,
    );
  }

  @override
  String toString() =>
      'DatasetInfo($countryCode, publisher: $publisher, '
      'retrievedOn: ${_fmt(retrievedOn)}, '
      'effectiveFrom: ${_fmt(effectiveFrom)}, '
      'validUntil: ${_fmt(validUntil)})';
}

DateTime? _date(Object? v) {
  if (v == null) return null;
  final DateTime d = DateTime.parse(v as String);
  return DateTime.utc(d.year, d.month, d.day);
}

String? _fmt(DateTime? d) => d?.toIso8601String().substring(0, 10);

Map<String, DatasetInfo>? _all;

/// Returns provenance and age of the built-in dataset for [countryCode]
/// (case-insensitive), or `null` if the package ships no data for it.
///
/// ```dart
/// final info = dataInfo('DE');
/// print(info?.effectiveFrom); // 2026-09-07 00:00:00.000Z
/// print(info?.ageInDays());
/// ```
///
/// The metadata is compiled into the package (it's small), so this is
/// synchronous and needs no preloading. It's parsed on the first call.
DatasetInfo? dataInfo(String countryCode) =>
    (_all ??= parseDatasetMeta(datasetMetaJson))[countryCode.toUpperCase()];

/// Parses provenance metadata in the format of `data/bank_codes/meta.json`.
Map<String, DatasetInfo> parseDatasetMeta(String metaJson) {
  final Map<String, dynamic> decoded =
      json.decode(metaJson) as Map<String, dynamic>;
  return <String, DatasetInfo>{
    for (final MapEntry<String, dynamic> e in decoded.entries)
      e.key: DatasetInfo.fromJson(e.key, e.value as Map<String, dynamic>),
  };
}
