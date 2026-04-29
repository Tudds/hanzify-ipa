import '../../../core/learning/quiz_generator.dart';
import 'review_challenge.dart';

extension LearningQuizReviewChallengeMapper on LearningQuiz {
  ReviewChallenge toReviewChallenge() {
    return ReviewChallenge(
      prompt: prompt,
      answer: answer,
      choices: choices,
      audioUrl: audioUrl,
    );
  }
}
