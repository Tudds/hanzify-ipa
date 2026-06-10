import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  int build() {
    return ref.watch(
      userProfileProvider.select((profile) => profile.activeLevel),
    );
  }

  void set(int level) => state = level;
}

final quizLevelProvider = NotifierProvider<QuizLevelNotifier, int>(
  QuizLevelNotifier.new,
);
