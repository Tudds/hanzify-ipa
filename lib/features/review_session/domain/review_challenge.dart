class ReviewChallenge {
  const ReviewChallenge({
    required this.prompt,
    required this.answer,
    required this.choices,
    this.audioUrl,
  });

  final String prompt;
  final String answer;
  final List<String> choices;

  /// URL phát âm prompt (vocab/sentence). Null khi không có audio liên kết.
  final String? audioUrl;
}
