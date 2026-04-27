import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../data/datasources/grammar_local_datasource.dart';
import 'grammar_providers_web.dart'
    if (dart.library.io) 'grammar_providers_native.dart' as platform;
import '../../data/repositories/grammar_repository_impl.dart';
import '../../domain/entities/grammar_point.dart';
import '../../domain/repositories/grammar_repository.dart';

part 'grammar_providers.g.dart';

// ============================================================================
// DataSource & Repository Providers (code-gen, keepAlive)
// Dùng chung appDatabaseProvider từ core/
// ============================================================================

@Riverpod(keepAlive: true)
GrammarLocalDataSource grammarLocalDataSource(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return platform.createNativeDataSource(db);
}

@Riverpod(keepAlive: true)
GrammarRepository grammarRepository(Ref ref) {
  final ds = ref.watch(grammarLocalDataSourceProvider);
  return GrammarRepositoryImpl(ds);
}

// ============================================================================
// Grammar List Provider — loads all grammar points from DB
// ============================================================================

@Riverpod(keepAlive: true)
class GrammarList extends _$GrammarList {
  @override
  Future<List<GrammarPoint>> build() async {
    // Watch search query → khi query thay đổi, tự động rebuild từ DB
    final query = ref.watch(grammarSearchQueryProvider);
    final repository = ref.read(grammarRepositoryProvider);
    if (query.isEmpty) {
      return repository.getAll();
    } else {
      return repository.search(query);
    }
  }

  /// Reload danh sách (giữ nguyên query hiện tại).
  Future<void> reload() async {
    state = const AsyncLoading();
    final query = ref.read(grammarSearchQueryProvider);
    final repository = ref.read(grammarRepositoryProvider);
    state = await AsyncValue.guard(() async {
      if (query.isEmpty) {
        return repository.getAll();
      } else {
        return repository.search(query);
      }
    });
  }

  /// Toggle bookmark on a grammar point.
  Future<void> toggleBookmark(GrammarPoint grammar) async {
    final updated = grammar.copyWith(isBookmarked: !grammar.isBookmarked);
    await ref.read(grammarRepositoryProvider).update(updated);
    ref.read(syncProvider.notifier).push().ignore();
    await reload();
  }

  /// Toggle mastered on a grammar point.
  Future<void> toggleMastered(GrammarPoint grammar) async {
    final updated = grammar.copyWith(isMastered: !grammar.isMastered);
    await ref.read(grammarRepositoryProvider).update(updated);
    ref.read(syncProvider.notifier).push().ignore();
    await reload();
  }
}

// ============================================================================
// Grammar By Level Provider — filtered by HSK level
// ============================================================================

@riverpod
Future<List<GrammarPoint>> grammarByLevel(Ref ref, int level) async {
  final repository = ref.watch(grammarRepositoryProvider);
  return repository.getByLevel(level);
}

// ============================================================================
// Grammar By Category Provider — filtered by category
// ============================================================================

@riverpod
Future<List<GrammarPoint>> grammarByCategory(Ref ref, String category) async {
  final repository = ref.watch(grammarRepositoryProvider);
  return repository.getByCategory(category);
}

// ============================================================================
// Grammar Detail Provider — single grammar point by ID
// ============================================================================

@riverpod
Future<GrammarPoint?> grammarDetail(Ref ref, String id) async {
  final repository = ref.watch(grammarRepositoryProvider);
  return repository.getById(id);
}

// ============================================================================
@riverpod
class GrammarSearchQuery extends _$GrammarSearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query;
}

// ============================================================================
// Grammar Stats — summary counts for dashboard/profile
// ============================================================================

@riverpod
GrammarStats grammarStats(Ref ref) {
  final allAsync = ref.watch(grammarListProvider);
  return allAsync.when(
    data: (list) {
      final total = list.length;
      final bookmarked = list.where((g) => g.isBookmarked).length;
      final mastered = list.where((g) => g.isMastered).length;
      return GrammarStats(
        total: total,
        bookmarked: bookmarked,
        mastered: mastered,
      );
    },
    loading: () => const GrammarStats(),
    error: (error, stack) => const GrammarStats(),
  );
}

/// Data class cho grammar statistics.
class GrammarStats {
  final int total;
  final int bookmarked;
  final int mastered;

  const GrammarStats({
    this.total = 0,
    this.bookmarked = 0,
    this.mastered = 0,
  });
}
