import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'bic.dart';
import 'resolver.dart';

/// Resolves bank codes by lazily loading a per-country JSON asset.
///
/// The first `resolve` call awaits asset loading and parsing. After that,
/// results are served from an in-memory cache — subsequent calls complete
/// synchronously from the caller's perspective, but the return type stays
/// `Future<Bic?>` to keep the API coherent.
///
/// Call [preload] up front (e.g. from `main()`) if you want [IbanToBic]'s
/// synchronous `lookupSync` path to work for this country.
class AssetJsonResolver implements BicResolver {
  final String assetPath;
  final AssetBundle _bundle;

  Map<String, Bic>? _cache;
  Future<Map<String, Bic>>? _inFlight;

  AssetJsonResolver(this.assetPath, {AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  /// Loads the asset into the cache. Idempotent + deduplicated.
  Future<void> preload() async {
    await _load();
  }

  /// Upgrades to a [SyncBicResolver] once [preload] has completed.
  ///
  /// Returns `null` if the asset hasn't finished loading yet.
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
    return _inFlight ??= _bundle.loadString(assetPath).then((String raw) {
      final Map<String, dynamic> decoded =
          json.decode(raw) as Map<String, dynamic>;
      final Map<String, Bic> parsed = <String, Bic>{
        for (final MapEntry<String, dynamic> e in decoded.entries)
          e.key: _bicFromJson(e.value as Map<String, dynamic>),
      };
      _cache = parsed;
      _inFlight = null;
      return parsed;
    });
  }
}

class _CachedSyncResolver implements SyncBicResolver {
  final Map<String, Bic> _entries;
  const _CachedSyncResolver(this._entries);
  @override
  Bic? resolve(String bankCode) => _entries[bankCode];
}

Bic _bicFromJson(Map<String, dynamic> m) => Bic(
      value: m['bic'] as String,
      bankName: m['bankName'] as String,
      bankShortName: m['bankShortName'] as String,
      bankAddress: m['bankAddress'] as String?,
      bankPostcode: m['bankPostcode'] as String?,
      bankLocation: m['bankLocation'] as String?,
    );
