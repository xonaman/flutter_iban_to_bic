## 2.2.0

* `IbanToBic.evict(countryCode)` and top-level `evictIbanToBic(countryCode)`
  drop a preloaded dataset so its memory can be reclaimed. The next
  `lookupSync` for that country returns `NotPreloaded` until it's
  preloaded again; `lookup` keeps working and re-reads the asset.
* `AssetJsonResolver.evict()` exposes the same on a single resolver and
  is safe to call mid-load.
* `preload` on an already-preloaded country is now a true no-op — no
  wrapper allocation or spec churn. Makes preload-per-keystroke patterns
  essentially free.
* A failed `AssetJsonResolver` load no longer latches a rejected future;
  the next `resolve` or `preload` call retries the asset read.
* `normalizeIban` now strips non-breaking spaces (U+00A0) in addition to
  ASCII whitespace — common when IBANs are pasted from bank PDFs.
* `CountrySpec.extractBankCode` returns `null` (surfaced as
  `InvalidIban(badShape)`) instead of throwing `RangeError` when a
  custom spec's `bankCodeEnd` exceeds the IBAN length.
* `IbanToBic(countries: …)` now defensively copies the caller's map so
  later external mutation can't bleed into the resolver.

## 2.1.0

* `IbanToBic.lookupSync` now returns a `NotPreloaded(countryCode)` result
  instead of throwing `StateError` when the country's resolver is async.
  This keeps the sealed-result discipline: every failure mode is
  pattern-matchable and exhaustive.
* Bundesbank BLZ parser factored into a pure `parseBundesbankBlz` function
  and unit-tested against a synthetic fixture — the refresh pipeline no
  longer relies exclusively on a working network for correctness checks.

## 2.0.0

* **Breaking:** Bank-code datasets moved from Dart `const` maps to JSON
  assets. Loading is lazy and cached.
* **Breaking:** The synchronous `ibanToBic` now requires the target country
  to have been preloaded. Either call
  `await preloadIbanToBic(['DE', 'NL', ...])` during app startup, or switch
  to `ibanToBicAsync` which needs no preload.
* `AssetJsonResolver` is a new public resolver; register it manually if you
  want to ship your own JSON dataset.
* Dropped the 8 generated `lib/src/data/*.dart` files — ~1 MB less Dart
  source compiled into every consumer.

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
