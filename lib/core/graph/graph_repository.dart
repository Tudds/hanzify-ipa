import 'graph_models.dart';

/// Interface cho Context Graph. Fail-safe: mọi method đều có thể trả về
/// empty list / null thay vì throw — graph là enhancement layer, không block UI.
abstract class GraphRepository {
  /// Toàn bộ context của một conversation (vocab ranked + grammar refs).
  Future<ConversationGraphContext> getConversationContext(String convId);

  /// Tất cả conversation có chứa vocab này + sentence IDs tương ứng.
  Future<List<VocabConvRef>> getConvsForVocab(String vocabId);

  /// Sentence IDs trong conversation.json minh họa grammar này.
  Future<List<String>> getSentencesForGrammar(String grammarId);

  /// Vocab IDs xuất hiện trong conversation (chưa ranked).
  Future<List<String>> getVocabIdsForConv(String convId);

  /// Grammar IDs được tag cho conversation.
  Future<List<String>> getGrammarIdsForConv(String convId);
}
