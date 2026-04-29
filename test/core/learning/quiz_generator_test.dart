import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/collocation.dart';
import 'package:hanzify/core/learning/quiz_generator.dart';

void main() {
  test('quiz generator creates valid HSK2 quizzes from collocations', () {
    const pool = [
      CollocationItem(
        id: 'c1',
        level: 2,
        source: 'vocab_example',
        textCn: '我学习中文。',
        pinyin: 'Wǒ xuéxí Zhōngwén.',
        textVi: 'Tôi học tiếng Trung.',
        targetVocabIds: ['hsk2_中文'],
        targetGrammarIds: [],
        conversationIds: [],
        tags: [],
        difficulty: 2.4,
      ),
      CollocationItem(
        id: 'c2',
        level: 2,
        source: 'vocab_example',
        textCn: '今天很热。',
        pinyin: 'Jīntiān hěn rè.',
        textVi: 'Hôm nay rất nóng.',
        targetVocabIds: ['hsk2_今天'],
        targetGrammarIds: [],
        conversationIds: [],
        tags: [],
        difficulty: 2.3,
      ),
      CollocationItem(
        id: 'c3',
        level: 1,
        source: 'vocab_example',
        textCn: '你好。',
        pinyin: 'Nǐ hǎo.',
        textVi: 'Xin chào.',
        targetVocabIds: ['hsk1_你好'],
        targetGrammarIds: [],
        conversationIds: [],
        tags: [],
        difficulty: 1.1,
      ),
    ];

    const generator = QuizGenerator();
    final quizzes = generator.generateForLevel(
      pool: pool,
      activeLevel: 2,
      limit: 4,
    );

    expect(quizzes, isNotEmpty);
    for (final quiz in quizzes) {
      expect(quiz.prompt, isNotEmpty);
      expect(quiz.answer, isNotEmpty);
      expect(quiz.choices, contains(quiz.answer));
      expect(quiz.choices.toSet().length, quiz.choices.length);
      if (quiz.type == QuizType.clozeCollocation) {
        expect(quiz.prompt, contains('____'));
      }
    }
  });
}
