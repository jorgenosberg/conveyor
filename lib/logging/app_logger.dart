import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final Logger appLogger = Logger(
  filter: _AppLogFilter(),
  printer: _OneLinePrinter(),
);

class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    return true;
  }
}

class _OneLinePrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final timestamp = _formatTimestamp(DateTime.now());
    final level = _formatLevel(event.level);
    final message = _singleLine(event.message.toString());
    final buffer = StringBuffer('$timestamp [$level] $message');

    if (event.error != null) {
      buffer.write(' | error: ${_singleLine(event.error.toString())}');
    }
    if (event.stackTrace != null) {
      buffer.write(' | stack: ${_firstLine(event.stackTrace.toString())}');
    }

    return [buffer.toString()];
  }

  String _formatTimestamp(DateTime now) {
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatLevel(Level level) {
    final name = level.name;
    if (name == 'warning') return 'WARN';
    if (name == 'fatal') return 'FATAL';
    if (name == 'trace') return 'TRACE';
    return name.toUpperCase();
  }

  String _singleLine(String value) {
    return value.replaceAll(RegExp(r'[\r\n]+'), ' ');
  }

  String _firstLine(String value) {
    final index = value.indexOf('\n');
    if (index == -1) return value;
    return value.substring(0, index);
  }
}
