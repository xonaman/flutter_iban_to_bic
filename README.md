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
    case InvalidIban(:final iban, :final reason):
      print('Invalid ($reason): $iban');
    case UnsupportedCountry(:final countryCode):
      print('No data for: $countryCode');
    case UnknownBank(:final countryCode, :final bankCode):
      print('Unknown bank $bankCode in $countryCode');
  }
}
```

## Sync vs. async

Bank-code datasets ship as JSON assets and are loaded lazily, so the default
path is async. Two APIs:

```dart
// Async — no setup required:
final result = await ibanToBicAsync('DE64 5001 0517 9423 8144 35');

// Sync — call preload first (e.g. from main()):
await preloadIbanToBic(['DE', 'NL']);
final result = ibanToBic('DE64 5001 0517 9423 8144 35');
```

Calling the sync `ibanToBic` for a country that hasn't been preloaded throws
`StateError`. If startup latency matters more than first-call latency,
preload; otherwise just use the async variant.

## Extending with custom data

Implement `SyncBicResolver` for in-memory data, or `BicResolver` (returns
`FutureOr<Bic?>`) for async sources — an overlay on top of the built-in maps,
a corporate registry, the ECB directory, etc.

```dart
class EcbResolver implements BicResolver {
  @override
  Future<Bic?> resolve(String bankCode) async =>
      await httpClient.fetchBic(bankCode);
}

final lookup = IbanToBic(countries: {
  'DE': CountrySpec(
    bankCodeStart: 4,
    bankCodeEnd: 12,
    resolver: EcbResolver(),
  ),
});
await lookup.lookup('DE64 5001 0517 9423 8144 35');
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
