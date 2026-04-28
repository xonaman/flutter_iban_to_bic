Determines the SWIFT BIC of an IBAN. Currently supports IBANs from the following countries:
Austria, Belgium, Germany, Spain, France, Lithuania, Luxembourg, Netherlands. Inspired by
[sigalor/iban-to-bic](https://github.com/sigalor/iban-to-bic).

## Getting started

### Depend on it

```
flutter pub add iban_to_bic
```

### Import it

```dart
import 'package:iban_to_bic/iban_to_bic.dart';
```

## Usage

`ibanToBic` returns a sealed `IbanLookupResult`. Pattern-match on it to handle
every case exhaustively — no exceptions, no surprise nulls:

```dart
import 'package:iban_to_bic/iban_to_bic.dart';

void main() {
  final result = ibanToBic('DE64 5001 0517 9423 8144 35');

  switch (result) {
    case BicFound(:final bic):
      print(bic.value);           // INGDDEFFXXX
      print(bic.bankShortName);   // ING-DiBa
      print(bic.bankLocation);    // Frankfurt am Main
    case InvalidIban(:final iban):
      print('Checksum failed: $iban');
    case UnsupportedCountry(:final countryCode):
      print('No data for: $countryCode');
    case UnknownBank(:final countryCode, :final bankCode):
      print('Unknown bank $bankCode in $countryCode');
  }
}
```

## Extending with custom data

Register a custom `BicResolver` to plug in your own data source — a corporate
registry, a remote API, or an overlay on top of the built-in maps:

```dart
class MyResolver implements BicResolver {
  @override
  Bic? resolve(String bankCode) => /* your lookup */;
}

final customCountries = {
  'DE': CountrySpec(
    bankCodeStart: 4,
    bankCodeEnd: 12,
    resolver: MyResolver(),
  ),
};

final lookup = IbanToBic(countries: customCountries);
lookup.lookup('DE64 5001 0517 9423 8144 35');
```

## Supported countries

| Code | Country     | Bank-code offset |
|------|-------------|------------------|
| AT   | Austria     | 4–9              |
| BE   | Belgium     | 4–7              |
| DE   | Germany     | 4–12             |
| ES   | Spain       | 4–8              |
| FR   | France      | 4–9              |
| LT   | Lithuania   | 4–9              |
| LU   | Luxembourg  | 4–7              |
| NL   | Netherlands | 4–8              |
