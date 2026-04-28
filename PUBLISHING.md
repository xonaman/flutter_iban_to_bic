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
   - Publishes via OIDC

If the workflow fails the version-match check, delete the tag locally and
remotely, fix `pubspec.yaml`, and retag.

## CI

Every push and PR to `main` runs `.github/workflows/ci.yml`:

- Flutter **stable** and **beta** channels in parallel
- `dart format --set-exit-if-changed`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
- `dart pub publish --dry-run` on stable — catches score/lint issues before
  a release is cut
