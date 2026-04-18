// lib/features/vocab/presentation/providers/vocab_filter_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/vocab.dart';
import '../../../../core/enums/filter_enums.dart';
import 'vocab_providers.dart';

part 'vocab_filter_provider.g.dart';

// ============================================================================
// VocabFilter state — dùng enum thay vì raw strings
// ============================================================================
class VocabFilter extends Equatable {
  final String query;
  final int level; // 0 = all
  final FilterWordType wordType;
  final FilterStatus status;

  const VocabFilter({
    this.query = '',
    this.level = 0,
    this.wordType = FilterWordType.all,
    this.status = FilterStatus.all,
  });

  @override
  List<Object?> get props => [query, level, wordType, status];

  VocabFilter copyWith({
    String? query,
    int? level,
    FilterWordType? wordType,
    FilterStatus? status,
  }) =>
      VocabFilter(
        query: query ?? this.query,
        level: level ?? this.level,
        wordType: wordType ?? this.wordType,
        status: status ?? this.status,
      );
}

// ============================================================================
// VocabFilterNotifier
// ============================================================================
@riverpod
class VocabFilterNotifier extends _$VocabFilterNotifier {
  @override
  VocabFilter build() => const VocabFilter();

  void setQuery(String q) => state = state.copyWith(query: q);
  void setLevel(int l) => state = state.copyWith(level: l);
  void setWordType(FilterWordType t) => state = state.copyWith(wordType: t);
  void setStatus(FilterStatus s) => state = state.copyWith(status: s);
  void clear() => state = const VocabFilter();
}

// ============================================================================
// vocabSearchProvider — DB search cho text query
// Khi query rỗng → trả về tất cả vocab (same as allVocabProvider).
// Khi query không rỗng → gọi repository.search() với DB LIKE query.
// Lưu ý: VocabListScreen dùng filteredVocabProvider (provider này)
// chứ không watch allVocabProvider riêng → tránh double DB query.
// ============================================================================
@riverpod
Future<List<Vocab>> vocabSearch(Ref ref) async {
  final filter = ref.watch(vocabFilterProvider);
  final repository = ref.watch(vocabRepositoryProvider);

  final hskLevel = filter.level > 0 ? filter.level : null;
  final wordType = filter.wordType != FilterWordType.all
      ? filterWordTypeToPos(filter.wordType)
      : null;
  final q = filter.query.trim();

  if (q.isEmpty && hskLevel == null && wordType == null) {
    return repository.getAll();
  }

  return repository.search(q, hskLevel: hskLevel, wordType: wordType);
}

// ============================================================================
// filteredVocabProvider — derived list dùng cho UI
// Kết hợp DB search (text query) + client-side filter (status/bookmark).
// ============================================================================
@riverpod
List<Vocab> filteredVocab(Ref ref) {
  final searchAsync = ref.watch(vocabSearchProvider);
  final filter = ref.watch(vocabFilterProvider);

  final all = searchAsync.value ?? [];

  // DB search đã xử lý: text query + level + wordType
  // Client-side chỉ cần filter status (mastered/bookmarked)
  if (filter.status == FilterStatus.mastered) {
    return all.where((v) => v.isMastered).toList();
  }
  if (filter.status == FilterStatus.bookmarked) {
    return all.where((v) => v.isBookmarked).toList();
  }

  return all;
}
