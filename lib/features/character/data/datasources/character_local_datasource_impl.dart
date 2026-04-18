import 'package:drift/drift.dart';
import '../../../../core/database/app_database_stub.dart'
    if (dart.library.io) '../../../../core/database/app_database.dart';
import '../../../vocab/domain/entities/vocab.dart';
import '../../domain/entities/character.dart';
import 'character_local_datasource.dart';

/// Implementation dùng Drift (native) để truy vấn character & vocab liên quan.
/// Chỉ cần AppDatabase — không còn phụ thuộc vào VocabLocalDataSource.
class CharacterLocalDataSourceImpl implements CharacterLocalDataSource {
  final AppDatabase db;

  CharacterLocalDataSourceImpl(this.db);

  @override
  Future<Character?> getByChar(String char) async {
    final query = db.select(db.charactersTable)
      ..where((tbl) => tbl.char.equals(char));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return Character.fromDbModel(row);
  }

  @override
  Future<List<Vocab>> getVocabContainingChar(String char) async {
    // Dùng DB query trực tiếp thay vì load ALL vocab rồi filter client-side.
    // Cột characters là JSON array string, dùng LIKE để tìm char trong đó.
    final query = db.select(db.vocabsTable)
      ..where((t) => t.characters.like('%$char%'))
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.hanzi, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return results.map(Vocab.fromDbModel).toList();
  }
}
