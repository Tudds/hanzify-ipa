import '../domain/collocation.dart';

enum QuizType {
  vocabRecognition,
  vocabRecall,
  pinyinChoice,
  grammarChoice,
  sentenceOrder,
  clozeCollocation,
}

class LearningQuiz {
  const LearningQuiz({
    required this.id,
    required this.type,
    required this.prompt,
    required this.answer,
    required this.choices,
    required this.sourceCollocationId,
    this.targetGrammarIds = const [],
    this.targetId,
  });

  final String id;
  final QuizType type;
  final String prompt;
  final String answer;
  final List<String> choices;
  final String sourceCollocationId;
  final List<String> targetGrammarIds;
  final String? targetId;
}

class QuizGenerator {
  const QuizGenerator();

  List<LearningQuiz> generateForLevel({
    required List<CollocationItem> pool,
    required int activeLevel,
    int limit = 20,
  }) {
    final scoped =
        pool
            .where(
              (item) =>
                  item.level == activeLevel &&
                  item.textCn.isNotEmpty &&
                  item.textVi.isNotEmpty,
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    final quizzes = <LearningQuiz>[];

    for (final item in scoped) {
      if (quizzes.length >= limit) break;
      final recognition = _vocabRecognition(item, scoped);
      if (recognition != null) quizzes.add(recognition);
      if (quizzes.length >= limit) break;

      final cloze = _clozeCollocation(item, scoped);
      if (cloze != null) quizzes.add(cloze);
      if (quizzes.length >= limit) break;

      final pinyin = _pinyinChoice(item, scoped);
      if (pinyin != null) quizzes.add(pinyin);
    }

    return quizzes.take(limit).toList();
  }

  LearningQuiz? _vocabRecognition(
    CollocationItem item,
    List<CollocationItem> scoped,
  ) {
    final choices = _choices(item.textVi, scoped.map((e) => e.textVi));
    if (choices.length < 2) return null;
    return LearningQuiz(
      id: '${item.id}_vocab_recognition',
      type: QuizType.vocabRecognition,
      prompt: item.textCn,
      answer: item.textVi,
      choices: choices,
      sourceCollocationId: item.id,
      targetGrammarIds: item.targetGrammarIds,
      targetId: item.targetVocabIds.isEmpty ? null : item.targetVocabIds.first,
    );
  }

  LearningQuiz? _pinyinChoice(
    CollocationItem item,
    List<CollocationItem> scoped,
  ) {
    if (item.pinyin.isEmpty) return null;
    final choices = _choices(
      item.pinyin,
      scoped.map((e) => e.pinyin).where((e) => e.isNotEmpty),
    );
    if (choices.length < 2) return null;
    return LearningQuiz(
      id: '${item.id}_pinyin_choice',
      type: QuizType.pinyinChoice,
      prompt: item.textCn,
      answer: item.pinyin,
      choices: choices,
      sourceCollocationId: item.id,
      targetGrammarIds: item.targetGrammarIds,
      targetId: item.targetVocabIds.isEmpty ? null : item.targetVocabIds.first,
    );
  }

  LearningQuiz? _clozeCollocation(
    CollocationItem item,
    List<CollocationItem> scoped,
  ) {
    final target = _targetText(item);
    if (target == null || !item.textCn.contains(target)) return null;
    final prompt = item.textCn.replaceFirst(target, '____');
    final distractors = scoped
        .map(_targetText)
        .whereType<String>()
        .where((value) => value != target && value.length <= 6);
    final choices = _choices(target, distractors);
    if (choices.length < 2) return null;
    return LearningQuiz(
      id: '${item.id}_cloze_collocation',
      type: QuizType.clozeCollocation,
      prompt: prompt,
      answer: target,
      choices: choices,
      sourceCollocationId: item.id,
      targetGrammarIds: item.targetGrammarIds,
      targetId: item.targetVocabIds.isEmpty ? null : item.targetVocabIds.first,
    );
  }

  String? _targetText(CollocationItem item) {
    final vocabId = item.targetVocabIds.isEmpty
        ? null
        : item.targetVocabIds.first;
    if (vocabId == null) return null;
    final separator = vocabId.indexOf('_');
    if (separator == -1 || separator == vocabId.length - 1) return null;
    return vocabId.substring(separator + 1);
  }

  List<String> _choices(String answer, Iterable<String> candidates) {
    final values = <String>[answer];
    for (final candidate in candidates) {
      if (candidate.isEmpty ||
          candidate == answer ||
          values.contains(candidate)) {
        continue;
      }
      values.add(candidate);
      if (values.length == 4) break;
    }
    values.sort();
    return values;
  }
}
