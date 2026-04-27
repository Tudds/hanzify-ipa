import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/graph/ranking.dart';

void main() {
  group('rankContextVocabs', () {
    test('returns empty list when vocabIds is empty', () {
      final result = rankContextVocabs([], {});
      expect(result, isEmpty);
    });

    test('vocab with more sentence appearances ranks higher', () {
      final result = rankContextVocabs(
        ['v1', 'v2'],
        {
          'v1': ['conv1#L0', 'conv1#L2', 'conv1#L4'], // 3 occurrences
          'v2': ['conv1#L1'],                          // 1 occurrence
        },
      );

      expect(result.length, 2);
      expect(result.first.vocabId, 'v1');
      expect(result.first.score, greaterThan(result.last.score));
    });

    test('preserves sentenceIds in result', () {
      final sents = ['conv1#L0', 'conv1#L2'];
      final result = rankContextVocabs(
        ['v1'],
        {'v1': sents},
      );

      expect(result.first.sentenceIds, equals(sents));
    });

    test('level match — same level scores higher than out-of-scope', () {
      // v1: same level as conv, v2: 2 levels above (score 0.0 coverage)
      final result = rankContextVocabs(
        ['v1', 'v2'],
        {
          'v1': ['conv1#L0'],
          'v2': ['conv1#L1'],
        },
        convLevel: 2,
        vocabLevels: {'v1': 2, 'v2': 4}, // v2 is 2 above → 0.0
      );

      expect(result.first.vocabId, 'v1');
    });

    test('scores are between 0 and 1', () {
      final result = rankContextVocabs(
        ['v1', 'v2', 'v3'],
        {
          'v1': ['conv1#L0', 'conv1#L1'],
          'v2': ['conv1#L2'],
          'v3': [],
        },
      );

      for (final r in result) {
        expect(r.score, greaterThanOrEqualTo(0.0));
        expect(r.score, lessThanOrEqualTo(1.0));
      }
    });

    test('results are sorted descending by score', () {
      final result = rankContextVocabs(
        ['a', 'b', 'c'],
        {
          'a': ['x#L0'],
          'b': ['x#L0', 'x#L1', 'x#L2'],
          'c': [],
        },
      );

      for (int i = 0; i < result.length - 1; i++) {
        expect(result[i].score, greaterThanOrEqualTo(result[i + 1].score));
      }
    });
  });
}
