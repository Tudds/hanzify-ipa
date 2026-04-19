import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hanzify/core/utils/vocab_parser.dart' show VocabJsonParser;
import '../../../vocab/domain/entities/vocab.dart';
import '../../domain/entities/character.dart';
import 'character_local_datasource.dart';

class CharacterWebDataSourceImpl implements CharacterLocalDataSource {
  final List<Character> _store = [];
  final List<Vocab> _vocabStore = []; // Need for vocabContainingChar

  CharacterWebDataSourceImpl._();

  static Future<CharacterWebDataSourceImpl> init() async {
    final ds = CharacterWebDataSourceImpl._();
    await ds._seedFromAssets();
    return ds;
  }

  @override
  Future<Character?> getByChar(String char) async {
    try {
      return _store.firstWhere((c) => c.char == char);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Vocab>> getVocabContainingChar(String char) async {
    // Note: In a real app, this might be slow if _vocabStore is huge.
    // But on web we only have HSK 1-3 (~600 words).
    return _vocabStore.where((v) => v.hanzi.contains(char)).toList();
  }

  Future<void> _seedFromAssets() async {
    try {
      // 1. Seed Characters
      final charFiles = ['char_hsk1.json', 'char_hsk2.json', 'char_hsk3.json'];
      for (final fileName in charFiles) {
        try {
          final jsonStr = await rootBundle.loadString('assets/data/$fileName');
          final decoded = json.decode(jsonStr);
          if (decoded is List) {
            for (var cRaw in decoded) {
              final c = cRaw as Map<String, dynamic>;
              final charVal = c['char'] as String? ?? c['character'] as String? ?? '';
              if (charVal.isEmpty) continue;

              final rawStrokes = c['strokes'] as List? ?? [];
              final strokesList = rawStrokes.map((s) => s.toString()).toList();

              _store.add(Character(
                char: charVal,
                strokes: strokesList,
                hskLevel: c['hskLevel'] as int?,
                radical: c['radical'] as String?,
                strokeCount: c['strokeCount'] as int? ?? strokesList.length,
                pinyin: c['pinyin'] as String?,
                definition: c['definition'] as String?,
                definitionVi: c['definitionVi'] as String?,
              ));
            }
          }
        } catch (e) {
          debugPrint('⚠️ [WebChar] Error seeding $fileName: $e');
        }
      }

      // 2. Seed Vocabs (needed for getVocabContainingChar)
      // Since VocabWebDataSource also does this, it's redundant but necessary if we want isolation.
      // Alternatively, we could inject the vocab store.
      final vocabFiles = ['hsk1.json', 'hsk2.json', 'hsk3.json'];
      for (final fileName in vocabFiles) {
        try {
          final jsonStr = await rootBundle.loadString('assets/data/$fileName');
          final decoded = json.decode(jsonStr);
          if (decoded is List) {
            final inferredLevel = int.tryParse(fileName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
            for (var v in decoded) {
              final map = v as Map<String, dynamic>;
              final id = map['id'] as String? ?? '${map['hanzi']}_$inferredLevel';
              // Note: We use the same parser logic as VocabWebDataSource
              // Importing from core utils if available
              _vocabStore.add(VocabJsonParser.parse(map, id: id, defaultLevel: inferredLevel));
            }
          }
        } catch (e) {
          debugPrint('⚠️ [WebChar] Error seeding vocab $fileName: $e');
        }
      }

      debugPrint('✅ [WebChar] Seeded ${_store.length} characters & ${_vocabStore.length} vocabs');
    } catch (e) {
      debugPrint('❌ [WebChar] Global seed error: $e');
    }
  }
}

