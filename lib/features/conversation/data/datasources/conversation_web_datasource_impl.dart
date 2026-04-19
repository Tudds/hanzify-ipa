import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/conversation_context.dart';
import 'conversation_local_datasource.dart';

// ============================================================================
// ConversationWebDataSourceImpl — In-memory datasource cho Conversation trên Web
// ============================================================================
class ConversationWebDataSourceImpl implements ConversationLocalDataSource {
  final List<ConversationContext> _store = [];

  ConversationWebDataSourceImpl._();

  static Future<ConversationWebDataSourceImpl> init() async {
    final ds = ConversationWebDataSourceImpl._();
    await ds._seedFromAssets();
    return ds;
  }

  @override
  Future<List<ConversationContext>> getAll({int limit = 0, int offset = 0}) async {
    var results = List<ConversationContext>.from(_store)
      ..sort((a, b) {
        final lvl = a.level.compareTo(b.level);
        return lvl != 0 ? lvl : a.id.compareTo(b.id);
      });

    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<ConversationContext?> getById(String id) async {
    try {
      return _store.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ConversationContext>> getByLevel(int level, {int limit = 0, int offset = 0}) async {
    var results = _store.where((c) => c.level == level).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<List<ConversationContext>> getByCategory(String category, {int limit = 0, int offset = 0}) async {
    var results = _store.where((c) => c.category == category).toList()
      ..sort((a, b) => a.level.compareTo(b.level));
    
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<List<ConversationContext>> search(String query, {int limit = 0, int offset = 0}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll(limit: limit, offset: offset);

    var results = _store.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.titleZh.contains(q) ||
          c.description.toLowerCase().contains(q);
    }).toList();

    results.sort((a, b) => a.level.compareTo(b.level));
    
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<void> update(ConversationContext conversation) async {
    final idx = _store.indexWhere((c) => c.id == conversation.id);
    if (idx >= 0) {
      _store[idx] = conversation;
    } else {
      _store.add(conversation);
    }
  }

  @override
  Future<int> count() async => _store.length;

  Future<void> _seedFromAssets() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/conversation.json');
      final decoded = json.decode(jsonStr) as List;
      for (final e in decoded) {
        final map = e as Map<String, dynamic>;
        final id = map['id'] as String? ?? '';
        _store.add(ConversationContext.fromJson(id, map));
      }
      debugPrint('✅ [Web] Seeded ${_store.length} conversations');
    } catch (e) {
      debugPrint('⚠️ [Web] Conversation seed error: $e');
    }
  }
}
