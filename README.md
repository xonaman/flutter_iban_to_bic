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

| Code | Country     | Bank-code offset | Data source | BIC accuracy | Automated refresh |
|------|-------------|------------------|-------------|--------------|-------------------|
| AT   | Austria     | 4–9              | [OeNB](https://www.oenb.at/) SEPA directory | exact | yes (weekly) |
| BE   | Belgium     | 4–7              | [NBB](https://www.nbb.be/en/payments-and-securities/payment-standards/bank-identification-codes) bank identification codes | exact | yes (weekly) |
| DE   | Germany     | 4–12             | [Deutsche Bundesbank](https://www.bundesbank.de/en/tasks/payment-systems/services/bank-sort-codes) BLZ file | exact | yes (weekly) |
| ES   | Spain       | 4–8              | inherited from [sigalor/iban-to-bic](https://github.com/sigalor/iban-to-bic), no official source yet | institution | no (unmaintained) |
| FR   | France      | 4–9              | inherited from [sigalor/iban-to-bic](https://github.com/sigalor/iban-to-bic), no official source yet | institution | no (unmaintained) |
| LT   | Lithuania   | 4–9              | inherited from [sigalor/iban-to-bic](https://github.com/sigalor/iban-to-bic), no official source yet | exact | no (unmaintained) |
| LU   | Luxembourg  | 4–7              | [ABBL](https://www.abbl.lu/) IBAN/BIC register | exact | yes (weekly) |
| NL   | Netherlands | 4–8              | [Betaalvereniging](https://www.betaalvereniging.nl/) BIC list | exact | yes (weekly) |

**BIC accuracy** is reported on every `BicFound` as `accuracy`
(`BicAccuracy.exact` or `BicAccuracy.institution`, with an `isExact`
shortcut):

* **exact** — the IBAN has no branch code, and the national directory assigns
  one BIC per bank code, so the result is the account's BIC (as of the
  dataset's date). The Bundesbank, for example, requires each BLZ's main
  record to carry a BIC that reaches the institution in every SEPA scheme.
* **institution** — the IBAN carries a branch code after the bank code
  (Spain: *oficina*, France: *code guichet*) that the lookup does not use.
  The result is the institution's main BIC, which SEPA payments to that
  institution generally accept, but the account may be held under a branch
  BIC. Every La Banque Postale IBAN starts with bank code `20041`, for
  instance, yet accounts are held at regional centres with BICs such as
  `PSSTFRPPPAR` (Paris) or `PSSTFRPPLIL` (Lille); the lookup returns
  `PSSTFRPPXXX`. Don't present such a BIC to users as verified for their
  account.

```dart
if (result case BicFound(:final bic, isExact: false)) {
  print('${bic.value} identifies the bank; the branch BIC may differ.');
}
```

If you register your own `CountrySpec`, pass `accuracy:` to match your data
(it defaults to `BicAccuracy.exact`).
