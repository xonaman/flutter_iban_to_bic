## 1.1.0

* `BicResolver.resolve` now returns `FutureOr<Bic?>`. Pure sync resolvers
  implement the new `SyncBicResolver` marker interface; the top-level
  `ibanToBic` stays synchronous because every built-in country ships one.
* Added `ibanToBicAsync` and `IbanToBic.lookup` (async) for callers whose
  resolvers hit the network/DB/etc.; `IbanToBic.lookupSync` keeps the fast path.
* `InvalidIban` now carries a structured `reason` (`empty`, `tooShort`,
  `tooLong`, `badShape`, `badChecksum`) so callers can render better errors.
* `Bic` exposes ISO 9362 parts as getters: `institutionCode`, `countryCode`,
  `locationCode`, `branchCode`, plus `isWellFormed`.

## 1.0.0

* **Breaking:** `ibanToBic` now returns a sealed `IbanLookupResult`
  (`BicFound` / `InvalidIban` / `UnsupportedCountry` / `UnknownBank`) instead of
  throwing. Pattern-match on the result.
* Removed the `iban` package dependency; IBAN validation is now a ~30-line
  inline mod-97 implementation.
* Reshaped internals into a pluggable `BicResolver` + `CountrySpec` registry
  so custom data sources can be injected via `IbanToBic(countries: …)`.
* Replaced `part`/`part of` with proper library files and exports.
* Bumped minimum Dart SDK to 3.0 (required for sealed/pattern matching).

## 0.1.0

* Merged [PR from @davidmigloz](https://github.com/xonaman/flutter_iban_to_bic/pull/1)

## 0.0.8

* added some code documentation

## 0.0.7

* upgraded dependencies

## 0.0.6

* renamed Iban class to "Bic"
* Bic.bankName & bankShortName are never null

## 0.0.5

* added support for LT ibans
* returns an Iban object instead a Future<String> object
* Iban object holds bic, bank name, bank address, bank postcode and bank location (if available)

## 0.0.1

* first release
