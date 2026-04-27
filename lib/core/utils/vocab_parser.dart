// ============================================================================
// VocabJsonParser — shared JSON → Vocab conversion for seed logic.
// Used by both app_database.dart (native) and vocab_web_datasource_impl.dart (web).
// ============================================================================
import '../../features/vocab/domain/entities/vocab.dart';
import 'pinyin_utils.dart' show normalizePinyin;

class VocabJsonParser {
  /// Parse a single JSON map into a Vocab entity.
  ///
  /// [map] — raw JSON object from asset file.
  /// [id] — unique identifier (usually "hanzi_level" or map key).
  /// [defaultLevel] — fallback HSK level when `map['level']` is missing.
  static Vocab parse(Map<String, dynamic> map, {required String id, int defaultLevel = 1}) {
    final meaningsList = (map['meanings'] as List?)?.map((m) {
          final mapM = m as Map<String, dynamic>;
          return Meaning(
            pos: mapM['pos'] as String? ?? 'other',
            vi: mapM['vi'] as String? ?? '',
            en: mapM['en'] as String? ?? '',
          );
        }).toList() ??
        [];

    final examplesList = (map['exampleSentences'] as List?)?.map((e) {
          if (e is Map) {
            final mapE = e as Map<String, dynamic>;
            return ExampleSentence(
              cn: mapE['cn'] as String? ?? '',
              pinyin: mapE['pinyin'] as String? ?? '',
              vi: mapE['vi'] as String? ?? '',
            );
          }
          return ExampleSentence(cn: e as String, pinyin: '', vi: '');
        }).toList() ??
        [];

    final wordType = map['wordType'] as String? ??
        (meaningsList.isNotEmpty ? meaningsList.first.pos : 'other');

    final hanziStr = map['hanzi'] as String? ?? '';
    final pinyinStr = map['pinyin'] as String? ?? '';

    return Vocab(
      id: id,
      hanzi: hanziStr,
      pinyin: pinyinStr,
      pinyinNormalized: normalizePinyin(map['pinyinNormalized'] as String? ?? pinyinStr),
      characters: List<String>.from((map['characters'] as List?) ?? hanziStr.split('')),
      meanings: meaningsList,
      exampleSentences: examplesList,
      level: map['level'] as int? ?? defaultLevel,
      wordType: wordType,
      isBookmarked: map['isBookmarked'] as bool? ?? false,
      isMastered: map['isMastered'] as bool? ?? false,
      repetitions: map['repetitions'] as int? ?? 0,
      easeFactor: (map['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: map['interval'] as int? ?? map['srsInterval'] as int? ?? 0,
      nextReview: DateTime.parse(
        map['nextReview'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }
}
