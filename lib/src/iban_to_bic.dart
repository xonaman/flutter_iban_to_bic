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

  /// Resolves the [rawIban] to a [Bic], returning a sealed [IbanLookupResult].
  IbanLookupResult lookup(String rawIban) {
    final String iban = normalizeIban(rawIban);
    if (!isValidIban(iban)) return InvalidIban(iban);

    final String countryCode = iban.substring(0, 2);
    final CountrySpec? spec = _countries[countryCode];
    if (spec == null) return UnsupportedCountry(countryCode);

    final String bankCode = spec.extractBankCode(iban);
    final Bic? bic = spec.resolver.resolve(bankCode);
    if (bic == null) {
      return UnknownBank(countryCode: countryCode, bankCode: bankCode);
    }
    return BicFound(bic);
  }
}

/// Convenience wrapper around the default [IbanToBic].
///
/// Returns a sealed [IbanLookupResult]: pattern-match on the result to access
/// the resolved [Bic] or handle the error cases exhaustively.
IbanLookupResult ibanToBic(String iban) => _shared.lookup(iban);

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
