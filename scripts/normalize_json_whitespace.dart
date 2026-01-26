#!/usr/bin/env dart

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

const Map<int, String> _spaceNames = {
  0x00A0: 'NBSP',
  0x2000: 'EN QUAD',
  0x2001: 'EM QUAD',
  0x2002: 'EN SPACE',
  0x2003: 'EM SPACE',
  0x2004: 'THREE-PER-EM SPACE',
  0x2005: 'FOUR-PER-EM SPACE',
  0x2006: 'SIX-PER-EM SPACE',
  0x2007: 'FIGURE SPACE',
  0x2008: 'PUNCTUATION SPACE',
  0x2009: 'THIN SPACE',
  0x200A: 'HAIR SPACE',
  0x202F: 'NNBSP',
  0x205F: 'MEDIUM MATHEMATICAL SPACE',
  0x3000: 'IDEOGRAPHIC SPACE',
};

class _Result {
  final String text;
  final Map<int, int> replacedBySpace;
  final int unitSpacesRemoved;
  const _Result(this.text, this.replacedBySpace, this.unitSpacesRemoved);
}

void main(List<String> args) {
  final options = args.toList();
  final dryRun = options.remove('--dry-run');
  final noBackup = options.remove('--no-backup');
  final stripUnitSpace = options.remove('--strip-unit-space');

  if (options.isEmpty) {
    stderr.writeln(
      'Usage: dart run scripts/normalize_json_whitespace.dart '
      '[--dry-run] [--no-backup] [--strip-unit-space] '
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
    final result = _normalizeJsonWhitespace(original, stripUnitSpace);
    final totalReplaced = result.replacedBySpace.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    final totalChanges = totalReplaced + result.unitSpacesRemoved;
    if (totalChanges == 0) {
      stdout.writeln('$filePath: no changes');
      continue;
    }
    if (dryRun) {
      stdout.writeln('$filePath: would update $totalChanges char(s)');
      _printSummary(result);
      continue;
    }
    if (!noBackup) {
      final backup = File('$filePath.bak');
      backup.writeAsStringSync(original);
    }
    file.writeAsStringSync(result.text);
    stdout.writeln('$filePath: updated $totalChanges char(s)');
    _printSummary(result);
  }

  exit(exitCode);
}

void _printSummary(_Result result) {
  for (final entry in result.replacedBySpace.entries) {
    final name = _spaceNames[entry.key] ?? 'U+${entry.key.toRadixString(16)}';
    stdout.writeln('  $name -> space: ${entry.value}');
  }
  if (result.unitSpacesRemoved > 0) {
    stdout.writeln(
      '  unit space (digit + space + m) -> removed: '
      '${result.unitSpacesRemoved}',
    );
  }
}

_Result _normalizeJsonWhitespace(String input, bool stripUnitSpace) {
  final buffer = StringBuffer();
  var inString = false;
  var escape = false;
  var unitSpacesRemoved = 0;
  final replacedBySpace = <int, int>{};
  int? lastOutputCodeUnit;

  for (var i = 0; i < input.length; i++) {
    final codeUnit = input.codeUnitAt(i);
    final ch = String.fromCharCode(codeUnit);

    if (!inString) {
      if (ch == '"') {
        inString = true;
      }
      buffer.write(ch);
      lastOutputCodeUnit = codeUnit;
      continue;
    }

    if (escape) {
      buffer.write(ch);
      lastOutputCodeUnit = codeUnit;
      escape = false;
      continue;
    }

    if (ch == '\\') {
      buffer.write(ch);
      lastOutputCodeUnit = codeUnit;
      escape = true;
      continue;
    }

    if (ch == '"') {
      inString = false;
      buffer.write(ch);
      lastOutputCodeUnit = codeUnit;
      continue;
    }

    final isWeirdSpace = _weirdSpaces.contains(codeUnit);
    final isSpace = ch == ' ' || isWeirdSpace;
    final nextChar = i + 1 < input.length ? input[i + 1] : '';
    if (stripUnitSpace &&
        isSpace &&
        _isDigit(lastOutputCodeUnit) &&
        nextChar == 'm') {
      unitSpacesRemoved++;
      continue;
    }

    if (isWeirdSpace) {
      buffer.write(' ');
      lastOutputCodeUnit = 0x20;
      replacedBySpace[codeUnit] = (replacedBySpace[codeUnit] ?? 0) + 1;
      continue;
    }

    buffer.write(ch);
    lastOutputCodeUnit = codeUnit;
  }

  return _Result(buffer.toString(), replacedBySpace, unitSpacesRemoved);
}

bool _isDigit(int? codeUnit) {
  if (codeUnit == null) return false;
  return codeUnit >= 0x30 && codeUnit <= 0x39;
}
