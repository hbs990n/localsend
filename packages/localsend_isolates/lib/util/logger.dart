import 'package:localsend_isolates/util/diagnostic_log.dart';
import 'package:logging/logging.dart';

void initLogger(Level level, {String label = 'main'}) {
  DiagnosticLog.init(label);
  Logger.root.level = level;
  Logger.root.onRecord.listen((record) {
    final line = '${record.time} ${'[${record.level.name}]'.padLeft(9)} [${record.loggerName}] ${record.message}';
    // ignore: avoid_print
    print(line);
    DiagnosticLog.write(line);

    if (record.error != null) {
      final error = record.error.toString();
      // ignore: avoid_print
      print(error);
      DiagnosticLog.write('    error: $error');
    }

    if (record.stackTrace != null) {
      final stackTrace = record.stackTrace.toString();
      // ignore: avoid_print
      print(stackTrace);
      DiagnosticLog.write('    stack: $stackTrace');
    }
  });
}
