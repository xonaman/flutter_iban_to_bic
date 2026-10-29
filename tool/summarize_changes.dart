// Prints a Markdown summary of which bank codes were added, removed or
// changed in `data/bank_codes/` compared to a git revision. Used by the
// `refresh-data` workflow for its pull-request body.
//
// Run with:
//   dart run tool/summarize_changes.dart          # compare against HEAD
//   dart run tool/summarize_changes.dart main     # compare against main

// ignore_for_file: avoid_print

import 'dart:io';

import 'bank_codes.dart';

/// Lists longer than this are cut off in the summary.
const int maxListed = 50;

/// GitHub rejects pull-request bodies over 65,536 characters; leave room
/// for the workflow's own text around the summary.
const int maxSummaryLength = 60000;

void main(List<String> args) {
  final String rev = args.isEmpty ? 'HEAD' : args.first;
  final StringBuffer out = StringBuffer();
  // Include countries whose source exists only at [rev], so a deleted
  // dataset shows up as all of its codes removed.
  final List<String> countries = <String>{
    ...sourceCountries(),
    ..._countriesAt(rev),
  }.toList()..sort();
  for (final String cc in countries) {
    final Map<String, BankEntry> before = _readAt(rev, sourcePath(cc));
    final Map<String, BankEntry> after = File(sourcePath(cc)).existsSync()
        ? readSource(cc)
        : <String, BankEntry>{};
    final String section = summarizeCountry(cc, before, after);
    if (section.isNotEmpty) out.writeln(section);
  }
  String summary = out.isEmpty
      ? 'No bank codes changed.'
      : out.toString().trimRight();
  if (summary.length > maxSummaryLength) {
    final String notice =
        '\n\n_Summary truncated; see the diff of `$sourceDir/`._';
    summary = summary.substring(0, maxSummaryLength - notice.length) + notice;
  }
  print(summary);
}

List<String> _countriesAt(String rev) {
  final ProcessResult res = Process.runSync('git', <String>[
    'ls-tree',
    '--name-only',
    rev,
    '$sourceDir/',
  ]);
  if (res.exitCode != 0) return <String>[];
  return <String>[
    for (final String path in (res.stdout as String).split('\n'))
      if (path.endsWith('.jsonl'))
        path.split('/').last.split('.').first.toUpperCase(),
  ];
}

Map<String, BankEntry> _readAt(String rev, String path) {
  final ProcessResult res = Process.runSync('git', <String>[
    'show',
    '$rev:$path',
  ]);
  // A country that is new in the working tree has no previous source.
  if (res.exitCode != 0) return <String, BankEntry>{};
  return decodeSource(res.stdout as String);
}

/// Markdown section for one country, or `''` when nothing changed.
String summarizeCountry(
  String cc,
  Map<String, BankEntry> before,
  Map<String, BankEntry> after,
) {
  final List<String> added = sortedCodes(
    after.keys.where((String c) => !before.containsKey(c)),
  );
  final List<String> removed = sortedCodes(
    before.keys.where((String c) => !after.containsKey(c)),
  );
  final List<String> changed = sortedCodes(
    after.keys.where(
      (String c) => before.containsKey(c) && before[c] != after[c],
    ),
  );
  if (added.isEmpty && removed.isEmpty && changed.isEmpty) return '';

  final StringBuffer out = StringBuffer()
    ..writeln(
      '### $cc: ${added.length} added, ${removed.length} removed, '
      '${changed.length} changed (${before.length} → ${after.length} codes)',
    );
  void list(String title, List<String> codes, String Function(String) line) {
    if (codes.isEmpty) return;
    out
      ..writeln()
      ..writeln('<details><summary>$title (${codes.length})</summary>')
      ..writeln();
    for (final String code in codes.take(maxListed)) {
      out.writeln('- ${line(code)}');
    }
    if (codes.length > maxListed) {
      out.writeln('- … and ${codes.length - maxListed} more');
    }
    out
      ..writeln()
      ..writeln('</details>');
  }

  list('Added', added, (String c) => '`$c` ${_describe(after[c]!)}');
  list('Removed', removed, (String c) => '`$c` ${_describe(before[c]!)}');
  list('Changed', changed, (String c) {
    final Map<String, String?> a = before[c]!.toJson();
    final Map<String, String?> b = after[c]!.toJson();
    final List<String> fields = <String>[
      for (final String k in <String>{...a.keys, ...b.keys})
        if (a[k] != b[k]) '$k: ${_quote(a[k])} → ${_quote(b[k])}',
    ];
    return '`$c` ${fields.join('; ')}';
  });
  return out.toString();
}

String _describe(BankEntry e) => '${e.bic} ${_quote(e.bankName)}';

String _quote(String? s) =>
    s == null ? '—' : '"${s.replaceAll('<', '&lt;').replaceAll('>', '&gt;')}"';
