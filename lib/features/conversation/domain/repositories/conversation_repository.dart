import '../entities/conversation_context.dart';

/// Repository interface cho Conversation feature.
abstract class ConversationRepository {
  Future<List<ConversationContext>> getAll();
  Future<ConversationContext?> getById(String id);
  Future<List<ConversationContext>> getByLevel(int level);
  Future<List<ConversationContext>> getByCategory(String category);
  Future<List<ConversationContext>> search(String query);
  Future<List<ConversationContext>> getByIds(List<String> ids);
  Future<void> update(ConversationContext conversation);
}
