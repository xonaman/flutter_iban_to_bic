import 'dart:async';

import 'bic.dart';

/// Strategy for mapping a national bank code to a [Bic].
///
/// Returns a [FutureOr] so implementations are free to be fully synchronous
/// (const maps, preloaded caches) or asynchronous (network, DB, platform
/// channels). A resolver that is synchronous *must* implement [SyncBicResolver]
/// so that [IbanToBic.lookupSync] can fast-path without scheduling microtasks.
abstract interface class BicResolver {
  FutureOr<Bic?> resolve(String bankCode);
}

/// Marker interface for resolvers that never return a [Future].
///
/// Implementing this signals to [IbanToBic] that [resolve] may be called from
/// a synchronous context and the result cast directly.
abstract interface class SyncBicResolver extends BicResolver {
  @override
  Bic? resolve(String bankCode);
}

/// Backed by an in-memory const map — used by every built-in country dataset.
class StaticMapResolver implements SyncBicResolver {
  final Map<String, Bic> _entries;
  const StaticMapResolver(this._entries);

  @override
  Bic? resolve(String bankCode) => _entries[bankCode];
}
