import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/character/domain/entities/character.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/repositories/character_repository.dart';
import '../../data/datasources/character_local_datasource.dart';
import 'character_providers_web.dart'
    if (dart.library.io) 'character_providers_native.dart' as platform;
import '../../data/repositories/character_repository_impl.dart';

part 'character_providers.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DI providers cho Character feature
// Không còn phụ thuộc vào vocab datasource — chỉ cần AppDatabase.
// ─────────────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
CharacterLocalDataSource characterLocalDataSource(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return platform.createNativeDataSource(db);
}

@Riverpod(keepAlive: true)
CharacterRepository characterRepository(Ref ref) {
  final ds = ref.watch(characterLocalDataSourceProvider);
  return CharacterRepositoryImpl(ds);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider: lấy Character entity theo ký tự (qua repository, không truy cập DB trực tiếp)
// ─────────────────────────────────────────────────────────────────────────────
@riverpod
Future<Character?> characterDetail(Ref ref, String char) async {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.getByChar(char);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider: danh sách Vocab chứa ký tự này (qua repository)
// ─────────────────────────────────────────────────────────────────────────────
@riverpod
Future<List<Vocab>> vocabContainingChar(Ref ref, String char) async {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.getVocabContainingChar(char);
}
