// Native platform implementation for vocab providers.

import '../../../../core/database/app_database.dart';
import '../../data/datasources/vocab_local_datasource.dart';
import '../../data/datasources/vocab_local_datasource_impl.dart';

/// Create the native datasource backed by drift SQLite.
VocabLocalDataSource createNativeDataSource(AppDatabase db) {
  return VocabLocalDataSourceImpl(db);
}
