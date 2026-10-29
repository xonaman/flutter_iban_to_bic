## Unreleased

* IBANs are now validated against the SWIFT IBAN Registry: an IBAN from a
  registered country must have exactly that country's length (e.g. 22 for
  DE) and a BBAN in its registered format (e.g. four letters, then ten
  digits for NL). Wrong lengths report `InvalidIbanReason.tooShort` or
  `tooLong`, and a BBAN in the wrong format reports `badShape`. Before,
  any 15-34 character IBAN with a valid checksum passed, so a German IBAN
  with a digit missing could still reach the bank-code lookup. Countries
  missing from the registry keep the old 15-34 rule. No new enum values,
  so exhaustive `switch`es over `InvalidIbanReason` keep compiling.
* The built-in countries' bank-code positions now come from a table
  generated from the registry (`lib/src/iban_registry.g.dart`) instead of
  hand-coded offsets. The values are unchanged. Regenerate it with
  `dart run tool/generate_iban_registry.dart <iban-registry.txt>`.
* Results now say how precise the BIC is. `BicFound` gains an `accuracy`
  field (`BicAccuracy.exact` or `BicAccuracy.institution`) and an `isExact`
  getter. Spain and France report `institution`: their IBANs carry a branch
  code the lookup ignores, so the returned BIC is the institution's main
  BIC and the account may be held under a branch BIC (La Banque Postale,
  for example). All other built-in countries report `exact`.
* `CountrySpec` takes an optional `accuracy` (default `exact`) so custom
  resolvers can declare theirs.
* README: the supported-countries table now lists each country's data
  source, BIC accuracy and whether it is refreshed automatically.
* Non-breaking: `BicFound(bic)` still compiles and defaults to `exact`, and
  the sealed `IbanLookupResult` hierarchy is unchanged.

## 2.3.0

* Requires Dart 3.8 / Flutter 3.32 or newer (was Dart 3.0). The dev
  toolchain (`flutter_lints` 6) already needed Dart 3.8, so the old floor
  was never actually tested. CI now also runs against Flutter 3.32.0 to
  keep the floor accurate. Sources are reformatted with the Dart 3.7+
  formatter; no API changes.
* `tool/refresh_data.dart`: the German adapter now reads the current BLZ
  file's URL off the Bundesbank download page, so the weekly refresh
  workflow picks up the December 2026 and March 2027 files (and later
  ones) without anyone rotating `BUNDESBANK_BLZ_URL` by hand. The
  variable still works as an override.
* Regenerated bank codes from the official sources (as of October 2026):
  * Austria (OeNB SEPA directory, 29 Oct 2026): 866 entries (was 843).
    Adds Trade Republic, Scalable Capital and A1 Bank, follows the
    Raiffeisen NÖ-Wien mergers, and drops two entries whose BIC was the
    literal string `"None"`.
  * Belgium (NBB, 1 Sep 2026): 771 entries (was 781). Former AXA Bank and
    bpost ranges resolve to their new banks or are gone; adds bunq, Swan
    and Atlantic Money. Codes without a Dutch name now carry the French
    name instead of an empty `bankName`.
  * Luxembourg (ABBL IBAN/BIC register, Aug 2026): 134 entries (was 135),
    with Credit Suisse, Keytrade and Fideuram removed and newly assigned
    codes added.
  * Netherlands (Betaalvereniging, 27 Oct 2026): 96 entries (was 80),
    including Buckaroo, ClearBank and Goldman Sachs.
  * Germany is unchanged; it already matches the Bundesbank file valid
    until 6 Dec 2026.

## 2.2.1

* Dataset rows with an empty or whitespace-only `bic` now resolve as
  `UnknownBank`. Previously `lookup` and `lookupSync` returned
  `BicFound` with an empty `Bic.value` for them.
* `tool/refresh_data.dart`: the Bundesbank BLZ parser read the BIC from
  columns 135-145, which hold the 5-digit PAN followed by only the first
  six BIC characters (e.g. `27100DEUTDE`). It now reads columns 140-150.
* German bank codes regenerated from the Bundesbank BLZ file valid
  2026-09-07 to 2026-12-06. `de.json` now has 3,505 entries, all with a
  BIC, postcode and city. Before, only 1,705 of its 3,544 entries had a
  BIC, so major banks such as Deutsche Bank (50070010), Commerzbank
  (37040044) and DKB (12030000) came back without one. 35 bank codes the
  Bundesbank no longer lists (merged or closed institutions) now resolve
  as `UnknownBank`.
* Removed the 34 Belgian entries without a BIC from `be.json`.

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
