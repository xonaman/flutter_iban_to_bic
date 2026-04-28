import 'dart:async';

import 'bic.dart';
import 'country_spec.dart';
import 'data/at.dart';
import 'data/be.dart';
import 'data/de.dart';
import 'data/es.dart';
import 'data/fr.dart';
import 'data/lt.dart';
import 'data/lu.dart';
import 'data/nl.dart';
import 'iban.dart';
import 'resolver.dart';
import 'result.dart';

/// Resolves a BIC from an IBAN using pluggable per-country data.
///
/// Most callers should use the top-level [ibanToBic] function. Instantiate
/// [IbanToBic] directly only when you want to register a custom [BicResolver]
/// or override the built-in country data.
class IbanToBic {
  final Map<String, CountrySpec> _countries;

  IbanToBic({Map<String, CountrySpec>? countries})
      : _countries = countries ?? _defaultCountries;

  /// Countries supported out of the box.
  Iterable<String> get supportedCountries => _countries.keys;

  /// Resolves the [rawIban] to a [Bic].
  ///
  /// Always returns a [Future] so resolvers are free to hit the network,
  /// a DB, or any other async source. Use [lookupSync] when you know every
  /// registered resolver is synchronous.
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
  /// Throws [StateError] if the country's resolver is not a [SyncBicResolver].
  /// Use this for hot paths where you control the registered resolvers.
  IbanLookupResult lookupSync(String rawIban) {
    final _Prelude prelude = _prelude(rawIban);
    if (prelude.earlyResult != null) return prelude.earlyResult!;

    final BicResolver resolver = prelude.spec!.resolver;
    if (resolver is! SyncBicResolver) {
      throw StateError(
        'lookupSync called for country ${prelude.countryCode} but its '
        'resolver (${resolver.runtimeType}) is asynchronous. Use lookup().',
      );
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

  /// Shared validation + country lookup used by both sync and async paths.
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

/// Sync convenience wrapper around the default [IbanToBic].
///
/// Safe because every built-in country ships a [SyncBicResolver]. If you
/// register an async resolver, call [IbanToBic.lookup] instead.
IbanLookupResult ibanToBic(String iban) => _shared.lookupSync(iban);

/// Async convenience wrapper, equivalent to `IbanToBic().lookup(iban)`.
Future<IbanLookupResult> ibanToBicAsync(String iban) => _shared.lookup(iban);

final IbanToBic _shared = IbanToBic();

const Map<String, CountrySpec> _defaultCountries = <String, CountrySpec>{
  'AT': CountrySpec(
    bankCodeStart: 4,
    bankCodeEnd: 9,
    resolver: StaticMapResolver(atBankCodes),
  ),
  'BE': CountrySpec(
    bankCodeStart: 4,
    bankCodeEnd: 7,
    resolver: StaticMapResolver(beBankCodes),
  ),
  'DE': CountrySpec(
    bankCodeStart: 4,
    bankCodeEnd: 12,
    resolver: StaticMapResolver(deBankCodes),
  ),
  'ES': CountrySpec(
    bankCodeStart: 4,
    bankCodeEnd: 8,
    resolver: StaticMapResolver(esBankCodes),
  ),
  'FR': CountrySpec(
    bankCodeStart: 4,
    bankCodeEnd: 9,
    resolver: StaticMapResolver(frBankCodes),
  ),
  'LT': CountrySpec(
    bankCodeStart: 4,
    bankCodeEnd: 9,
    resolver: StaticMapResolver(ltBankCodes),
  ),
  'LU': CountrySpec(
    bankCodeStart: 4,
    bankCodeEnd: 7,
    resolver: StaticMapResolver(luBankCodes),
  ),
  'NL': CountrySpec(
    bankCodeStart: 4,
    bankCodeEnd: 8,
    resolver: StaticMapResolver(nlBankCodes),
  ),
};
