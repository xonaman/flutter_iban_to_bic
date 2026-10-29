import 'dart:async';
import 'dart:convert';

import 'bic.dart';
import 'resolver.dart';

/// Resolves bank codes by lazily loading and parsing a per-country JSON
/// dataset.
///
/// Two shapes are accepted:
///
/// * a map from bank code to an object with `bic`, `bankName`,
///   `bankShortName` and optionally `bankAddress`, `bankPostcode` and
///   `bankLocation`, e.g.
///   `{"10010010":{"bic":"PBNKDEFFXXX","bankName":"Postbank",...}}`;
/// * the compact form the bundled datasets use,
///   `{"v":1,"banks":[[codes, bic, bankName, bankShortName, bankAddress,
///   bankPostcode, bankLocation], ...]}`, where `codes` lists every bank
///   code sharing that row, a `null` `bankShortName` means "same as
///   `bankName`", and trailing `null`s may be omitted.
///
/// The built-in countries use it with the datasets bundled in this package.
/// Point it at your own source to plug in other data, for example a Flutter
/// asset:
///
/// ```dart
/// LazyJsonResolver(() => rootBundle.loadString('assets/my_banks.json'))
/// ```
///
/// The first `resolve` call awaits loading and parsing. After that,
/// results are served from an in-memory cache — subsequent calls complete
/// synchronously from the caller's perspective, but the return type stays
/// `Future<Bic?>` to keep the API coherent.
///
/// Call [preload] up front (e.g. from `main()`) if you want [IbanToBic]'s
/// synchronous `lookupSync` path to work for this country.
class LazyJsonResolver implements BicResolver {
  final Future<String> Function() _loadJson;

  Map<String, Bic>? _cache;
  Future<Map<String, Bic>>? _inFlight;
  int _generation = 0;

  /// Creates a resolver that calls [loadJson] for the raw JSON the first
  /// time it's needed, and again after [evict] or a failed load.
  LazyJsonResolver(Future<String> Function() loadJson) : _loadJson = loadJson;

  /// Loads the dataset into the cache. Idempotent + deduplicated.
  Future<void> preload() async {
    await _load();
  }

  /// Drops the in-memory cache so the next resolve re-reads the dataset.
  ///
  /// Cheap and idempotent. Safe to call mid-load — an in-flight decode
  /// will still fulfil its awaiters but will not repopulate the cache.
  void evict() {
    _generation++;
    _cache = null;
    _inFlight = null;
  }

  /// Upgrades to a [SyncBicResolver] once [preload] has completed.
  ///
  /// Returns `null` if the dataset hasn't finished loading yet.
  SyncBicResolver? asSync() =>
      _cache == null ? null : _CachedSyncResolver(_cache!);

  @override
  Future<Bic?> resolve(String bankCode) async {
    final Map<String, Bic> entries = await _load();
    return entries[bankCode];
  }

  Future<Map<String, Bic>> _load() {
    final Map<String, Bic>? cached = _cache;
    if (cached != null) return Future<Map<String, Bic>>.value(cached);
    return _inFlight ??= _doLoad(_generation);
  }

  Future<Map<String, Bic>> _doLoad(int gen) async {
    try {
      final String raw = await _loadJson();
      final Map<String, Bic> parsed = _parse(json.decode(raw));
      if (_generation == gen) _cache = parsed;
      return parsed;
    } finally {
      // Always clear _inFlight on completion — success or failure —
      // so a transient load error doesn't latch a rejected future
      // onto every subsequent resolve call. Guarded by generation so
      // a concurrent evict+preload doesn't see its own _inFlight wiped.
      if (_generation == gen) _inFlight = null;
    }
  }
}

class _CachedSyncResolver implements SyncBicResolver {
  final Map<String, Bic> _entries;
  const _CachedSyncResolver(this._entries);
  @override
  Bic? resolve(String bankCode) => _entries[bankCode];
}

Map<String, Bic> _parse(Object? decoded) {
  final Map<String, dynamic> map = decoded as Map<String, dynamic>;
  // A bank code maps to an object, never a list, so `banks` being a list
  // unambiguously marks the compact form.
  if (map['banks'] case final List<dynamic> banks) {
    if (map['v'] != 1) {
      throw FormatException('Unsupported bank-code asset version: ${map['v']}');
    }
    return <String, Bic>{
      for (final List<dynamic> row in banks.cast<List<dynamic>>())
        if (_bicFromRow(row) case final Bic bic)
          for (final String code in (row[0] as List<dynamic>).cast<String>())
            code: bic,
    };
  }
  return <String, Bic>{
    for (final MapEntry<String, dynamic> e in map.entries)
      if (_bicFromJson(e.value as Map<String, dynamic>) case final Bic bic)
        e.key: bic,
  };
}

Bic? _bicFromRow(List<dynamic> row) {
  String? at(int i) => i < row.length ? row[i] as String? : null;
  final String bankName = at(2)!;
  return _bic(
    value: at(1),
    bankName: bankName,
    bankShortName: at(3) ?? bankName,
    bankAddress: at(4),
    bankPostcode: at(5),
    bankLocation: at(6),
  );
}

/// Returns `null` for rows without a BIC so lookups report `UnknownBank`
/// instead of a `BicFound` carrying an empty value.
Bic? _bicFromJson(Map<String, dynamic> m) => _bic(
  value: m['bic'] as String?,
  bankName: m['bankName'] as String,
  bankShortName: m['bankShortName'] as String,
  bankAddress: m['bankAddress'] as String?,
  bankPostcode: m['bankPostcode'] as String?,
  bankLocation: m['bankLocation'] as String?,
);

Bic? _bic({
  required String? value,
  required String bankName,
  required String bankShortName,
  String? bankAddress,
  String? bankPostcode,
  String? bankLocation,
}) {
  if (value == null || value.trim().isEmpty) return null;
  return Bic(
    value: value,
    bankName: bankName,
    bankShortName: bankShortName,
    bankAddress: bankAddress,
    bankPostcode: bankPostcode,
    bankLocation: bankLocation,
  );
}
