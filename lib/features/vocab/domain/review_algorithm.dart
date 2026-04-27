import 'entities/vocab.dart';

/// SM-2 spaced repetition algorithm. Pure function — không cần dependency.
Vocab reviewVocab(Vocab vocab, int quality) {
  double ef = vocab.easeFactor;
  int rep = vocab.repetitions;
  int interval = vocab.interval;

  if (quality < 3) {
    rep = 0;
    interval = 1;
  } else {
    if (rep == 0) {
      interval = 1;
    } else if (rep == 1) {
      interval = 6;
    } else {
      interval = (interval * ef).round();
    }
    rep++;
  }

  ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
  if (ef < 1.3) ef = 1.3;

  bool isMastered = vocab.isMastered;
  if (interval >= 21) {
    isMastered = true;
  }

  return vocab.copyWith(
    repetitions: rep,
    easeFactor: ef,
    interval: interval,
    nextReview: DateTime.now().add(Duration(days: interval)),
    isMastered: isMastered,
    updatedAt: DateTime.now().toUtc(),
  );
}
