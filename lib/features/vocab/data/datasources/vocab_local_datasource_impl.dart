import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/vocab.dart';
import 'vocab_local_datasource.dart';

import 'package:hanzify/core/utils/pinyin_utils.dart';

class VocabLocalDataSourceImpl implements VocabLocalDataSource {
  final AppDatabase db;
  VocabLocalDataSourceImpl(this.db);

  VocabsTableCompanion _mapToCompanion(Vocab vocab) {
    return VocabsTableCompanion.insert(
      id: vocab.id,
      hanzi: vocab.hanzi,
      pinyin: vocab.pinyin,
      pinyinNormalized: vocab.pinyinNormalized,
      characters: vocab.characters,
      meanings: vocab.meanings,
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
      updatedAt: Value(DateTime.now().toUtc()),
    );
  }

  /// Apply limit & offset to a query. limit=0 means no limit.
  SimpleSelectStatement<$VocabsTableTable, VocabDbModel> _applyPagination(
    SimpleSelectStatement<$VocabsTableTable, VocabDbModel> query, {
    int limit = 0,
    int offset = 0,
  }) {
    if (limit > 0) query.limit(limit, offset: offset);
    return query;
  }

  @override
  Future<List<Vocab>> getAll({int limit = 0, int offset = 0}) async {
    var query = db.select(db.vocabsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.hanzi, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);
    final results = await query.get();
    return results.map(Vocab.fromDbModel).toList();
  }

  @override
  Future<List<Vocab>> getDue({int limit = 0, int offset = 0}) async {
    final now = DateTime.now().toUtc();
    var query = db.select(db.vocabsTable)
      ..where((t) =>
          t.nextReview.isSmallerThanValue(now) &
          t.interval.isBiggerThanValue(0) &
          t.isMastered.equals(false));
    query = _applyPagination(query, limit: limit, offset: offset);
    final results = await query.get();
    return results.map(Vocab.fromDbModel).toList();
  }

  @override
  Future<List<Vocab>> getNew({int limit = 0, int offset = 0}) async {
    var query = db.select(db.vocabsTable)..where((t) => t.interval.equals(0));
    query = _applyPagination(query, limit: limit, offset: offset);
    final results = await query.get();
    return results.map(Vocab.fromDbModel).toList();
  }

  @override
  Future<List<Vocab>> getByLevel(
    int level, {
    int limit = 0,
    int offset = 0,
  }) async {
    var query = db.select(db.vocabsTable)
      ..where((t) => t.level.equals(level))
      ..orderBy([
        (t) => OrderingTerm(expression: t.hanzi, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);
    final results = await query.get();
    return results.map(Vocab.fromDbModel).toList();
  }

  @override
  Future<void> update(Vocab model) async {
    await db
        .into(db.vocabsTable)
        .insert(_mapToCompanion(model), mode: InsertMode.insertOrReplace);
  }

  @override
  Future<void> insert(Vocab model) => update(model);

  @override
  Future<int> count() async {
    final countQuery = db.selectOnly(db.vocabsTable)
      ..addColumns([db.vocabsTable.id.count()]);
    return countQuery
        .map((row) => row.read(db.vocabsTable.id.count()))
        .getSingle()
        .then((v) => v ?? 0);
  }

  @override
  Future<List<Vocab>> search(
    String queryStr, {
    int? hskLevel,
    String? wordType,
    int limit = 0,
    int offset = 0,
  }) async {
    if (queryStr.trim().isEmpty) {
      final all = await getAll(limit: limit, offset: offset);
      return _applyFilters(all, hskLevel, wordType);
    }

    final normalizedQuery = normalizePinyin(queryStr.trim());
    final qRaw = queryStr.trim();

    var query = db.select(db.vocabsTable)
      ..where((t) {
        return t.hanzi.like('%$qRaw%') |
            t.pinyinNormalized.like('%$normalizedQuery%') |
            t.meanings.like('%$qRaw%');
      })
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.hanzi, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);

    final rawResults = await query.get();
    var mapped = rawResults.map(Vocab.fromDbModel).toList();

    // Post-filter: kiểm tra thêm trong meanings[].vi cho accuracy
    final isHanziQuery = qRaw.runes.any((r) => r >= 0x4E00 && r <= 0x9FFF);
    if (!isHanziQuery && normalizedQuery.isNotEmpty) {
      mapped = mapped.where((v) {
        if (v.hanzi.contains(qRaw)) return true;
        if (v.pinyin.toLowerCase().contains(qRaw.toLowerCase())) return true;
        if (v.pinyinNormalized.contains(normalizedQuery)) return true;
        if (v.meanings.any(
          (m) => m.vi.toLowerCase().contains(qRaw.toLowerCase()),
        )) {
          return true;
        }
        return false;
      }).toList();
    }

    return _applyFilters(mapped, hskLevel, wordType);
  }

  List<Vocab> _applyFilters(List<Vocab> list, int? hskLevel, String? wordType) {
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
