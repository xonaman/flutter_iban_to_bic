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
| AT   | Austria     | 4–9              | [OeNB](https://www.oenb.at/) SEPA directory | exact | no (manual) |
| BE   | Belgium     | 4–7              | [NBB](https://www.nbb.be/en/payments-and-securities/payment-standards/bank-identification-codes) bank identification codes | exact | no (manual) |
| DE   | Germany     | 4–12             | [Deutsche Bundesbank](https://www.bundesbank.de/en/tasks/payment-systems/services/bank-sort-codes) BLZ file | exact | yes (weekly) |
| ES   | Spain       | 4–8              | inherited from [sigalor/iban-to-bic](https://github.com/sigalor/iban-to-bic), no official source yet | institution | no |
| FR   | France      | 4–9              | inherited from [sigalor/iban-to-bic](https://github.com/sigalor/iban-to-bic), no official source yet | institution | no |
| LT   | Lithuania   | 4–9              | not recorded (added in 0.0.5), no official source yet | exact | no |
| LU   | Luxembourg  | 4–7              | [ABBL](https://www.abbl.lu/) IBAN/BIC register | exact | no (manual) |
| NL   | Netherlands | 4–8              | [Betaalvereniging](https://www.betaalvereniging.nl/) BIC list | exact | no (manual) |

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

## Data sources & licences

The code is MIT-licensed. The bank-code datasets in `assets/bank_codes/` are
not: they come from the publishers below, whose terms apply to them. See
[`NOTICE`](NOTICE) for the full attribution text and links.

| Code   | Source | Terms (summary) |
|--------|--------|-----------------|
| AT     | [OeNB SEPA directory](https://www.oenb.at/docroot/downloads_observ/sepa-zv-vz_gesamt.csv) | [CC BY 4.0](https://www.oenb.at/serviceportal/impressum-und-haftung.html), credit the OeNB |
| BE     | [NBB bank identification codes](https://www.nbb.be/en/payments-and-securities/bank-identification-codes) | [Free use](https://www.nbb.be/en/disclaimer-and-legal-information/copyright-and-use-information), credit the NBB |
| DE     | [Bundesbank BLZ file](https://www.bundesbank.de/en/tasks/payment-systems/services/bank-sort-codes) | [Free use, unaltered](https://www.bundesbank.de/en/homepage/user-information/conditions-for-the-general-use-of-the-website-764706), "Quelle: Deutsche Bundesbank" |
| ES, FR | [ECB list of MFIs](https://www.ecb.europa.eu/stats/financial_corporations/list_of_financial_institutions/html/index.en.html), via [sigalor/iban-to-bic](https://github.com/sigalor/iban-to-bic) (2024) | [Free use](https://www.ecb.europa.eu/services/disclaimer/html/index.en.html), credit the ECB |
| LT     | Not recorded; most likely the [Bank of Lithuania code list](https://www.lb.lt/en/iban-and-financial-institution-codes) | Not yet established |
| LU     | [ABBL IBAN-BIC register](https://www.abbl.lu/luxembourg-register-of-iban-bic-codes/) | [Reference use, unmodified](https://www.abbl.lu/legal-notice/), credit the ABBL; redistribution not addressed |
| NL     | [Betaalvereniging BIC list](https://www.betaalvereniging.nl/en/knowledge-base/iban-and-bic/bic-code/) | [Personal, non-commercial use](https://www.betaalvereniging.nl/en/disclaimer/); redistribution needs written consent |

The data is provided as published, without warranty. If you need guaranteed
coverage or redistribution rights, plug in your own data with a custom
`BicResolver` (see [Extending with custom data](#extending-with-custom-data)).
