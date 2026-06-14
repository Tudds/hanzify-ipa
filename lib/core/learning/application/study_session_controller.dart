import '../domain/fsrs.dart';
import 'quiz_generator.dart';

class StudyAnswerResult {
  const StudyAnswerResult({
    required this.isCorrect,
    required this.rating,
    required this.reviewResult,
    required this.reviewedCount,
  });

  final bool isCorrect;
  final SrsRating rating;
  final SrsReviewResult reviewResult;
  final int reviewedCount;
}

class StudySessionSnapshot {
  const StudySessionSnapshot({
    required this.cards,
    required this.logs,
    required this.reviewedCount,
  });

  final Map<String, SrsCard> cards;
  final List<SrsReviewLog> logs;
  final int reviewedCount;
}

class StudySessionController {
  StudySessionController({
    FsrsScheduler scheduler = const FsrsScheduler(),
    DateTime Function()? clock,
  }) : _scheduler = scheduler,
       _clock = clock ?? DateTime.now;

  final FsrsScheduler _scheduler;
  final DateTime Function() _clock;
  final Map<String, SrsCard> _cards = {};
  final List<SrsReviewLog> _logs = [];

  void hydrate(StudySessionSnapshot snapshot) {
    _cards
      ..clear()
      ..addAll(snapshot.cards);
    _logs
      ..clear()
      ..addAll(snapshot.logs);
  }

  StudyAnswerResult answer(LearningQuiz quiz, String selectedChoice) {
    final isCorrect = selectedChoice == quiz.answer;
    return recordAnswer(
      targetType: _targetTypeForQuiz(quiz),
      targetId: quiz.targetId ?? quiz.sourceCollocationId,
      cardType: _cardTypeForQuiz(quiz),
      rating: isCorrect ? SrsRating.good : SrsRating.again,
      isCorrect: isCorrect,
    );
  }

  /// Ghi nhận một lần trả lời mà không cần dựng [LearningQuiz] — dùng cho các
  /// drill Quiz (VocabItem) và quiz Shorts. Thẻ chung theo từ: id =
  /// `targetType:targetId:cardType` nên mọi nguồn cùng đẩy một lịch FSRS.
  StudyAnswerResult recordAnswer({
    required String targetType,
    required String targetId,
    String cardType = 'recognition',
    required SrsRating rating,
    bool? isCorrect,
  }) {
    final id = '$targetType:$targetId:$cardType';
    final card = _cards.putIfAbsent(
      id,
      () => SrsCard(
        id: id,
        targetType: targetType,
        targetId: targetId,
        cardType: cardType,
        state: SrsCardState.newCard,
      ),
    );
    final result = _scheduler.review(card, rating, _clock());
    _cards[result.card.id] = result.card;
    _logs.add(result.log);

    return StudyAnswerResult(
      isCorrect: isCorrect ?? (rating != SrsRating.again),
      rating: rating,
      reviewResult: result,
      reviewedCount: _logs.length,
    );
  }

  StudySessionSnapshot snapshot() {
    return StudySessionSnapshot(
      cards: Map.unmodifiable(_cards),
      logs: List.unmodifiable(_logs),
      reviewedCount: _logs.length,
    );
  }

  String _targetTypeForQuiz(LearningQuiz quiz) {
    switch (quiz.type) {
      case QuizType.grammarChoice:
      case QuizType.sentenceOrder:
        return 'grammar';
      case QuizType.vocabRecognition:
      case QuizType.vocabRecall:
      case QuizType.pinyinChoice:
      case QuizType.clozeCollocation:
        return 'vocab';
    }
  }

  String _cardTypeForQuiz(LearningQuiz quiz) {
    switch (quiz.type) {
      case QuizType.vocabRecognition:
      case QuizType.pinyinChoice:
        return 'recognition';
      case QuizType.vocabRecall:
        return 'recall';
      case QuizType.clozeCollocation:
        return 'cloze';
      case QuizType.grammarChoice:
        return 'grammar_choice';
      case QuizType.sentenceOrder:
        return 'sentence_build';
    }
  }
}
