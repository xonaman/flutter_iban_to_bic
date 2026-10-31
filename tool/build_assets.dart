// Regenerates the runtime datasets in `lib/src/data/<cc>.g.dart` from the
// canonical sources in `data/bank_codes/`, updates each rewritten dataset's
// hash in `data/bank_codes/meta.json`, and regenerates
// `lib/src/data/meta.g.dart` from it. See `tool/bank_codes.dart` and
// `tool/dataset_meta.dart` for the formats.
//
// Run with:
//   dart run tool/build_assets.dart           # rewrite every dataset
//   dart run tool/build_assets.dart --check   # fail if any is stale

// ignore_for_file: avoid_print

import 'dart:io';

import 'bank_codes.dart';
import 'dataset_meta.dart';

void main(List<String> args) {
  final bool check = args.contains('--check');
  final List<String> stale = <String>[];

  for (final String cc in sourceCountries()) {
    final Map<String, BankEntry> entries = readSource(cc);
    final String expected = encodeLibrary(cc, entries);
    final File asset = File(libraryPath(cc));
    if (asset.existsSync() && asset.readAsStringSync() == expected) continue;
    if (check) {
      stale.add(asset.path);
    } else {
      asset.writeAsStringSync(expected);
      print('wrote ${asset.path}');
      updateMetaHash(cc, datasetJson(entries));
    }
  }

  final String expectedMeta = encodeMetaLibrary(readMeta());
  final File metaLibrary = File(metaLibraryPath);
  if (!metaLibrary.existsSync() ||
      metaLibrary.readAsStringSync() != expectedMeta) {
    if (check) {
      stale.add(metaLibraryPath);
    } else {
      metaLibrary.writeAsStringSync(expectedMeta);
      print('wrote $metaLibraryPath');
    }
  }

  // A dataset whose source was deleted or renamed would otherwise keep
  // shipping unnoticed. Report it rather than deleting it: removing a
  // country also means updating lib/src/data/bank_codes.dart and
  // _buildDefaultCountries.
  final Set<String> sources = sourceCountries().toSet();
  final List<String> orphaned = <String>[
    for (final File f in Directory(libraryDir).listSync().whereType<File>())
      if (f.path.endsWith('.g.dart') &&
          // Provenance for all countries, not a dataset.
          f.uri.pathSegments.last != metaLibraryPath.split('/').last &&
          !sources.contains(
            f.uri.pathSegments.last.split('.').first.toUpperCase(),
          ))
        f.path,
  ]..sort();
  if (orphaned.isNotEmpty) {
    stderr.writeln(
      'No source in $sourceDir/ for: ${orphaned.join(', ')}\n'
      'Restore the .jsonl source or remove the generated dataset.',
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
