import 'dart:io';

/// Lightweight, dependency-free diagnostic log that survives process death.
///
/// Every isolate writes its own file (identified by [label]) so there is no
/// cross-isolate write contention. Files live in the app-specific external
/// directory, which needs no storage permission and can be pulled with ADB:
///
///   adb pull /sdcard/Android/data/org.localsend.localsend_app/files/ ./localsend-logs/
///
/// Logging must never break a transfer, so every operation is best-effort and
/// silently ignored on failure.
class DiagnosticLog {
  DiagnosticLog._();

  static const _androidDir = '/storage/emulated/0/Android/data/org.localsend.localsend_app/files';

  static String? _directory;
  static String _label = 'main';

  /// Initialize the file log. Called from [initLogger] in every isolate.
  /// On non-Android platforms this is a no-op.
  static void init(String label) {
    _label = label;
    if (!Platform.isAndroid) {
      return;
    }
    try {
      final dir = Directory(_androidDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      _directory = _androidDir;
    } catch (_) {
      // Ignore: diagnostics are optional.
      _directory = null;
    }
  }

  /// Append a single line with a timestamp. Never throws.
  static void write(String line) {
    final directory = _directory;
    if (directory == null) {
      return;
    }
    try {
      final file = File('$directory/localsend-$_label.log');
      file.writeAsStringSync(
        '${DateTime.now().toIso8601String()} $line\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Ignore: diagnostics must not affect the transfer.
    }
  }
}

/// Convenience top-level function for callers that only need to append a line.
void writeDiagnosticLog(String line) => DiagnosticLog.write(line);
