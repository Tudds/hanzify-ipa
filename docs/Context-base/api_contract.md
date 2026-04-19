# API Contract — Dart interfaces

Không có backend — "API" ở đây là **repository + provider interface** trong Flutter.

---

## 1. GraphManifest

```dart
// lib/core/graph/graph_manifest.dart
class GraphManifest {
  final int graphVersion;
  final String dataHash;
  final DateTime generatedAt;
  final Map<String, int> nodeCounts; // {"vocab": 500, "grammar": 30, ...}
}

abstract interface class GraphRepository {
  Future<GraphManifest> loadManifest();

  /// Conversation → danh sách vocab ID với occurrences + spans
  Future<List<ConvVocabEdge>> vocabsInConversation(String convId);
  Future<List<ConvGrammarEdge>> grammarsInConversation(String convId);

  /// Reverse: Vocab → conversation usage
  Future<List<VocabConvUsage>> conversationsContainingVocab(String vocabId);
  Future<List<VocabSentence>> sentencesContainingVocab(String vocabId);

  /// Grammar → example sentences (cross-source)
  Future<List<GrammarSentence>> sentencesForGrammar(String grammarId);
}
```

Impl: `GraphRepositoryAssetImpl` — đọc `assets/data/graph/*.json`, cache in memory.

---

## 2. Edge DTOs

```dart
class ConvVocabEdge {
  final String vocabId;
  final int occurrences;      // số lần vocab xuất hiện trong conv
  final List<SpanRef> spans;  // mỗi span: {lineIdx, charStart, charEnd}
}

class ConvGrammarEdge {
  final String grammarId;
  final List<int> lineIndices; // các line mà grammar pattern match
}

class VocabConvUsage {
  final String convId;
  final int occurrences;
  final int firstLineIdx; // để auto-scroll
  final double density;   // precomputed: occurrences / total_lines
}

class VocabSentence {
  final String sentenceId;      // "conv_xxx#L3" hoặc "hsk1_0234#ex0"
  final String zh;
  final String? pinyin;
  final String? vi;
  final SpanRef highlight;      // vị trí vocab trong sentence
  final String source;          // "conversation" | "vocab_example"
}

class GrammarSentence {
  final String sentenceId;
  final String zh;
  final String? pinyin;
  final String? vi;
}

class SpanRef {
  final int start; // char offset (not byte)
  final int end;
}
```

---

## 3. Ranking

```dart
// lib/core/graph/ranking.dart — pure functions

class RankingContext {
  final int currentLevel;
  final String? currentConvId;
  final String? currentVocabId;
}

class RankingWeights {
  final double freq;
  final double novelty;
  final double coverage;
  final double level;

  static const phase1 = RankingWeights(
    freq: 0.15, novelty: 0.5, coverage: 0.3, level: 0.05,
  );
}

class ScoredNode<T> {
  final T node;
  final double score;
  final Map<String, double> breakdown; // debug
}

List<ScoredNode<ConvVocabEdge>> rankContextVocabs(
  List<ConvVocabEdge> edges,
  List<Vocab> hydrated,
  RankingContext ctx,
  RankingWeights weights,
);

List<ScoredNode<VocabConvUsage>> rankRelatedConversations(
  List<VocabConvUsage> usages,
  List<Conversation> hydrated,
  RankingContext ctx,
  RankingWeights weights,
);
```

---

## 4. Providers

```dart
@Riverpod(keepAlive: true)
GraphRepository graphRepository(GraphRepositoryRef ref) => GraphRepositoryAssetImpl();

@Riverpod(keepAlive: true)
Future<ConversationContext> conversationContext(Ref ref, String convId) async {
  final repo = ref.watch(graphRepositoryProvider);
  final conv = await ref.watch(conversationRepositoryProvider).getById(convId);
  final vocabEdges = await repo.vocabsInConversation(convId);
  final grammarEdges = await repo.grammarsInConversation(convId);
  final vocabs = await ref.watch(vocabRepositoryProvider)
      .getByIds(vocabEdges.map((e) => e.vocabId).toList());
  final grammars = await ref.watch(grammarRepositoryProvider)
      .getByIds(grammarEdges.map((e) => e.grammarId).toList());
  final rankedVocabs = rankContextVocabs(vocabEdges, vocabs,
      RankingContext(currentLevel: conv.level, currentConvId: convId),
      RankingWeights.phase1);
  return ConversationContext(conv, rankedVocabs, grammars);
}

@Riverpod(keepAlive: true)
Future<VocabContext> vocabContext(Ref ref, String vocabId) async { /* ... */ }
```

Lưu ý: cần thêm `getByIds()` batch methods vào `VocabRepository`, `GrammarRepository`, `ConversationRepository` (hiện chỉ có `getAll`/`getById`).

---

## 5. Build script

```
dart run tool/build_graph.dart
```

Input: `assets/data/{hsk,grammar_hsk,conversation,char_hsk}*.json`
Output: `assets/data/graph/**`

Chạy:
- Tay khi author update data.
- CI pre-build hook (sau `flutter pub get`, trước `flutter build`).
- **Không** chạy runtime.

Script tự in stats: node/edge count, warnings (vocab ID không tìm thấy trong từ điển, grammar không có ví dụ, ...).

---

## 6. Error contracts

| Tình huống | Behavior |
|---|---|
| `assets/data/graph/meta.json` missing | Throw `GraphUnavailableException`, UI degrade |
| Edge ref ID không có trong dataset | Log warning, skip edge |
| JSON parse lỗi | Throw, surface lên UI banner |
| Version mismatch | Log warning, continue (forward compatible trong cùng major) |

Không retry, không fallback network — đây là asset bundle.
