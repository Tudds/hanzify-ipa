import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/learning/learning_asset_repository.dart';
import '../../../core/learning/lesson_context.dart';
import '../../../core/learning/quiz_generator.dart';
import '../../../core/learning/study_session_controller.dart';
import '../../../core/learning/study_session_store.dart';

final gameSessionControllerProvider = AsyncNotifierProvider.family
    .autoDispose<GameSessionController, GameSessionState, GameSessionArgs>(
      GameSessionController.new,
    );

@immutable
class GameSessionArgs {
  const GameSessionArgs({
    this.sessionFactory = const HskLearningSessionFactory(),
    this.studySessionStore = const StudySessionStore(),
    this.lessonContext,
  });

  final HskLearningSessionFactory sessionFactory;
  final StudySessionStore studySessionStore;
  final LessonContext? lessonContext;
}

@immutable
class GameSessionState {
  const GameSessionState({
    required this.session,
    required this.snapshot,
    required this.activeQuizIndexes,
    required this.failedQuizIndexes,
    required this.index,
    required this.answeredCount,
    required this.correctCount,
    required this.sessionCompleted,
    this.lastResult,
  });

  final HskLearningSessionSeed session;
  final StudySessionSnapshot snapshot;
  final List<int> activeQuizIndexes;
  final List<int> failedQuizIndexes;
  final int index;
  final int answeredCount;
  final int correctCount;
  final bool sessionCompleted;
  final StudyAnswerResult? lastResult;

  LearningQuiz get currentQuiz => session.quizzes[activeQuizIndexes[index]];

  int get score {
    if (activeQuizIndexes.isEmpty) return 0;
    return (correctCount / activeQuizIndexes.length * 100).round();
  }

  List<LearningQuiz> get failedQuizzes {
    return [
      for (final failedIndex in failedQuizIndexes) session.quizzes[failedIndex],
    ];
  }

  List<RemediationGroup> get remediationGroups {
    final collocationsById = {
      for (final item in session.collocations) item.id: item,
    };
    final groups = <String, RemediationGroup>{};
    for (final failedIndex in failedQuizIndexes) {
      final quiz = session.quizzes[failedIndex];
      final collocation = collocationsById[quiz.sourceCollocationId];
      final vocabId = quiz.targetId;
      if (vocabId != null && vocabId.isNotEmpty) {
        _addRemediation(
          groups,
          'vocab:$vocabId',
          'Từ vựng',
          _targetLabel(vocabId),
          quiz,
          failedIndex,
        );
      }
      final grammarIds = quiz.targetGrammarIds.isNotEmpty
          ? quiz.targetGrammarIds
          : collocation?.targetGrammarIds ?? const <String>[];
      for (final grammarId in grammarIds) {
        if (grammarId.isNotEmpty) {
          _addRemediation(
            groups,
            'grammar:$grammarId',
            'Ngữ pháp',
            grammarId,
            quiz,
            failedIndex,
          );
        }
      }
      if ((vocabId == null || vocabId.isEmpty) && grammarIds.isEmpty) {
        _addRemediation(
          groups,
          'collocation:${quiz.sourceCollocationId}',
          'Câu mẫu',
          quiz.sourceCollocationId,
          quiz,
          failedIndex,
        );
      }
    }
    return groups.values.toList(growable: false);
  }

  GameSessionState copyWith({
    StudySessionSnapshot? snapshot,
    List<int>? activeQuizIndexes,
    List<int>? failedQuizIndexes,
    int? index,
    int? answeredCount,
    int? correctCount,
    bool? sessionCompleted,
    StudyAnswerResult? lastResult,
    bool clearLastResult = false,
  }) {
    return GameSessionState(
      session: session,
      snapshot: snapshot ?? this.snapshot,
      activeQuizIndexes: activeQuizIndexes ?? this.activeQuizIndexes,
      failedQuizIndexes: failedQuizIndexes ?? this.failedQuizIndexes,
      index: index ?? this.index,
      answeredCount: answeredCount ?? this.answeredCount,
      correctCount: correctCount ?? this.correctCount,
      sessionCompleted: sessionCompleted ?? this.sessionCompleted,
      lastResult: clearLastResult ? null : lastResult ?? this.lastResult,
    );
  }
}

@immutable
class RemediationGroup {
  const RemediationGroup({
    required this.key,
    required this.kind,
    required this.label,
    required this.quizzes,
    required this.quizIndexes,
  });

  final String key;
  final String kind;
  final String label;
  final List<LearningQuiz> quizzes;
  final List<int> quizIndexes;
}

void _addRemediation(
  Map<String, RemediationGroup> groups,
  String key,
  String kind,
  String label,
  LearningQuiz quiz,
  int quizIndex,
) {
  final current = groups[key];
  groups[key] = RemediationGroup(
    key: key,
    kind: kind,
    label: label,
    quizzes: [...?current?.quizzes, quiz],
    quizIndexes: [...?current?.quizIndexes, quizIndex],
  );
}

String _targetLabel(String id) {
  final separator = id.indexOf('_');
  if (separator == -1 || separator == id.length - 1) return id;
  return id.substring(separator + 1);
}

class GameSessionController extends AsyncNotifier<GameSessionState> {
  GameSessionController(this._args);

  final GameSessionArgs _args;
  late final StudySessionController _studyController;

  @override
  Future<GameSessionState> build() async {
    _studyController = StudySessionController();
    final saved = await _args.studySessionStore.load();
    _studyController.hydrate(saved);
    final session = await _args.sessionFactory.createHsk2Session(
      lessonContext: _args.lessonContext,
    );
    final activeQuizIndexes = [
      for (var index = 0; index < session.quizzes.length; index++) index,
    ];

    return GameSessionState(
      session: session,
      snapshot: _studyController.snapshot(),
      activeQuizIndexes: activeQuizIndexes,
      failedQuizIndexes: const [],
      index: 0,
      answeredCount: 0,
      correctCount: 0,
      sessionCompleted: false,
    );
  }

  Future<StudyAnswerResult> answer(String selectedChoice) async {
    final current = state.requireValue;
    final quiz = current.currentQuiz;
    final result = _studyController.answer(quiz, selectedChoice);
    unawaited(_args.studySessionStore.save(_studyController.snapshot()));

    final failedQuizIndexes = [...current.failedQuizIndexes];
    if (!result.isCorrect) {
      failedQuizIndexes.add(current.activeQuizIndexes[current.index]);
    }

    final answeredCount = current.answeredCount + 1;
    final correctCount = current.correctCount + (result.isCorrect ? 1 : 0);
    final completed = answeredCount >= current.activeQuizIndexes.length;

    state = AsyncData(
      current.copyWith(
        snapshot: _studyController.snapshot(),
        failedQuizIndexes: failedQuizIndexes,
        index: completed
            ? current.index
            : (current.index + 1) % current.activeQuizIndexes.length,
        answeredCount: answeredCount,
        correctCount: correctCount,
        sessionCompleted: completed || current.sessionCompleted,
        lastResult: result,
      ),
    );
    return result;
  }

  void retryFailed() {
    final current = state.requireValue;
    retryQuizIndexes(current.failedQuizIndexes);
  }

  void retryQuizIndexes(List<int> quizIndexes) {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(
        activeQuizIndexes: List<int>.from(quizIndexes),
        failedQuizIndexes: const [],
        index: 0,
        answeredCount: 0,
        correctCount: 0,
        sessionCompleted: false,
        clearLastResult: true,
      ),
    );
  }
}
