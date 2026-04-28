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

  String extractBankCode(String normalizedIban) =>
      normalizedIban.substring(bankCodeStart, bankCodeEnd);
}
