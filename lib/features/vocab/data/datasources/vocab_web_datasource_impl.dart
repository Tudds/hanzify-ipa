import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/vocab.dart';
import 'vocab_local_datasource.dart';
import 'pinyin_utils.dart';

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

  @override
  Future<List<Vocab>> getAll() async {
    final sorted = List<Vocab>.from(_store);
    sorted.sort((a, b) {
      final lvl = a.level.compareTo(b.level);
      return lvl != 0 ? lvl : a.hanzi.compareTo(b.hanzi);
    });
    return sorted;
  }

  @override
  Future<List<Vocab>> getDue() async {
    final now = DateTime.now().toUtc();
    return _store.where((v) => v.nextReview.isBefore(now)).toList();
  }

  @override
  Future<List<Vocab>> getByLevel(int level) async {
    return _store.where((v) => v.level == level).toList()
      ..sort((a, b) => a.hanzi.compareTo(b.hanzi));
  }

  @override
  Future<void> update(Vocab model) async {
    final idx = _store.indexWhere((v) => v.id == model.id);
    if (idx >= 0) {
      _store[idx] = model;
    } else {
      _store.add(model);
    }
  }

  @override
  Future<void> insert(Vocab model) async {
    final idx = _store.indexWhere((v) => v.id == model.id);
    if (idx >= 0) {
      _store[idx] = model;
    } else {
      _store.add(model);
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  @override
  Future<List<Vocab>> search(
    String query, {
    int? hskLevel,
    String? wordType,
  }) async {
    var results = List<Vocab>.from(_store);

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      final qNorm = normalizePinyin(q);

      results = results.where((v) {
        if (v.hanzi.contains(q)) return true;
        if (v.pinyin.toLowerCase().contains(q)) return true;
        if (v.pinyinNormalized.contains(qNorm)) return true;
        if (v.meaning.toLowerCase().contains(q)) return true;
        if (v.meanings.any((m) => m.vi.toLowerCase().contains(q))) return true;
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
    return results;
  }

  // ── Seed từ JSON assets ────────────────────────────────────────────────────

  Future<void> _seedFromAssets() async {
    try {

      void addVocab(Map<String, dynamic> v, String id) {
        final meaningsList = (v['meanings'] as List?)?.map((m) {
              final map = m as Map<String, dynamic>;
              return Meaning(
                pos: map['pos'] as String? ?? 'other',
                vi: map['vi'] as String? ?? '',
                en: map['en'] as String? ?? '',
              );
            }).toList() ?? [];

        final meaningFlat = v['meaning'] as String? ??
            meaningsList.map((m) => '${m.pos}. ${m.vi}').join('; ');

        final examplesList = (v['exampleSentences'] as List?)?.map((e) {
              if (e is Map) {
                final map = e as Map<String, dynamic>;
                return ExampleSentence(
                  cn: map['cn'] as String? ?? '',
                  pinyin: map['pinyin'] as String? ?? '',
                  vi: map['vi'] as String? ?? '',
                );
              }
              return ExampleSentence(cn: e as String, pinyin: '', vi: '');
            }).toList() ?? [];

        final wordType = v['wordType'] as String? ??
            (meaningsList.isNotEmpty ? meaningsList.first.pos : 'other');

        final hanziStr = v['hanzi'] as String? ?? '';
        final pinyinStr = v['pinyin'] as String? ?? '';

        _store.add(Vocab(
          id: id,
          hanzi: hanziStr,
          pinyin: pinyinStr,
          pinyinNormalized: _normalizePinyinLocalWeb(v['pinyinNormalized'] as String? ?? pinyinStr),
          characters: List<String>.from((v['characters'] as List?) ?? hanziStr.split('')),
          meanings: meaningsList,
          meaning: meaningFlat,
          exampleSentences: examplesList,
          level: v['level'] as int? ?? 1,
          wordType: wordType,
          isBookmarked: v['isBookmarked'] as bool? ?? false,
          isMastered: v['isMastered'] as bool? ?? false,
          repetitions: v['repetitions'] as int? ?? 0,
          easeFactor: (v['easeFactor'] as num?)?.toDouble() ?? 2.5,
          interval: v['interval'] as int? ?? v['srsInterval'] as int? ?? 0,
          nextReview: DateTime.parse(v['nextReview'] as String? ?? DateTime.now().toUtc().toIso8601String()),
        ));
      }

      final listFiles = ['hsk1.json', 'hsk2.json', 'hsk3.json', 'hsk4.json', 'hsk5.json', 'hsk6.json'];
      for (final fileName in listFiles) {
        try {
          final jsonStr = await rootBundle.loadString('assets/data/$fileName');
          final decoded = json.decode(jsonStr);

          if (decoded is List) {
            for (var v in decoded) {
              final map = v as Map<String, dynamic>;
              final id = map['id'] as String? ?? '${map['hanzi']}_${map['level']}';
              addVocab(map, id);
            }
          } else if (decoded is Map) {
            for (var e in decoded.entries) {
              addVocab(e.value as Map<String, dynamic>, e.key);
            }
          }
        } catch (e) {
          // ignore: avoid_print
          print('⚠️ [Web] Skipping $fileName: $e');
        }
      }

      // ignore: avoid_print
      print('✅ [Web] Seeded ${_store.length} vocab items (in-memory)');
    } catch (e) {
      // ignore: avoid_print
      print('❌ [Web] Vocab seed error: $e');
    }
  }

  static String _normalizePinyinLocalWeb(String pinyin) {
    const toneMap = {
      'ā': 'a', 'á': 'a', 'ǎ': 'a', 'à': 'a',
      'ē': 'e', 'é': 'e', 'ě': 'e', 'è': 'e',
      'ī': 'i', 'í': 'i', 'ǐ': 'i', 'ì': 'i',
      'ō': 'o', 'ó': 'o', 'ǒ': 'o', 'ò': 'o',
      'ū': 'u', 'ú': 'u', 'ǔ': 'u', 'ù': 'u',
      'ǖ': 'v', 'ǘ': 'v', 'ǚ': 'v', 'ǜ': 'v', 'ü': 'v',
    };
    var result = pinyin.toLowerCase();
    toneMap.forEach((t, p_) => result = result.replaceAll(t, p_));
    return result.replaceAll(RegExp(r'[\s\d]'), '');
  }

  @override
  Future<void> reseed() async {
    await _seedFromAssets();
  }
}
