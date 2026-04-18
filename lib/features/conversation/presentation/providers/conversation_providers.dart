import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/datasources/conversation_local_datasource.dart';
import '../../data/datasources/conversation_local_datasource_impl.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../domain/entities/conversation_context.dart';
import '../../domain/repositories/conversation_repository.dart';

part 'conversation_providers.g.dart';

// ============================================================================
// DataSource & Repository Providers (code-gen, keepAlive)
// Dùng chung appDatabaseProvider từ core/
// ============================================================================

@Riverpod(keepAlive: true)
ConversationLocalDataSource conversationLocalDataSource(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return ConversationLocalDataSourceImpl(db);
}

@Riverpod(keepAlive: true)
ConversationRepository conversationRepository(Ref ref) {
  final ds = ref.watch(conversationLocalDataSourceProvider);
  return ConversationRepositoryImpl(ds);
}

// ============================================================================
// Conversation List Provider — loads all conversations from DB
// ============================================================================

@Riverpod(keepAlive: true)
class ConversationList extends _$ConversationList {
  @override
  Future<List<ConversationContext>> build() async {
    // Watch search query → khi query thay đổi, tự động rebuild từ DB
    final query = ref.watch(conversationSearchQueryProvider);
    final repository = ref.read(conversationRepositoryProvider);
    if (query.isEmpty) {
      return repository.getAll();
    } else {
      return repository.search(query);
    }
  }

  /// Reload danh sách (giữ nguyên query hiện tại).
  Future<void> reload() async {
    state = const AsyncLoading();
    final query = ref.read(conversationSearchQueryProvider);
    final repository = ref.read(conversationRepositoryProvider);
    state = await AsyncValue.guard(() async {
      if (query.isEmpty) {
        return repository.getAll();
      } else {
        return repository.search(query);
      }
    });
  }

  /// Toggle bookmark on a conversation.
  Future<void> toggleBookmark(ConversationContext conversation) async {
    final updated =
        conversation.copyWith(isBookmarked: !conversation.isBookmarked);
    await ref.read(conversationRepositoryProvider).update(updated);
    await reload();
  }

  /// Toggle mastered on a conversation.
  Future<void> toggleMastered(ConversationContext conversation) async {
    final updated =
        conversation.copyWith(isMastered: !conversation.isMastered);
    await ref.read(conversationRepositoryProvider).update(updated);
    await reload();
  }
}

// ============================================================================
// Conversation By Level Provider — filtered by HSK level
// ============================================================================

@riverpod
Future<List<ConversationContext>> conversationByLevel(Ref ref, int level) async {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getByLevel(level);
}

// ============================================================================
// Conversation By Category Provider — filtered by category
// ============================================================================

@riverpod
Future<List<ConversationContext>> conversationByCategory(Ref ref, String category) async {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getByCategory(category);
}

// ============================================================================
// Conversation Detail Provider — single conversation by ID
// ============================================================================

@riverpod
Future<ConversationContext?> conversationDetail(Ref ref, String id) async {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getById(id);
}

// ============================================================================
// Search Query Provider
// ============================================================================

@riverpod
class ConversationSearchQuery extends _$ConversationSearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query;
}

// ============================================================================
// Conversation Stats — summary counts for dashboard/profile
// ============================================================================

@riverpod
ConversationStats conversationStats(Ref ref) {
  final allAsync = ref.watch(conversationListProvider);
  return allAsync.when(
    data: (list) {
      final total = list.length;
      final bookmarked = list.where((c) => c.isBookmarked).length;
      final mastered = list.where((c) => c.isMastered).length;
      return ConversationStats(
        total: total,
        bookmarked: bookmarked,
        mastered: mastered,
      );
    },
    loading: () => const ConversationStats(),
    error: (error, stack) => const ConversationStats(),
  );
}

/// Data class cho conversation statistics.
class ConversationStats {
  final int total;
  final int bookmarked;
  final int mastered;

  const ConversationStats({
    this.total = 0,
    this.bookmarked = 0,
    this.mastered = 0,
  });
}
