class ReviewChallenge {
  const ReviewChallenge({
    required this.prompt,
    required this.answer,
    required this.choices,
    this.audioUrl,
    this.promptPinyin,
    this.promptMeaning,
    this.quizType,
  });

  final String prompt;
  final String answer;
  final List<String> choices;

  /// URL phát âm prompt (vocab/sentence). Null khi không có audio liên kết.
  final String? audioUrl;
  final String? promptPinyin;
  final String? promptMeaning;
  final String? quizType;
}
