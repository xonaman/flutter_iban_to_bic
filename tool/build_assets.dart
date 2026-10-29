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

  if (stale.isNotEmpty) {
    stderr.writeln(
      'Out of date: ${stale.join(', ')}\n'
      'Run `dart run tool/build_assets.dart` and commit the result.',
    );
    exit(1);
  }
}
