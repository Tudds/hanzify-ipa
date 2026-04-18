import '../../domain/entities/conversation_context.dart';

/// Abstract data source cho Conversation feature.
abstract class ConversationLocalDataSource {
  /// Lấy toàn bộ bài hội thoại, sắp xếp theo level rồi id.
  Future<List<ConversationContext>> getAll({int limit = 0, int offset = 0});

  /// Lấy bài hội thoại theo id.
  Future<ConversationContext?> getById(String id);

  /// Lấy bài hội thoại theo HSK level.
  Future<List<ConversationContext>> getByLevel(int level, {int limit = 0, int offset = 0});

  /// Lấy bài hội thoại theo category.
  Future<List<ConversationContext>> getByCategory(String category, {int limit = 0, int offset = 0});

  /// Tìm kiếm hội thoại theo title hoặc description.
  Future<List<ConversationContext>> search(String query, {int limit = 0, int offset = 0});

  /// Đếm tổng số conversations.
  Future<int> count();

  /// Cập nhật bài hội thoại (bookmark, mastered).
  Future<void> update(ConversationContext conversation);
}
