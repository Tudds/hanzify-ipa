// lib/features/vocab/presentation/providers/vocab_filter_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/vocab.dart';
import '../../data/datasources/pinyin_utils.dart';
import 'vocab_state.dart';

part 'vocab_filter_provider.g.dart';

// ============================================================================
// VocabFilter state
// ============================================================================
class VocabFilter extends Equatable {
  final String query;
  final int level; // 0 = all
  final String wordType; // 'all' = no filter
  final String status; // 'all', 'mastered', 'bookmarked'

  const VocabFilter({
    this.query = '',
    this.level = 0,
    this.wordType = 'all',
    this.status = 'all',
  });

  @override
  List<Object?> get props => [query, level, wordType, status];

  VocabFilter copyWith({
    String? query,
    int? level,
    String? wordType,
    String? status,
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
  void setWordType(String t) => state = state.copyWith(wordType: t);
  void setStatus(String s) => state = state.copyWith(status: s);
  void clear() => state = const VocabFilter();
}

// ============================================================================
// filteredVocabProvider — derived list dùng cho UI
// Chạy filter trên Dart-side để reactive theo filter state thay đổi.
// ============================================================================
@riverpod
List<Vocab> filteredVocab(Ref ref) {
  final all = ref.watch(allVocabProvider).value ?? [];
  final filter = ref.watch(vocabFilterProvider);

  return all.where((v) {
    // ── Level filter ─────────────────────────────────────────────────────
    if (filter.level > 0 && v.level != filter.level) return false;

    // ── Status filter ────────────────────────────────────────────────────
    if (filter.status == 'mastered' && !v.isMastered) return false;
    if (filter.status == 'bookmarked' && !v.isBookmarked) return false;

    // ── Word type filter ─────────────────────────────────────────────────
    if (filter.wordType != 'all') {
      final matchesMeanings = v.meanings.any((m) => m.pos == filter.wordType);
      final matchesLegacy = v.wordType == filter.wordType;
      if (!matchesMeanings && !matchesLegacy) return false;
    }

    // ── Text search ───────────────────────────────────────────────────────
    if (filter.query.isNotEmpty) {
      final q = filter.query.trim().toLowerCase();
      final qNorm = normalizePinyin(q);

      // 1. Hanzi exact / contains
      if (v.hanzi.contains(q)) return true;

      // 2. Pinyin: cả có dấu và không dấu
      if (v.pinyin.toLowerCase().contains(q)) return true;
      if (v.pinyinNormalized.contains(qNorm)) return true;

      // 3. Meaning: flat string + structured meanings list
      if (v.meaning.toLowerCase().contains(q)) return true;
      if (v.meanings.any((m) => m.vi.toLowerCase().contains(q))) return true;

      return false;
    }

    return true;
  }).toList();
}
