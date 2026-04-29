import 'resolver.dart';

/// Where the bank code lives inside a country's IBAN and how to resolve it.
class CountrySpec {
  final int bankCodeStart;
  final int bankCodeEnd;
  final BicResolver resolver;

  const CountrySpec({
    required this.bankCodeStart,
    required this.bankCodeEnd,
    required this.resolver,
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
