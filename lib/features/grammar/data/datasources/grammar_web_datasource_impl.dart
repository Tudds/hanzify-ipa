import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/grammar_point.dart';
import 'grammar_local_datasource.dart';
import 'package:hanzify/core/services/sync_web_service.dart';

// ============================================================================
// GrammarWebDataSourceImpl — In-memory datasource cho Grammar trên Web
// Khi user đã login, bookmark/mastered sẽ được sync với Supabase.
// ============================================================================
class GrammarWebDataSourceImpl implements GrammarLocalDataSource {
  final List<GrammarPoint> _store = [];
  final SyncWebService _syncService = SyncWebService();

  GrammarWebDataSourceImpl._();

  static Future<GrammarWebDataSourceImpl> init() async {
    final ds = GrammarWebDataSourceImpl._();
    await ds._seedFromAssets();
    await ds._mergeSupabaseProgress();
    return ds;
  }

  @override
  Future<List<GrammarPoint>> getAll({int limit = 0, int offset = 0}) async {
    var results = List<GrammarPoint>.from(_store)
      ..sort((a, b) {
        final lvl = a.level.compareTo(b.level);
        return lvl != 0 ? lvl : a.id.compareTo(b.id);
      });

    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<GrammarPoint?> getById(String id) async {
    try {
      return _store.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<GrammarPoint>> getByLevel(int level, {int limit = 0, int offset = 0}) async {
    var results = _store.where((g) => g.level == level).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<List<GrammarPoint>> getByCategory(String category, {int limit = 0, int offset = 0}) async {
    var results = _store.where((g) => g.category == category).toList()
      ..sort((a, b) => a.level.compareTo(b.level));
    
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<List<GrammarPoint>> search(String query, {int limit = 0, int offset = 0}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll(limit: limit, offset: offset);

    var results = _store.where((g) {
      return g.title.toLowerCase().contains(q) ||
          g.structure.toLowerCase().contains(q) ||
          g.explanation.toLowerCase().contains(q);
    }).toList();

    results.sort((a, b) => a.level.compareTo(b.level));
    
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<void> update(GrammarPoint grammar) async {
    final idx = _store.indexWhere((g) => g.id == grammar.id);
    if (idx >= 0) {
      _store[idx] = grammar;
    } else {
      _store.add(grammar);
    }

    // Push lên Supabase nếu đã login
    _pushToSupabase(grammar);
  }

  @override
  Future<int> count() async => _store.length;

  // ── Supabase Sync ──────────────────────────────────────────────────────────

  /// Push grammar update lên Supabase (fire-and-forget)
  void _pushToSupabase(GrammarPoint grammar) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    _syncService.pushGrammarUpdate(
      userId,
      grammar.id,
      isBookmarked: grammar.isBookmarked,
      isMastered: grammar.isMastered,
    ).ignore();
  }

  /// Pull bookmark/mastered từ Supabase và merge vào store.
  /// Remote luôn wins vì web không có persistent state.
  Future<void> _mergeSupabaseProgress() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final remoteProgress = await _syncService.pullGrammarProgress(userId);
      if (remoteProgress.isEmpty) return;

      int merged = 0;
      for (int i = 0; i < _store.length; i++) {
        final syncData = remoteProgress[_store[i].id];
        if (syncData != null) {
          _store[i] = _store[i].copyWith(
            isBookmarked: syncData.isBookmarked,
            isMastered: syncData.isMastered,
          );
          merged++;
        }
      }

      debugPrint('✅ [Web] Merged $merged grammar progress items from Supabase');
    } catch (e) {
      debugPrint('⚠️ [Web] Failed to merge Supabase grammar progress: $e');
    }
  }

  // ── Seed ────────────────────────────────────────────────────────────────────

  Future<void> _seedFromAssets() async {
    const files = [
      'assets/data/grammar_hsk1.json',
      'assets/data/grammar_hsk2.json',
      'assets/data/grammar_hsk3.json',
      'assets/data/grammar_hsk4.json',
    ];
    for (final path in files) {
      try {
        final jsonStr = await rootBundle.loadString(path);
        final decoded = json.decode(jsonStr) as List;
        for (final e in decoded) {
          final map = e as Map<String, dynamic>;
          final id = map['id'] as String? ?? '';
          _store.add(GrammarPoint.fromJson(id, map));
        }
      } catch (e) {
        debugPrint('⚠️ [Web] Grammar seed error ($path): $e');
      }
    }
    debugPrint('✅ [Web] Seeded ${_store.length} grammar points');
  }
}
