import '../../../core/audio/audio_urls.dart';
import '../../../core/learning/quiz_generator.dart';
import 'review_challenge.dart';

extension LearningQuizReviewChallengeMapper on LearningQuiz {
  ReviewChallenge toReviewChallenge() {
    return ReviewChallenge(
      prompt: prompt,
      answer: answer,
      choices: choices,
      audioUrl: _resolveAudioUrl(),
    );
  }

  String? _resolveAudioUrl() {
    final id = targetId;
    if (id == null || id.isEmpty) return null;

    // Quiz dạng đoán Hán tự / pinyin → phát từ vựng (URL ngắn)
    // Quiz dạng cloze → cũng phát toàn câu vocab (đủ ngữ cảnh)
    switch (type) {
      case QuizType.vocabRecognition:
      case QuizType.vocabRecall:
      case QuizType.pinyinChoice:
      case QuizType.clozeCollocation:
      case QuizType.grammarChoice:
      case QuizType.sentenceOrder:
        return AudioUrls.forVocab(id);
    }
  }
}
