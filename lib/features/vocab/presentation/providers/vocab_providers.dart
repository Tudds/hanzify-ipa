import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/vocab_local_datasource.dart';
import '../../data/repositories/vocab_repository_impl.dart';
import '../../domain/repositories/vocab_repository.dart';

// Conditional import: on web → stub (no dart:io / drift/native),
//                     on native → real AppDatabase + VocabLocalDataSourceImpl.
import '../../../../core/database/app_database_stub.dart'
    if (dart.library.io) '../../../../core/database/app_database.dart';

import 'vocab_providers_web.dart'
    if (dart.library.io) 'vocab_providers_native.dart' as platform;

part 'vocab_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  // Overridden in main.dart on native platforms.
  throw UnimplementedError('appDatabase must be overridden via ProviderScope.');
}

@Riverpod(keepAlive: true)
VocabLocalDataSource vocabLocalDataSource(Ref ref) {
  // On web this provider is overridden in main.dart with VocabWebDataSourceImpl.
  // On native this calls through to VocabLocalDataSourceImpl(db).
  final db = ref.watch(appDatabaseProvider);
  return platform.createNativeDataSource(db);
}

@Riverpod(keepAlive: true)
VocabRepository vocabRepository(Ref ref) {
  final localDataSource = ref.watch(vocabLocalDataSourceProvider);
  return VocabRepositoryImpl(localDataSource);
}
