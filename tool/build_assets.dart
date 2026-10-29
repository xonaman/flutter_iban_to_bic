// Regenerates the minified runtime assets in `assets/bank_codes/` from the
// canonical sources in `data/bank_codes/`. See `tool/bank_codes.dart` for
// both formats.
//
// Run with:
//   dart run tool/build_assets.dart           # rewrite every asset
//   dart run tool/build_assets.dart --check   # fail if any asset is stale

// ignore_for_file: avoid_print

import 'dart:io';

import 'bank_codes.dart';

void main(List<String> args) {
  final bool check = args.contains('--check');
  final List<String> stale = <String>[];

  for (final String cc in sourceCountries()) {
    final String expected = encodeAsset(readSource(cc));
    final File asset = File(assetPath(cc));
    if (asset.existsSync() && asset.readAsStringSync() == expected) continue;
    if (check) {
      stale.add(asset.path);
    } else {
      asset.writeAsStringSync(expected);
      print('wrote ${asset.path}');
    }
  }

  // An asset whose source was deleted or renamed would otherwise keep
  // shipping unnoticed. Report it rather than deleting it: removing a
  // country also means updating pubspec.yaml and the library.
  final Set<String> sources = sourceCountries().toSet();
  final List<String> orphaned = <String>[
    for (final File f in Directory(assetDir).listSync().whereType<File>())
      if (f.path.endsWith('.json') &&
          !sources.contains(
            f.uri.pathSegments.last.split('.').first.toUpperCase(),
          ))
        f.path,
  ]..sort();
  if (orphaned.isNotEmpty) {
    stderr.writeln(
      'No source in $sourceDir/ for: ${orphaned.join(', ')}\n'
      'Restore the .jsonl source or remove the asset.',
    );
  }

  if (stale.isNotEmpty) {
    stderr.writeln(
      'Out of date: ${stale.join(', ')}\n'
      'Run `dart run tool/build_assets.dart` and commit the result.',
    );
  }
  if (stale.isNotEmpty || orphaned.isNotEmpty) exit(1);
}
