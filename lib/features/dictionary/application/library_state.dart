import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/user_profile_provider.dart';
import '../data/library_repository.dart';
import '../domain/grammar_item.dart';
import '../domain/vocab_item.dart';

final vocabLibraryProvider = FutureProvider.autoDispose<List<VocabItem>>((
  ref,
) async {
  return ref.watch(libraryRepositoryProvider).loadVocab();
});

final grammarLibraryProvider = FutureProvider.autoDispose<List<GrammarItem>>((
  ref,
) async {
  return ref.watch(libraryRepositoryProvider).loadGrammar();
});

/// Vocab for a single HSK level — parses only that level's file. Used by the
/// dictionary when a specific level filter is active so it doesn't decode the
/// whole library.
final vocabLibraryForLevelProvider =
    FutureProvider.autoDispose.family<List<VocabItem>, int>((ref, level) async {
  return ref.watch(libraryRepositoryProvider).loadVocabLevel(level);
});

/// Grammar for a single HSK level. See [vocabLibraryForLevelProvider].
final grammarLibraryForLevelProvider =
    FutureProvider.autoDispose.family<List<GrammarItem>, int>((
  ref,
  level,
) async {
  return ref.watch(libraryRepositoryProvider).loadGrammarLevel(level);
});

class LibraryFilter {
  const LibraryFilter({this.level, this.query = ''});

  final int? level;
  final String query;

  LibraryFilter copyWith({Object? level = _sentinel, String? query}) {
    return LibraryFilter(
      level: identical(level, _sentinel) ? this.level : level as int?,
      query: query ?? this.query,
    );
  }

  static const _sentinel = Object();
}

class LibraryFilterNotifier extends Notifier<LibraryFilter> {
  @override
  LibraryFilter build() {
    // Mặc định lọc theo level của user (mở app là thấy đúng trình độ);
    // chip "Tất cả" vẫn cho phép bỏ lọc (setLevel(null)).
    return LibraryFilter(
      level: ref.watch(
        userProfileProvider.select((profile) => profile.activeLevel),
      ),
    );
  }

  void setLevel(int? level) {
    state = state.copyWith(level: level);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }
}

final libraryFilterProvider =
    NotifierProvider<LibraryFilterNotifier, LibraryFilter>(
  LibraryFilterNotifier.new,
);
