import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../vocab/domain/entities/vocab.dart';
import '../../../vocab/data/datasources/vocab_web_datasource_impl.dart';
import '../../domain/entities/character.dart';
import 'character_local_datasource.dart';

class CharacterWebDataSourceImpl implements CharacterLocalDataSource {
  final List<Character> _store = [];
  final VocabWebDataSourceImpl _vocabWebDs;

  CharacterWebDataSourceImpl._(this._vocabWebDs);

  static Future<CharacterWebDataSourceImpl> init({required VocabWebDataSourceImpl vocabWebDs}) async {
    final ds = CharacterWebDataSourceImpl._(vocabWebDs);
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
    final allVocab = await _vocabWebDs.getAll();
    return allVocab.where((v) => v.hanzi.contains(char)).toList();
  }

  Future<void> _seedFromAssets() async {
    try {
      // 1. Seed Characters
      final charFiles = ['char_hsk1.json', 'char_hsk2.json', 'char_hsk3.json', 'char_hsk4.json'];
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

      debugPrint('✅ [WebChar] Seeded ${_store.length} characters');
    } catch (e) {
      debugPrint('❌ [WebChar] Global seed error: $e');
    }
  }
}

