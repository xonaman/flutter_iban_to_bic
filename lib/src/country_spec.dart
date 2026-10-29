import 'bic_accuracy.dart';
import 'resolver.dart';
import 'result.dart' show BicFound;

/// Where the bank code lives inside a country's IBAN and how to resolve it.
class CountrySpec {
  final int bankCodeStart;
  final int bankCodeEnd;
  final BicResolver resolver;

  /// How precisely a bank code in this country determines the account's
  /// BIC. Copied onto every [BicFound] the lookup returns for the country.
  ///
  /// Defaults to [BicAccuracy.exact]. Set it to [BicAccuracy.institution]
  /// when [resolver] only knows one BIC per institution but accounts may
  /// be held under branch BICs.
  final BicAccuracy accuracy;

  const CountrySpec({
    required this.bankCodeStart,
    required this.bankCodeEnd,
    required this.resolver,
    this.accuracy = BicAccuracy.exact,
  });

  /// Returns the bank-code slice, or `null` when [normalizedIban] is too
  /// short to contain one. Callers treat `null` as `InvalidIban(badShape)`
  /// — this is only reachable when a country's IBAN is shorter than its
  /// advertised bank-code range, which the shape regex can't catch on its
  /// own (it only validates character classes, not country-specific lengths).
  String? extractBankCode(String normalizedIban) =>
      normalizedIban.length >= bankCodeEnd
      ? normalizedIban.substring(bankCodeStart, bankCodeEnd)
      : null;
}
