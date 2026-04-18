import 'package:drift/drift.dart';
import '../../../../core/database/app_database_stub.dart'
    if (dart.library.io) '../../../../core/database/app_database.dart';
import '../../domain/entities/grammar_point.dart';
import 'grammar_local_datasource.dart';

class GrammarLocalDataSourceImpl implements GrammarLocalDataSource {
  final AppDatabase db;
  GrammarLocalDataSourceImpl(this.db);

  /// Apply limit & offset to a query. limit=0 means no limit.
  SimpleSelectStatement<$GrammarPointsTableTable, GrammarPointDbModel> _applyPagination(
    SimpleSelectStatement<$GrammarPointsTableTable, GrammarPointDbModel> query, {
    int limit = 0,
    int offset = 0,
  }) {
    if (limit > 0) query.limit(limit, offset: offset);
    return query;
  }

  @override
  Future<List<GrammarPoint>> getAll({int limit = 0, int offset = 0}) async {
    var query = db.select(db.grammarPointsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);
    final results = await query.get();
    return results.map(GrammarPoint.fromDbModel).toList();
  }

  @override
  Future<GrammarPoint?> getById(String id) async {
    final query = db.select(db.grammarPointsTable)
      ..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return GrammarPoint.fromDbModel(row);
  }

  @override
  Future<List<GrammarPoint>> getByLevel(int level, {int limit = 0, int offset = 0}) async {
    var query = db.select(db.grammarPointsTable)
      ..where((tbl) => tbl.level.equals(level))
      ..orderBy([
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);
    return (await query.get()).map(GrammarPoint.fromDbModel).toList();
  }

  @override
  Future<List<GrammarPoint>> getByCategory(String category, {int limit = 0, int offset = 0}) async {
    var query = db.select(db.grammarPointsTable)
      ..where((tbl) => tbl.category.equals(category))
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);
    return (await query.get()).map(GrammarPoint.fromDbModel).toList();
  }

  @override
  Future<List<GrammarPoint>> search(String queryStr, {int limit = 0, int offset = 0}) async {
    if (queryStr.trim().isEmpty) return getAll(limit: limit, offset: offset);

    final q = '%${queryStr.trim()}%';
    var query = db.select(db.grammarPointsTable)
      ..where((tbl) =>
          tbl.title.like(q) | tbl.structure.like(q) | tbl.explanation.like(q) | tbl.category.like(q))
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);
    return (await query.get()).map(GrammarPoint.fromDbModel).toList();
  }

  @override
  Future<int> count() async {
    final countQuery = db.selectOnly(db.grammarPointsTable)
      ..addColumns([db.grammarPointsTable.id.count()]);
    return countQuery.map((row) => row.read(db.grammarPointsTable.id.count())).getSingle().then((v) => v ?? 0);
  }

  @override
  Future<void> update(GrammarPoint grammar) async {
    await db.into(db.grammarPointsTable).insert(
      GrammarPointsTableCompanion.insert(
        id: grammar.id,
        title: grammar.title,
        structure: grammar.structure,
        explanation: grammar.explanation,
        level: grammar.level,
        category: grammar.category,
        examples: grammar.examples,
        relatedGrammar: grammar.relatedGrammar,
        isBookmarked: Value(grammar.isBookmarked),
        isMastered: Value(grammar.isMastered),
        formulaParts: grammar.formulaParts,
        usages: grammar.usages,
        exampleTags: grammar.exampleTags,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}
