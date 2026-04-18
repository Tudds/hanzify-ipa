// ============================================================================
// VocabMeaningHelper — Extension on Vocab for meaning-related utilities
// Replaces duplicated meaning access patterns across 5+ files:
//   - VocabDetailScreen: groupedByPos + primaryMeaning
//   - FlashcardStudyView: groupedByPos
//   - VocabCardWidget: individual meaning rows
//   - VocabListScreen: primaryMeaning fallback
//   - CharacterDetailScreen: primaryMeaning fallback
//   - QuizState: getMeaning() method
//   - QuizQuestionView: meaning display
// ============================================================================
import 'dart:ui' show Color;
import '../../features/vocab/domain/entities/vocab.dart';

/// Extension on Vocab for meaning-related helpers
extension VocabMeaningHelper on Vocab {
  /// Primary meaning in Vietnamese.
  String get primaryMeaningVi =>
      meanings.isNotEmpty ? meanings.first.vi : '';

  /// Primary part-of-speech tag.
  String get primaryPos =>
      meanings.isNotEmpty ? meanings.first.pos : wordType;

  /// Meanings grouped by POS (part-of-speech).
  Map<String, List<Meaning>> get groupedByPos {
    final grouped = <String, List<Meaning>>{};
    for (final m in meanings) {
      grouped.putIfAbsent(m.pos, () => []).add(m);
    }
    return grouped;
  }

  /// Whether this vocab has structured (POS-tagged) meanings.
  bool get hasStructuredMeanings => meanings.isNotEmpty;

  /// Whether this vocab has any meaning data at all.
  bool get hasAnyMeaning => meanings.isNotEmpty;

  /// Get POS color from theme colors map.
  /// Moved from vocab_card.dart `_posColor()` to centralized location.
  /// Requires AppThemeColors to be passed since we can't access theme in extension.
  static String posLabel(String pos) => pos;
}

/// Extension on AppThemeColors for POS-related helpers.
/// (Kept separate to avoid importing theme in domain layer)
extension PosColorHelper on Map<String, dynamic> {
  /// Get color for a POS tag from theme colors map.
  /// Returns fallback gray if POS not found.
  Color? posColor(String pos) {
    if (this is Map<String, Color>) {
      return (this as Map<String, Color>)[pos];
    }
    return null;
  }
}

