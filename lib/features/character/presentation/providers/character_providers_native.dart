// Native platform implementation for character providers.

import '../../../../core/database/app_database.dart';
import '../../data/datasources/character_local_datasource.dart';
import '../../data/datasources/character_local_datasource_impl.dart';

/// Create the native datasource backed by drift SQLite.
CharacterLocalDataSource createNativeDataSource(AppDatabase db) {
  return CharacterLocalDataSourceImpl(db);
}
