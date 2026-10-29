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
  /// short to contain one. Callers treat `null` as `InvalidIban(badShape)`.
  /// Validation already enforces the SWIFT IBAN Registry length for
  /// registered countries, so this is only reachable with a custom spec
  /// whose range doesn't fit the country's IBANs, or for a country the
  /// registry doesn't list.
  String? extractBankCode(String normalizedIban) =>
      normalizedIban.length >= bankCodeEnd
      ? normalizedIban.substring(bankCodeStart, bankCodeEnd)
      : null;
}
