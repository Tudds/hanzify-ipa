import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/profile/domain/entities/profile_stats.dart';

part 'profile_stats_provider.g.dart';

@Riverpod(keepAlive: true)
ProfileStats profileStats(Ref ref) {
  final vocabAsync = ref.watch(allVocabProvider);
  return vocabAsync.when(
    data: _compute,
    loading: () => const ProfileStats.empty(),
    error: (_, _) => const ProfileStats.empty(),
  );
}

ProfileStats _compute(List<Vocab> vocabs) {
  final mastered = vocabs.where((v) => v.isMastered).toList();
  final reviewed = vocabs.where((v) => v.interval > 0).toList();

  // ── Dominant HSK level ────────────────────────────────────────────────────
  // Ưu tiên: level có nhiều mastered nhất; fallback: level có nhiều reviewed nhất
  int dominantLevel = 0;
  final source = mastered.isNotEmpty ? mastered : reviewed;
  if (source.isNotEmpty) {
    final counts = <int, int>{};
    for (final v in source) {
      counts[v.level] = (counts[v.level] ?? 0) + 1;
    }
    dominantLevel = counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  // ── Streak ────────────────────────────────────────────────────────────────
  // Ước tính ngày ôn cuối: nextReview - interval days
  // (chính xác cho SM-2: interval = số ngày đến lần ôn tiếp theo)
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  final studiedDates = <DateTime>{};
  for (final v in reviewed) {
    if (v.interval <= 0) continue;
    final lastReviewed = v.nextReview.subtract(Duration(days: v.interval));
    final d = DateTime(lastReviewed.year, lastReviewed.month, lastReviewed.day);
    studiedDates.add(d);
  }

  int streak = 0;
  // Bắt đầu kiểm tra từ hôm nay; nếu hôm nay chưa ôn thì bắt đầu từ hôm qua
  var checkDate = studiedDates.contains(todayDate)
      ? todayDate
      : todayDate.subtract(const Duration(days: 1));

  while (studiedDates.contains(checkDate)) {
    streak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  }

  return ProfileStats(
    streakDays: streak,
    dominantHskLevel: dominantLevel,
    masteredCount: mastered.length,
    reviewedCount: reviewed.length,
  );
}
