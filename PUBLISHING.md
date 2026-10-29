# Publishing

`iban_to_bic` publishes to [pub.dev](https://pub.dev) automatically from GitHub
Actions using pub.dev's trusted-publisher OIDC flow. No long-lived tokens or
`PUB_TOKEN` secrets are stored in GitHub.

## One-time setup (pub.dev side)

Do this once, as a package owner on pub.dev.

1. Publish an initial version manually (if the package has never been
   published):
   ```bash
   dart pub publish
   ```
2. Visit `https://pub.dev/packages/iban_to_bic/admin`.
3. Under **Automated publishing**, click **Enable publishing from GitHub
   Actions**.
4. Fill in:
   - **Repository**: `xonaman/flutter_iban_to_bic`
   - **Tag pattern**: `v{{version}}`
   - **Require GitHub Actions environment**: leave blank (or set one if you
     want an extra approval gate)

Once saved, pushes of a tag matching the pattern will be trusted to publish.

## Cutting a release

1. Make sure `main` is green on CI.
2. Bump `version:` in `pubspec.yaml` and add a `CHANGELOG.md` entry.
3. Commit and merge to `main`.
4. Tag and push:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
5. The `Publish to pub.dev` workflow runs and:
   - Verifies the tag matches `pubspec.yaml`
   - Runs format, analyze, tests, and `pub publish --dry-run`
   - Checks that `CHANGELOG.md` has a `## <version>` entry
   - Publishes via OIDC
   - Creates a GitHub release for the tag, using that `CHANGELOG.md`
     entry as the release notes (tags with a `-` suffix, like
     `v1.2.3-beta.1`, become pre-releases)

If the workflow fails the version-match check, delete the tag locally and
remotely, fix `pubspec.yaml`, and retag.

## Data refresh

`.github/workflows/refresh-data.yml` runs every Monday 04:00 UTC (or
manually via `workflow_dispatch`). It invokes `tool/refresh_data.dart`
against each country's authoritative upstream, runs the test suite
against the new data, and opens a PR with the diff if anything changed.

### One-time setup

- Nothing for Germany: the script finds the current BLZ file on the
  Bundesbank download page, so new quarterly files (December, March, June,
  September) are picked up by the next weekly run once they're in force.
  Set a repo-level variable `BUNDESBANK_BLZ_URL`
  (`Settings → Secrets and variables → Actions → Variables`) only to pin a
  specific file; delete it again afterwards or it keeps overriding the
  lookup.
- Nothing for the other adapters either. Each reads a fixed URL or finds
  the current file on the publisher's page, and each has an optional
  override variable, set the same way and only to pin a file:

  | Country | Source | Override variable |
  |---------|--------|-------------------|
  | AT | [OeNB SEPA directory](https://www.oenb.at/Statistik/Klassifikationen/SEPA-Zahlungsverkehrs-Verzeichnis.html) (fixed URL) | `OENB_SEPA_URL` |
  | BE | [NBB bank identification codes](https://www.nbb.be/en/payments-and-securities/payment-standards/bank-identification-codes) (fixed URL) | `NBB_BIC_URL` |
  | DE | [Bundesbank BLZ file](https://www.bundesbank.de/en/tasks/payment-systems/services/bank-sort-codes) (looked up) | `BUNDESBANK_BLZ_URL` |
  | LU | [ABBL IBAN/BIC register](https://www.abbl.lu/publications/abbl-luxembourg-register-of-iban-bic-codes/) (looked up) | `ABBL_IBAN_BIC_URL` |
  | NL | [Betaalvereniging BIC list](https://www.betaalvereniging.nl/kennisbank/iban-en-bic/) (looked up) | `BETAALVERENIGING_BIC_URL` |

- ES, FR and LT have no adapter and their datasets are **unmaintained**:
  no authoritative source publishes their bank codes with BICs in a form a
  script can download (see the comment above `adapters` in
  `tool/refresh_data.dart`). Changes to them have to be made by hand.
- When adding a new country adapter in `tool/refresh_data.dart`, register
  any additional repo variables it needs the same way and reference them
  under `env:` in the workflow.

### Adding a country

1. Add an adapter function in `tool/refresh_data.dart`.
2. Register it in the `adapters` map.
3. Make sure `assets/bank_codes/<cc>.json` is listed in `pubspec.yaml`.
4. Give it a pure parser with a test against a small fixture in
   `test/fixtures/` (see `test/refresh_data_test.dart`).

## CI

Every push and PR to `main` runs `.github/workflows/ci.yml`:

- Flutter **stable** and **beta** channels in parallel
- `dart format --set-exit-if-changed`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
- `dart pub publish --dry-run` on stable — catches score/lint issues before
  a release is cut
