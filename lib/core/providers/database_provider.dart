import 'package:riverpod_annotation/riverpod_annotation.dart';

// Conditional import: on web → stub (no dart:io / drift/native),
//                     on native → real AppDatabase + VocabLocalDataSourceImpl.
import '../database/app_database_stub.dart'
    if (dart.library.io) '../database/app_database.dart';

part 'database_provider.g.dart';

/// Shared AppDatabase provider — singleton, keepAlive.
/// Overridden in platform_native.dart with real AppDatabase instance.
/// All features (vocab, grammar, conversation, character) use this provider
/// instead of creating their own DB instances.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  // Overridden in main.dart on native platforms.
  throw UnimplementedError('appDatabase must be overridden via ProviderScope.');
}
