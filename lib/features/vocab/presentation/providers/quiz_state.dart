import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hanzify/core/theme/app_durations.dart';
import 'package:hanzify/core/utils/vocab_meaning_helper.dart';

part 'quiz_state.g.dart';

enum QuizMode { hanziToMeaning, meaningToHanzi }

class QuizQuestion extends Equatable {
  final Vocab vocab;
  final List<String> options;
  final int correctIndex;
  final QuizMode mode;

  const QuizQuestion({
    required this.vocab,
    required this.options,
    required this.correctIndex,
    required this.mode,
  });

  @override
  List<Object?> get props => [vocab.id, options, correctIndex, mode];
}

class QuizState extends Equatable {
  final QuizMode? mode;
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedAnswer;
  final int score;
  final int streak;
  final bool isFinished;
  final bool? answerFeedback;
  final bool showPinyin;

  const QuizState({
    this.mode,
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.score = 0,
    this.streak = 0,
    this.isFinished = false,
    this.answerFeedback,
    this.showPinyin = true,
  });

  QuizState copyWith({
    QuizMode? mode,
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? selectedAnswer,
    int? score,
    int? streak,
    bool? isFinished,
    bool? answerFeedback,
    bool? showPinyin,
    bool clearSelectedAnswer = false,
  }) {
    return QuizState(
      mode: mode ?? this.mode,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: clearSelectedAnswer ? null : (selectedAnswer ?? this.selectedAnswer),
      score: score ?? this.score,
      streak: streak ?? this.streak,
      isFinished: isFinished ?? this.isFinished,
      answerFeedback: clearSelectedAnswer ? null : (answerFeedback ?? this.answerFeedback),
      showPinyin: showPinyin ?? this.showPinyin,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    questions,
    currentIndex,
    selectedAnswer,
    score,
    streak,
    isFinished,
    answerFeedback,
    showPinyin,
  ];
}

@riverpod
class QuizNotifier extends _$QuizNotifier {
  /// Timer để auto-advance sau khi chọn đáp án.
  /// Được cancel khi reset/dispose để tránh memory leak.
  Timer? _advanceTimer;

  @override
  QuizState build() => const QuizState();

  static const _totalQuestions = 10;

  void startQuiz(QuizMode mode) {
    _cancelAdvanceTimer();

    final vocabState = ref.read(allVocabProvider);
    if (vocabState is! AsyncData<List<Vocab>>) return;

    final allVocab = vocabState.value;
    if (allVocab.length < 4) return;

    final questions = _generateQuestions(allVocab, mode);
    state = QuizState(mode: mode, questions: questions);
  }

  void selectAnswer(int index) {
    if (state.selectedAnswer != null || state.isFinished) return;

    final isCorrect = index == state.questions[state.currentIndex].correctIndex;

    state = state.copyWith(
      selectedAnswer: index,
      answerFeedback: isCorrect,
      score: isCorrect ? state.score + 1 : state.score,
      streak: isCorrect ? state.streak + 1 : 0,
    );

    // Auto advance — dùng Timer thay Future.delayed để cancel được
    _cancelAdvanceTimer();
    _advanceTimer = Timer(AppDurations.quizFeedback, () {
      if (ref.mounted && state.mode != null && !state.isFinished) {
        nextQuestion();
      }
    });
  }

  void nextQuestion() {
    _cancelAdvanceTimer();

    if (state.currentIndex + 1 >= state.questions.length) {
      state = state.copyWith(isFinished: true, clearSelectedAnswer: true);
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      clearSelectedAnswer: true,
    );
  }

  void togglePinyin() {
    state = state.copyWith(showPinyin: !state.showPinyin);
  }

  void reset() {
    _cancelAdvanceTimer();
    state = const QuizState();
  }

  /// Hủy timer auto-advance nếu đang đợi.
  void _cancelAdvanceTimer() {
    _advanceTimer?.cancel();
    _advanceTimer = null;
  }

  List<QuizQuestion> _generateQuestions(List<Vocab> allVocab, QuizMode mode) {
    final random = Random();
    final shuffledVocab = List<Vocab>.from(allVocab)..shuffle(random);
    final selectedVocab = shuffledVocab.take(_totalQuestions).toList();

    return selectedVocab.map((vocab) {
      final String correctOption = mode == QuizMode.hanziToMeaning
          ? vocab.primaryMeaningVi
          : vocab.hanzi;

      // Lấy danh sách các từ khác để làm đáp án nhiễu
      final distractors = allVocab
          .where((v) => v.id != vocab.id)
          .map((v) =>
              mode == QuizMode.hanziToMeaning ? v.primaryMeaningVi : v.hanzi)
          .cast<String>()
          .toSet() // Loại bỏ trùng lặp giữa các distractors
          .where((d) => d != correctOption) // Loại bỏ trùng với đáp án đúng
          .toList()
        ..shuffle(random);

      // Lấy 3 distractors, thêm correctOption, rồi shuffle
      final List<String> options = distractors.take(3).toList();
      options.add(correctOption);
      options.shuffle(random);

      // Đảm bảo indexOf luôn tìm đúng vị trí (không bị trùng)
      return QuizQuestion(
        vocab: vocab,
        options: options,
        correctIndex: options.lastIndexOf(correctOption),
        mode: mode,
      );
    }).toList();
  }
}
