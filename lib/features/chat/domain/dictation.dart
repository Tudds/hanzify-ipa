enum DictationMode {
  /// Nghe audio rồi gõ lại câu bằng chữ Hán.
  listen,

  /// Đọc câu tiếng Việt rồi dịch sang chữ Hán.
  readVi,
}

class DictationExercise {
  const DictationExercise({
    required this.id,
    required this.mode,
    required this.textCn,
    required this.pinyin,
    required this.textVi,
    required this.level,
    this.audioUrl,
  }) : assert(
         mode != DictationMode.listen || audioUrl != null,
         'Bài nghe bắt buộc phải có audioUrl.',
       );

  final String id;
  final DictationMode mode;
  final String textCn;
  final String pinyin;
  final String textVi;
  final int level;
  final String? audioUrl;
}
