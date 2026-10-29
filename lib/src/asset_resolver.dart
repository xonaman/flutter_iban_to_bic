import 'json_resolver.dart';

/// Resolves bank codes from a JSON file in a Flutter `AssetBundle`.
///
/// The package no longer depends on Flutter, and its own datasets are no
/// longer Flutter assets, so this can't default to `rootBundle` any more:
/// pass it as [bundle]. Prefer [LazyJsonResolver], which takes any loader:
///
/// ```dart
/// LazyJsonResolver(() => rootBundle.loadString('assets/my_banks.json'))
/// ```
@Deprecated(
  'Use LazyJsonResolver(() => rootBundle.loadString(assetPath)) instead. '
  'AssetJsonResolver will be removed in the next major release.',
)
class AssetJsonResolver extends LazyJsonResolver {
  final String assetPath;

  /// [bundle] must be a Flutter `AssetBundle` (anything with a
  /// `Future<String> loadString(String key)` method). It's typed as
  /// [Object] so this package doesn't need to depend on Flutter.
  ///
  /// Without a [bundle], every load fails with a [StateError].
  AssetJsonResolver(this.assetPath, {Object? bundle})
    : super(() => _loadString(bundle, assetPath));

  static Future<String> _loadString(Object? bundle, String assetPath) async {
    if (bundle == null) {
      throw StateError(
        'AssetJsonResolver("$assetPath") needs a bundle now that '
        'iban_to_bic no longer depends on Flutter. Pass bundle: rootBundle, '
        'or use LazyJsonResolver(() => rootBundle.loadString(...)).',
      );
    }
    return await (bundle as dynamic).loadString(assetPath) as String;
  }
}
