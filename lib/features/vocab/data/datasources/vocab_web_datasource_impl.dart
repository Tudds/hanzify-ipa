import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/vocab.dart';
import 'vocab_local_datasource.dart';
import 'package:hanzify/core/utils/pinyin_utils.dart' show normalizePinyin;
import 'package:hanzify/core/utils/vocab_parser.dart' show VocabJsonParser;

// ============================================================================
// VocabWebDataSourceImpl — In-memory datasource cho nền tảng Web
// Dữ liệu được seed từ JSON assets và lưu hoàn toàn trong bộ nhớ RAM.
// ============================================================================
class VocabWebDataSourceImpl implements VocabLocalDataSource {
  final List<Vocab> _store = [];

  VocabWebDataSourceImpl._();

  /// Factory khởi tạo + seed dữ liệu từ assets
  static Future<VocabWebDataSourceImpl> init() async {
    final ds = VocabWebDataSourceImpl._();
    await ds._seedFromAssets();
    return ds;
  }

  // ── Basic CRUD ─────────────────────────────────────────────────────────────
  
  List<Vocab>? _sortedCache;

  @override
  Future<List<Vocab>> getAll({int limit = 0, int offset = 0}) async {
    _sortedCache ??= List<Vocab>.from(_store)
      ..sort((a, b) {
        final lvl = a.level.compareTo(b.level);
        return lvl != 0 ? lvl : a.hanzi.compareTo(b.hanzi);
      });

    var results = _sortedCache!;
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<List<Vocab>> getDue({int limit = 0, int offset = 0}) async {
    final now = DateTime.now().toUtc();
    var results = _store
        .where((v) => v.nextReview.isBefore(now) && v.interval > 0)
        .toList();
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<List<Vocab>> getNew({int limit = 0, int offset = 0}) async {
    var results = _store.where((v) => v.interval == 0).toList();
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<List<Vocab>> getByLevel(int level, {int limit = 0, int offset = 0}) async {
    var results = _store.where((v) => v.level == level).toList()
      ..sort((a, b) => a.hanzi.compareTo(b.hanzi));
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    return results;
  }

  @override
  Future<void> update(Vocab model) async {
    final idx = _store.indexWhere((v) => v.id == model.id);
    if (idx >= 0) {
      _store[idx] = model;
    } else {
      _store.add(model);
    }
    _sortedCache = null; // Invalidate cache
  }

  @override
  Future<void> insert(Vocab model) => update(model);

  // ── Search ─────────────────────────────────────────────────────────────────

  @override
  Future<List<Vocab>> search(
    String query, {
    int? hskLevel,
    String? wordType,
    int limit = 0,
    int offset = 0,
  }) async {
    final qTrim = query.trim().toLowerCase();
    
    // Nếu query rỗng + no filter, dùng cache cho nhanh
    if (qTrim.isEmpty && hskLevel == null && (wordType == null || wordType == 'all')) {
      return getAll(limit: limit, offset: offset);
    }

    var results = List<Vocab>.from(_store);

    if (qTrim.isNotEmpty) {
      final qNorm = normalizePinyin(qTrim);

      results = results.where((v) {
        if (v.hanzi.contains(qTrim)) return true;
        if (v.pinyin.toLowerCase().contains(qTrim)) return true;
        if (v.pinyinNormalized.contains(qNorm)) return true;
        if (v.meanings.any((m) => m.vi.toLowerCase().contains(qTrim))) return true;
        return false;
      }).toList();
    }

    if (hskLevel != null && hskLevel > 0) {
      results = results.where((v) => v.level == hskLevel).toList();
    }
    if (wordType != null && wordType != 'all') {
      results = results.where((v) {
        return v.wordType == wordType ||
            v.meanings.any((m) => m.pos == wordType);
      }).toList();
    }

    results.sort((a, b) {
      final lvl = a.level.compareTo(b.level);
      return lvl != 0 ? lvl : a.hanzi.compareTo(b.hanzi);
    });
    
    if (offset > 0) results = results.skip(offset).toList();
    if (limit > 0) results = results.take(limit).toList();
    
    return results;
  }

  // ── Seed từ JSON assets ────────────────────────────────────────────────────

  Future<void> _seedFromAssets() async {
    try {
      final listFiles = ['hsk1.json', 'hsk2.json', 'hsk3.json', 'hsk4.json'];
      
      // Parallelize asset loading
      final contents = await Future.wait(
        listFiles.map((f) => rootBundle.loadString('assets/data/$f'))
      );

      for (final jsonStr in contents) {
        try {
          final decoded = json.decode(jsonStr);

          if (decoded is List) {
            for (var v in decoded) {
              final map = v as Map<String, dynamic>;
              final id = map['id'] as String? ?? '${map['hanzi']}_${map['level']}';
              _store.add(VocabJsonParser.parse(map, id: id));
            }
          } else if (decoded is Map) {
            for (var e in decoded.entries) {
              _store.add(VocabJsonParser.parse(
                e.value as Map<String, dynamic>,
                id: e.key,
              ));
            }
          }
        } catch (e) {
          debugPrint('⚠️ [Web] Decoding error: $e');
        }
      }

      _sortedCache = null; // Ensure cache is refreshed
      debugPrint('✅ [Web] Seeded ${_store.length} vocab items (in-memory)');
    } catch (e) {
      debugPrint('❌ [Web] Vocab seed error: $e');
    }
  }

  @override
  Future<void> reseed() async {
    _store.clear();
    _sortedCache = null;
    await _seedFromAssets();
  }

  @override
  Future<int> count() async => _store.length;
}

