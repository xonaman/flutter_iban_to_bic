import 'dart:async';

import 'asset_resolver.dart';
import 'bic.dart';
import 'country_spec.dart';
import 'iban.dart';
import 'resolver.dart';
import 'result.dart';

/// Resolves a BIC from an IBAN using pluggable per-country data.
///
/// Most callers should use the top-level [ibanToBic] (sync, requires
/// [preload]) or [ibanToBicAsync] (no preload needed). Instantiate
/// [IbanToBic] directly only when you want to register a custom
/// [BicResolver] or override the built-in country data.
class IbanToBic {
  final Map<String, CountrySpec> _countries;
  // Preserves the original asset-backed spec per country so [evict] can
  // restore it after [preload] swapped in a sync-cached variant.
  final Map<String, CountrySpec> _assetSpecs = <String, CountrySpec>{};

  IbanToBic({Map<String, CountrySpec>? countries})
      : _countries = countries ?? _buildDefaultCountries() {
    for (final MapEntry<String, CountrySpec> e in _countries.entries) {
      if (e.value.resolver is AssetJsonResolver) {
        _assetSpecs[e.key] = e.value;
      }
    }
  }

  /// Countries supported out of the box.
  Iterable<String> get supportedCountries => _countries.keys;

  /// Eagerly loads the bank-code datasets for [countryCodes] so that
  /// [lookupSync] and the top-level [ibanToBic] can serve them without
  /// awaiting I/O.
  ///
  /// Country codes are case-insensitive. Unknown codes are ignored so a
  /// caller can safely pass `supportedCountries` or its own superset.
  Future<void> preload(Iterable<String> countryCodes) async {
    final List<Future<void>> work = <Future<void>>[];
    for (final String raw in countryCodes) {
      final String code = raw.toUpperCase();
      final CountrySpec? assetSpec = _assetSpecs[code];
      if (assetSpec == null) continue;
      // Already preloaded + swapped — skip the redundant allocations.
      // Matters for call patterns like preload-per-keystroke.
      if (_countries[code]?.resolver is SyncBicResolver) continue;
      final AssetJsonResolver resolver =
          assetSpec.resolver as AssetJsonResolver;
      work.add(resolver.preload().then((void _) {
        // Re-check after the await: a concurrent preload may have
        // already swapped the spec, and we don't want to overwrite it
        // with an equivalent-but-fresh wrapper.
        if (_countries[code]?.resolver is SyncBicResolver) return;
        final SyncBicResolver? synced = resolver.asSync();
        if (synced != null) {
          _countries[code] = CountrySpec(
            bankCodeStart: assetSpec.bankCodeStart,
            bankCodeEnd: assetSpec.bankCodeEnd,
            resolver: synced,
          );
        }
      }));
    }
    await Future.wait<void>(work);
  }

  /// Drops the cached dataset for [countryCode] so its memory can be
  /// reclaimed. After eviction, [lookupSync] will return [NotPreloaded]
  /// for that country until [preload] is awaited again; [lookup] keeps
  /// working and re-reads the asset on the next call.
  ///
  /// No-op for countries that were never preloaded, not asset-backed, or
  /// not registered. Country codes are case-insensitive.
  void evict(String countryCode) {
    final String code = countryCode.toUpperCase();
    final CountrySpec? assetSpec = _assetSpecs[code];
    if (assetSpec == null) return;
    (assetSpec.resolver as AssetJsonResolver).evict();
    // Restore the async spec so lookupSync reports NotPreloaded again.
    _countries[code] = assetSpec;
  }

  /// Resolves the [rawIban] to a [Bic].
  ///
  /// Always returns a [Future] so resolvers are free to hit the network,
  /// a DB, or any other async source.
  Future<IbanLookupResult> lookup(String rawIban) async {
    final _Prelude prelude = _prelude(rawIban);
    if (prelude.earlyResult != null) return prelude.earlyResult!;

    final Bic? bic = await prelude.spec!.resolver.resolve(prelude.bankCode!);
    if (bic == null) {
      return UnknownBank(
        countryCode: prelude.countryCode!,
        bankCode: prelude.bankCode!,
      );
    }
    return BicFound(bic);
  }

  /// Synchronous variant of [lookup].
  ///
  /// Returns [NotPreloaded] if the country's resolver is async (for the
  /// built-in asset-backed resolvers, that means [preload] has not yet been
  /// awaited). Callers that prefer to fail fast can pattern-match on the
  /// result and throw at the call site.
  IbanLookupResult lookupSync(String rawIban) {
    final _Prelude prelude = _prelude(rawIban);
    if (prelude.earlyResult != null) return prelude.earlyResult!;

    final BicResolver resolver = prelude.spec!.resolver;
    if (resolver is! SyncBicResolver) {
      return NotPreloaded(prelude.countryCode!);
    }
    final Bic? bic = resolver.resolve(prelude.bankCode!);
    if (bic == null) {
      return UnknownBank(
        countryCode: prelude.countryCode!,
        bankCode: prelude.bankCode!,
      );
    }
    return BicFound(bic);
  }

  _Prelude _prelude(String rawIban) {
    final String iban = normalizeIban(rawIban);
    final IbanValidation validation = validateIban(iban);
    if (validation is IbanInvalid) {
      return _Prelude.early(InvalidIban(iban, validation.reason));
    }

    final String countryCode = iban.substring(0, 2);
    final CountrySpec? spec = _countries[countryCode];
    if (spec == null) return _Prelude.early(UnsupportedCountry(countryCode));

    return _Prelude.resolved(
      countryCode: countryCode,
      bankCode: spec.extractBankCode(iban),
      spec: spec,
    );
  }
}

class _Prelude {
  final IbanLookupResult? earlyResult;
  final String? countryCode;
  final String? bankCode;
  final CountrySpec? spec;

  const _Prelude.early(this.earlyResult)
      : countryCode = null,
        bankCode = null,
        spec = null;

  const _Prelude.resolved({
    required this.countryCode,
    required this.bankCode,
    required this.spec,
  }) : earlyResult = null;
}

/// Synchronous top-level convenience.
///
/// Throws [StateError] if the country has not been preloaded. Call
/// `await preloadIbanToBic([...])` during app startup for the countries
/// you care about, or use [ibanToBicAsync] to skip preload entirely.
IbanLookupResult ibanToBic(String iban) => _shared.lookupSync(iban);

/// Async top-level convenience, equivalent to `IbanToBic().lookup(iban)`.
/// No preload required.
Future<IbanLookupResult> ibanToBicAsync(String iban) => _shared.lookup(iban);

/// Preload built-in country datasets for the shared instance so
/// [ibanToBic] can serve them synchronously.
Future<void> preloadIbanToBic(Iterable<String> countryCodes) =>
    _shared.preload(countryCodes);

/// Drops a preloaded country dataset on the shared instance, freeing
/// its memory. [ibanToBic] will report [NotPreloaded] for that country
/// until it's preloaded again; [ibanToBicAsync] keeps working.
void evictIbanToBic(String countryCode) => _shared.evict(countryCode);

/// The shared [IbanToBic] used by the top-level convenience functions.
IbanToBic get sharedIbanToBic => _shared;

final IbanToBic _shared = IbanToBic();

const String _assetDir = 'packages/iban_to_bic/assets/bank_codes';

Map<String, CountrySpec> _buildDefaultCountries() {
  Map<String, CountrySpec>? mapOrNull;
  CountrySpec spec(int start, int end, String cc) => CountrySpec(
        bankCodeStart: start,
        bankCodeEnd: end,
        resolver: AssetJsonResolver('$_assetDir/${cc.toLowerCase()}.json'),
      );
  return mapOrNull ??= <String, CountrySpec>{
    'AT': spec(4, 9, 'AT'),
    'BE': spec(4, 7, 'BE'),
    'DE': spec(4, 12, 'DE'),
    'ES': spec(4, 8, 'ES'),
    'FR': spec(4, 9, 'FR'),
    'LT': spec(4, 9, 'LT'),
    'LU': spec(4, 7, 'LU'),
    'NL': spec(4, 8, 'NL'),
  };
}
