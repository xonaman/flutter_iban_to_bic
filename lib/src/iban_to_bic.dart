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

  IbanToBic({Map<String, CountrySpec>? countries})
      : _countries = countries ?? _buildDefaultCountries();

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
      final CountrySpec? spec = _countries[code];
      final BicResolver? resolver = spec?.resolver;
      if (resolver is AssetJsonResolver) {
        work.add(resolver.preload().then((void _) {
          // Swap the country's resolver for its sync-cached variant so
          // lookupSync stops failing the SyncBicResolver check.
          final SyncBicResolver? synced = resolver.asSync();
          if (synced != null) {
            _countries[code] = CountrySpec(
              bankCodeStart: spec!.bankCodeStart,
              bankCodeEnd: spec.bankCodeEnd,
              resolver: synced,
            );
          }
        }));
      }
    }
    await Future.wait<void>(work);
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
