import 'package:drift/drift.dart';
import '../../../../core/database/app_database_stub.dart'
    if (dart.library.io) '../../../../core/database/app_database.dart';
import '../../domain/entities/conversation_context.dart';
import 'conversation_local_datasource.dart';

class ConversationLocalDataSourceImpl implements ConversationLocalDataSource {
  final AppDatabase db;
  ConversationLocalDataSourceImpl(this.db);

  /// Apply limit & offset to a query. limit=0 means no limit.
  SimpleSelectStatement<$ConversationsTableTable, ConversationDbModel> _applyPagination(
    SimpleSelectStatement<$ConversationsTableTable, ConversationDbModel> query, {
    int limit = 0,
    int offset = 0,
  }) {
    if (limit > 0) query.limit(limit, offset: offset);
    return query;
  }

  @override
  Future<List<ConversationContext>> getAll({int limit = 0, int offset = 0}) async {
    var query = db.select(db.conversationsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);
    final results = await query.get();
    return results.map(ConversationContext.fromDbModel).toList();
  }

  @override
  Future<ConversationContext?> getById(String id) async {
    final query = db.select(db.conversationsTable)
      ..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return ConversationContext.fromDbModel(row);
  }

  @override
  Future<List<ConversationContext>> getByLevel(int level, {int limit = 0, int offset = 0}) async {
    var query = db.select(db.conversationsTable)
      ..where((tbl) => tbl.level.equals(level))
      ..orderBy([
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);
    return (await query.get()).map(ConversationContext.fromDbModel).toList();
  }

  @override
  Future<List<ConversationContext>> getByCategory(String category, {int limit = 0, int offset = 0}) async {
    var query = db.select(db.conversationsTable)
      ..where((tbl) => tbl.category.equals(category))
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);
    return (await query.get()).map(ConversationContext.fromDbModel).toList();
  }

  @override
  Future<List<ConversationContext>> search(String queryStr, {int limit = 0, int offset = 0}) async {
    if (queryStr.trim().isEmpty) return getAll(limit: limit, offset: offset);

    final q = '%${queryStr.trim()}%';
    var query = db.select(db.conversationsTable)
      ..where((tbl) =>
          tbl.title.like(q) |
          tbl.description.like(q) |
          tbl.category.like(q) |
          tbl.titleZh.like(q))
      ..orderBy([
        (t) => OrderingTerm(expression: t.level, mode: OrderingMode.asc),
      ]);
    query = _applyPagination(query, limit: limit, offset: offset);
    return (await query.get()).map(ConversationContext.fromDbModel).toList();
  }

  @override
  Future<int> count() async {
    final countQuery = db.selectOnly(db.conversationsTable)
      ..addColumns([db.conversationsTable.id.count()]);
    return countQuery.map((row) => row.read(db.conversationsTable.id.count())).getSingle().then((v) => v ?? 0);
  }

  @override
  Future<void> update(ConversationContext conversation) async {
    await db.into(db.conversationsTable).insert(
          ConversationsTableCompanion.insert(
            id: conversation.id,
            title: conversation.title,
            titleZh: conversation.titleZh,
            titlePinyin: conversation.titlePinyin,
            description: conversation.description,
            level: conversation.level,
            category: conversation.category,
            icon: conversation.icon,
            lines: conversation.lines,
            vocabulary: conversation.vocabulary,
            speakers: conversation.speakers,
            relatedGrammar: conversation.relatedGrammar,
            cultureTip: conversation.cultureTip,
            isBookmarked: Value(conversation.isBookmarked),
            isMastered: Value(conversation.isMastered),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}
