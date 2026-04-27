import 'graph_models.dart';

// Weights theo spec ranking_algorithm.md Phase 1
const _wNovelty = 0.50;
const _wCoverage = 0.30;
const _wFreq = 0.15;
const _wLevel = 0.05;

/// Rank vocab IDs by context relevance for a conversation.
///
/// [vocabIds] — vocab xuất hiện trong conv (từ inverted index)
/// [sentencesPerVocab] — sentenceIds trong conv này cho mỗi vocab
/// [convLevel] — HSK level của conversation (default 1)
/// [vocabLevels] — HSK level của từng vocab (nếu biết)
List<RankedVocab> rankContextVocabs(
  List<String> vocabIds,
  Map<String, List<String>> sentencesPerVocab, {
  int convLevel = 1,
  Map<String, int>? vocabLevels,
}) {
  if (vocabIds.isEmpty) return [];

  final maxOccurrences = vocabIds.fold<int>(
    1,
    (max, id) {
      final len = sentencesPerVocab[id]?.length ?? 0;
      return len > max ? len : max;
    },
  );

  final ranked = vocabIds.map((vocabId) {
    final sents = sentencesPerVocab[vocabId] ?? [];
    final occurrences = sents.length;

    // novelty: xuất hiện nhiều trong conv này → cao
    final novelty = maxOccurrences > 0 ? occurrences / maxOccurrences : 0.0;

    // coverage_gap: level match với conv
    final vocabLevel = vocabLevels?[vocabId] ?? convLevel;
    final coverage = _coverageGap(vocabLevel, convLevel);

    // freq_norm: Phase 1 — dùng occurrences làm proxy (không có global count)
    final freqNorm = occurrences > 0 ? (occurrences / maxOccurrences) * 0.5 : 0.1;

    // level_match: Phase 1 = 1.0 (chưa track user level)
    const levelMatch = 1.0;

    final score = _wNovelty * novelty +
        _wCoverage * coverage +
        _wFreq * freqNorm +
        _wLevel * levelMatch;

    return RankedVocab(vocabId: vocabId, score: score, sentenceIds: sents);
  }).toList();

  ranked.sort((a, b) => b.score.compareTo(a.score));
  return ranked;
}

double _coverageGap(int vocabLevel, int convLevel) {
  if (vocabLevel == convLevel) return 1.0;
  if (vocabLevel < convLevel) return 0.6;
  if (vocabLevel == convLevel + 1) return 0.3;
  return 0.0;
}
