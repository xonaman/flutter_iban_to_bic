import 'bic.dart';

/// Strategy for mapping a national bank code to a [Bic].
///
/// Implement this to plug in custom data sources (e.g. a network fetch
/// or an in-house corporate registry).
abstract interface class BicResolver {
  Bic? resolve(String bankCode);
}

/// Backed by an in-memory const map — used by every built-in country dataset.
class StaticMapResolver implements BicResolver {
  final Map<String, Bic> _entries;
  const StaticMapResolver(this._entries);

  @override
  Bic? resolve(String bankCode) => _entries[bankCode];
}
