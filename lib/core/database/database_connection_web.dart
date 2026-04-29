import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import 'app_database.dart';

AppDatabase openAppDatabase() {
  return AppDatabase(
    LazyDatabase(() async {
      final result = await WasmDatabase.open(
        databaseName: 'hanzify',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      );
      return result.resolvedExecutor;
    }),
  );
}
