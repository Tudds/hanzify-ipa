import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/vocab.dart';
import 'vocab_local_datasource.dart';

// Re-export for backward compatibility
export 'pinyin_utils.dart' show normalizePinyin;
import 'pinyin_utils.dart';

class VocabLocalDataSourceImpl implements VocabLocalDataSource {
  final AppDatabase db;
  VocabLocalDataSourceImpl(this.db);

  Vocab _mapToDomain(VocabDbModel model) {
    return Vocab(
      id: model.id,
      hanzi: model.hanzi,
      pinyin: model.pinyin,
      pinyinNormalized: model.pinyinNormalized,
      characters: model.characters,
      meanings: model.meanings,
      meaning: model.meaning,
      exampleSentences: model.exampleSentences,
      level: model.level,
      wordType: model.wordType,
      isBookmarked: model.isBookmarked,
      isMastered: model.isMastered,
      repetitions: model.repetitions,
      easeFactor: model.easeFactor,
      interval: model.interval,
      nextReview: model.nextReview.toLocal(),
    );
  }

  VocabsTableCompanion _mapToCompanion(Vocab vocab) {
    return VocabsTableCompanion.insert(
      id: vocab.id,
      hanzi: vocab.hanzi,
      pinyin: vocab.pinyin,
      pinyinNormalized: vocab.pinyinNormalized,
      characters: vocab.characters,
      meanings: vocab.meanings,
      meaning: vocab.meaning,
      exampleSentences: vocab.exampleSentences,
      level: vocab.level,
      wordType: vocab.wordType,
      isBookmarked: Value(vocab.isBookmarked),
      isMastered: Value(vocab.isMastered),
      repetitions: Value(vocab.repetitions),
      easeFactor: Value(vocab.easeFactor),
      interval: Value(vocab.interval),
      nextReview: vocab.nextReview.toUtc(),
      needsSync: const Value(true),
    );
  }

  @override
  Future<List<Vocab>> getAll() async {
    final query = db.select(db.vocabsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.hanzi, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return results.map(_mapToDomain).toList();
  }

  @override
  Future<List<Vocab>> getDue() async {
    final now = DateTime.now().toUtc();
    final query = db.select(db.vocabsTable)
      ..where((t) => t.nextReview.isSmallerThanValue(now));
    final results = await query.get();
    return results.map(_mapToDomain).toList();
  }

  @override
  Future<List<Vocab>> getByLevel(int level) async {
    final query = db.select(db.vocabsTable)
      ..where((t) => t.level.equals(level))
      ..orderBy([
        (t) => OrderingTerm(expression: t.hanzi, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return results.map(_mapToDomain).toList();
  }

  @override
  Future<void> update(Vocab model) async {
    await db.into(db.vocabsTable).insert(_mapToCompanion(model), mode: InsertMode.insertOrReplace);
  }

  @override
  Future<void> insert(Vocab model) async {
    await db.into(db.vocabsTable).insert(_mapToCompanion(model), mode: InsertMode.insertOrReplace);
  }

  @override
  Future<List<Vocab>> search(
    String queryStr, {
    int? hskLevel,
    String? wordType,
  }) async {
    if (queryStr.trim().isEmpty) {
      var q = db.select(db.vocabsTable)..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.hanzi, mode: OrderingMode.asc),
      ]);
      var results = await q.get();
      return _applyFilters(results.map(_mapToDomain).toList(), hskLevel, wordType);
    }

    final normalizedQuery = normalizePinyin(queryStr.trim());
    final qRaw = queryStr.trim();
    
    final query = db.select(db.vocabsTable)
      ..where((t) {
        return t.hanzi.like('%$qRaw%') |
            t.pinyinNormalized.like('%$normalizedQuery%') |
            t.meaning.like('%$qRaw%') |
            t.meanings.like('%$qRaw%'); 
      })
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.hanzi, mode: OrderingMode.asc),
      ]);

    final rawResults = await query.get();
    return _applyFilters(rawResults.map(_mapToDomain).toList(), hskLevel, wordType);
  }

  List<Vocab> _applyFilters(
    List<Vocab> list,
    int? hskLevel,
    String? wordType,
  ) {
    var result = list;
    if (hskLevel != null && hskLevel > 0) {
      result = result.where((v) => v.level == hskLevel).toList();
    }
    if (wordType != null && wordType != 'all') {
      result = result.where((v) {
        return v.wordType == wordType ||
            v.meanings.any((m) => m.pos == wordType);
      }).toList();
    }
    return result;
  }

  @override
  Future<void> reseed() async {
    await db.forceSeed();
  }
}
