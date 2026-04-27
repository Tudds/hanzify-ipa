import 'package:equatable/equatable.dart';

// ── Node types ────────────────────────────────────────────────────────────────

enum GraphNodeType { vocab, grammar, conversation }

class GraphNode extends Equatable {
  final String id;
  final GraphNodeType type;
  final String label;
  final int level;

  const GraphNode({
    required this.id,
    required this.type,
    required this.label,
    required this.level,
  });

  factory GraphNode.fromJson(Map<String, dynamic> json) => GraphNode(
        id: json['id'] as String,
        type: GraphNodeType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => GraphNodeType.vocab,
        ),
        label: json['label'] as String? ?? '',
        level: json['level'] as int? ?? 1,
      );

  @override
  List<Object?> get props => [id, type, level];
}

// ── Edge types ────────────────────────────────────────────────────────────────

enum GraphEdgeType { vocabInConv, grammarInConv }

class GraphEdge extends Equatable {
  final GraphEdgeType type;
  final String from;
  final String to;
  final double weight;

  const GraphEdge({
    required this.type,
    required this.from,
    required this.to,
    this.weight = 1.0,
  });

  factory GraphEdge.fromJson(Map<String, dynamic> json) => GraphEdge(
        type: json['type'] == 'grammar_in_conv'
            ? GraphEdgeType.grammarInConv
            : GraphEdgeType.vocabInConv,
        from: json['from'] as String,
        to: json['to'] as String,
        weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      );

  @override
  List<Object?> get props => [type, from, to];
}

// ── Context results ───────────────────────────────────────────────────────────

/// Vocab ranked by context relevance for a given conversation.
class RankedVocab extends Equatable {
  final String vocabId;
  final double score;
  final List<String> sentenceIds; // sentences in this conv where vocab appears

  const RankedVocab({
    required this.vocabId,
    required this.score,
    required this.sentenceIds,
  });

  @override
  List<Object?> get props => [vocabId, score];
}

/// Grammar referenced in a conversation + its example sentence IDs.
class ConvGrammarRef extends Equatable {
  final String grammarId;
  final List<String> sentenceIds;

  const ConvGrammarRef({required this.grammarId, required this.sentenceIds});

  @override
  List<Object?> get props => [grammarId];
}

/// Full context for a conversation screen.
class ConversationGraphContext extends Equatable {
  final String convId;
  final List<RankedVocab> rankedVocabs;
  final List<ConvGrammarRef> grammarRefs;

  const ConversationGraphContext({
    required this.convId,
    required this.rankedVocabs,
    required this.grammarRefs,
  });

  @override
  List<Object?> get props => [convId];
}

/// Conversations where a vocab appears + relevant sentence IDs.
class VocabConvRef extends Equatable {
  final String convId;
  final List<String> sentenceIds;

  const VocabConvRef({required this.convId, required this.sentenceIds});

  @override
  List<Object?> get props => [convId];
}
