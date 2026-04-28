import 'bic.dart';
import 'iban.dart';

/// Outcome of an IBAN-to-BIC lookup.
///
/// Use exhaustive pattern matching:
/// ```dart
/// switch (result) {
///   BicFound(:final bic) => print(bic.value),
///   InvalidIban(:final reason) => print('invalid: $reason'),
///   UnsupportedCountry(:final countryCode) => print('no data for $countryCode'),
///   UnknownBank(:final bankCode) => print('unknown bank: $bankCode'),
/// }
/// ```
sealed class IbanLookupResult {
  const IbanLookupResult();
}

final class BicFound extends IbanLookupResult {
  final Bic bic;
  const BicFound(this.bic);
}

final class InvalidIban extends IbanLookupResult {
  final String iban;
  final InvalidIbanReason reason;
  const InvalidIban(this.iban, this.reason);
}

final class UnsupportedCountry extends IbanLookupResult {
  final String countryCode;
  const UnsupportedCountry(this.countryCode);
}

final class UnknownBank extends IbanLookupResult {
  final String countryCode;
  final String bankCode;
  const UnknownBank({required this.countryCode, required this.bankCode});
}

/// Returned by `IbanToBic.lookupSync` when the country's dataset has not
/// been preloaded yet. Call `preload([countryCode])` and retry, or switch
/// to the async `lookup`.
final class NotPreloaded extends IbanLookupResult {
  final String countryCode;
  const NotPreloaded(this.countryCode);
}
