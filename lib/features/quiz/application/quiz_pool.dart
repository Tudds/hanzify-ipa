import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hsk_levels.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../dictionary/application/library_state.dart';
import '../../dictionary/domain/vocab_item.dart';

class QuizPool {
  const QuizPool({required this.vocab});

  final List<VocabItem> vocab;

  QuizPool sample({int level = 1, int count = 8, int? seed}) {
    final pool = vocab.where((v) => v.level == level).toList();
    if (pool.length <= count) return QuizPool(vocab: pool);
    final rng = Random(seed);
    pool.shuffle(rng);
    return QuizPool(vocab: pool.take(count).toList());
  }
}

final quizPoolProvider = FutureProvider.autoDispose<QuizPool>((
  ref,
) async {
  final vocab = await ref.watch(vocabLibraryProvider.future);
  return QuizPool(vocab: vocab);
});

class QuizLevelNotifier extends Notifier<int> {
  static const _key = 'quiz_level';

  @override
  int build() {
    final saved = ref.watch(sharedPreferencesProvider).getInt(_key);
    if (saved != null && saved >= kMinHskLevel && saved <= kMaxHskLevel) {
      return saved;
    }
    return ref.watch(
      userProfileProvider.select((profile) => profile.activeLevel),
    );
  }

  void set(int level) {
    state = level;
    unawaited(ref.read(sharedPreferencesProvider).setInt(_key, level));
  }
}

final quizLevelProvider = NotifierProvider<QuizLevelNotifier, int>(
  QuizLevelNotifier.new,
);
