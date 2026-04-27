import 'dart:convert';
import 'package:flutter/services.dart';
import 'graph_models.dart';
import 'graph_repository.dart';
import 'ranking.dart';

/// Đọc Context Graph từ assets/data/graph/*.json, cache in-memory.
/// Fail-safe: mọi lỗi load → trả empty, không crash UI.
class GraphRepositoryAssetImpl implements GraphRepository {
  // Raw inverted indexes (loaded once)
  Map<String, List<String>> _convToVocab = {};
  Map<String, List<String>> _vocabToConv = {};
  Map<String, List<String>> _vocabToSentence = {};
  Map<String, List<String>> _convToGrammar = {};
  Map<String, List<String>> _grammarToSentence = {};

  bool _loaded = false;

  GraphRepositoryAssetImpl._();

  static Future<GraphRepositoryAssetImpl> load() async {
    final repo = GraphRepositoryAssetImpl._();
    await repo._loadAll();
    return repo;
  }

  Future<void> _loadAll() async {
    try {
      _convToVocab = await _loadInverted('conv_to_vocab.json');
      _vocabToConv = await _loadInverted('vocab_to_conv.json');
      _vocabToSentence = await _loadInverted('vocab_to_sentence.json');
      _convToGrammar = await _loadInverted('conv_to_grammar.json');
      _grammarToSentence = await _loadInverted('grammar_to_sentence.json');
      _loaded = true;
    } catch (e) {
      // Graph is enhancement — silently degrade
      debugPrint('GraphRepository: load failed ($e), graph disabled');
    }
  }

  static Future<Map<String, List<String>>> _loadInverted(String filename) async {
    final raw = await rootBundle.loadString('assets/data/graph/inverted/$filename');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json.map((k, v) => MapEntry(k, List<String>.from(v as List)));
  }

  // ── GraphRepository ────────────────────────────────────────────────────────

  @override
  Future<ConversationGraphContext> getConversationContext(String convId) async {
    if (!_loaded) return _emptyContext(convId);

    final vocabIds = _convToVocab[convId] ?? [];
    final grammarIds = _convToGrammar[convId] ?? [];

    // Build sentence sets per vocab for this conv
    final vocabSentences = <String, List<String>>{};
    for (final vId in vocabIds) {
      final sents = (_vocabToSentence[vId] ?? [])
          .where((s) => s.startsWith('$convId#'))
          .toList();
      vocabSentences[vId] = sents;
    }

    final ranked = rankContextVocabs(vocabIds, vocabSentences);

    final grammarRefs = grammarIds.map((gId) {
      final sents = (_grammarToSentence[gId] ?? [])
          .where((s) => s.startsWith('$convId#'))
          .toList();
      return ConvGrammarRef(grammarId: gId, sentenceIds: sents);
    }).toList();

    return ConversationGraphContext(
      convId: convId,
      rankedVocabs: ranked,
      grammarRefs: grammarRefs,
    );
  }

  @override
  Future<List<VocabConvRef>> getConvsForVocab(String vocabId) async {
    if (!_loaded) return [];
    final convIds = _vocabToConv[vocabId] ?? [];
    return convIds.map((cId) {
      final sents = (_vocabToSentence[vocabId] ?? [])
          .where((s) => s.startsWith('$cId#'))
          .toList();
      return VocabConvRef(convId: cId, sentenceIds: sents);
    }).toList();
  }

  @override
  Future<List<String>> getSentencesForGrammar(String grammarId) async {
    if (!_loaded) return [];
    return _grammarToSentence[grammarId] ?? [];
  }

  @override
  Future<List<String>> getVocabIdsForConv(String convId) async {
    if (!_loaded) return [];
    return _convToVocab[convId] ?? [];
  }

  @override
  Future<List<String>> getGrammarIdsForConv(String convId) async {
    if (!_loaded) return [];
    return _convToGrammar[convId] ?? [];
  }

  ConversationGraphContext _emptyContext(String convId) => ConversationGraphContext(
        convId: convId,
        rankedVocabs: [],
        grammarRefs: [],
      );
}

// ignore: avoid_print
void debugPrint(String msg) => print(msg);
