#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

const Set<int> _weirdSpaces = {
  0x00A0, // NO-BREAK SPACE
  0x2000, // EN QUAD
  0x2001, // EM QUAD
  0x2002, // EN SPACE
  0x2003, // EM SPACE
  0x2004, // THREE-PER-EM SPACE
  0x2005, // FOUR-PER-EM SPACE
  0x2006, // SIX-PER-EM SPACE
  0x2007, // FIGURE SPACE
  0x2008, // PUNCTUATION SPACE
  0x2009, // THIN SPACE
  0x200A, // HAIR SPACE
  0x202F, // NARROW NO-BREAK SPACE
  0x205F, // MEDIUM MATHEMATICAL SPACE
  0x3000, // IDEOGRAPHIC SPACE
};

void main(List<String> args) {
  final options = args.toList();
  final dryRun = options.remove('--dry-run');
  final noBackup = options.remove('--no-backup');
  final force = options.remove('--force');
  final stripUnitSpace = options.remove('--strip-unit-space');

  if (options.isEmpty) {
    stderr.writeln(
      'Usage: dart run scripts/add_asset_paths.dart '
      '[--dry-run] [--no-backup] [--force] [--strip-unit-space] '
      '<file1.json> [file2.json ...]',
    );
    exit(2);
  }

  var exitCode = 0;
  for (final filePath in options) {
    final file = File(filePath);
    if (!file.existsSync()) {
      stderr.writeln('$filePath: not found');
      exitCode = 1;
      continue;
    }

    final original = file.readAsStringSync();
    final data = jsonDecode(original);
    if (data is! Map<String, dynamic>) {
      stderr.writeln('$filePath: expected a JSON object at top level');
      exitCode = 1;
      continue;
    }

    var updated = 0;
    var skipped = 0;
    var existing = 0;

    for (final entry in data.entries) {
      final list = entry.value;
      if (list is! List) {
        skipped++;
        continue;
      }
      for (final item in list) {
        if (item is! Map<String, dynamic>) {
          skipped++;
          continue;
        }
        final name = item['name'];
        if (name is! String || name.isEmpty) {
          skipped++;
          continue;
        }
        if (!force && item.containsKey('assetPath')) {
          existing++;
          continue;
        }
        final assetPath = _buildAssetPath(name, stripUnitSpace);
        item['assetPath'] = assetPath;
        updated++;
      }
    }

    if (updated == 0 && force == false) {
      stdout.writeln('$filePath: no changes');
      continue;
    }

    if (dryRun) {
      stdout.writeln(
        '$filePath: would add assetPath to $updated item(s), '
        '$existing already set, $skipped skipped',
      );
      continue;
    }

    if (!noBackup) {
      File('$filePath.bak').writeAsStringSync(original);
    }

    final encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync('${encoder.convert(data)}\n');
    stdout.writeln(
      '$filePath: added assetPath to $updated item(s), '
      '$existing already set, $skipped skipped',
    );
  }

  exit(exitCode);
}

String _buildAssetPath(String name, bool stripUnitSpace) {
  final normalized = _normalizeName(name, stripUnitSpace);
  final slug = normalized.replaceAll(' ', '_');
  return 'assets/images/$slug.webp';
}

String _normalizeName(String name, bool stripUnitSpace) {
  final buffer = StringBuffer();
  var lastWasSpace = false;

  for (final rune in name.runes) {
    if (_isSpace(rune)) {
      if (!lastWasSpace) {
        buffer.write(' ');
        lastWasSpace = true;
      }
      continue;
    }
    buffer.write(String.fromCharCode(rune));
    lastWasSpace = false;
  }

  var normalized = buffer.toString().trim();
  if (stripUnitSpace) {
    normalized = normalized.replaceAll(RegExp(r'(\d)\s+m\b'), r'$1m');
  }
  return normalized;
}

bool _isSpace(int rune) {
  return rune == 0x20 ||
      rune == 0x09 ||
      rune == 0x0A ||
      rune == 0x0D ||
      _weirdSpaces.contains(rune);
}
