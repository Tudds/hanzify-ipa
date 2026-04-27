/// Convention-based URL builder cho TTS audio host trên Cloudflare R2.
///
/// Naming convention (audio/v1/):
///   vocab/{vocabId}.mp3              — pinyin reading của từ vựng
///   vocab/{vocabId}_E{idx}.mp3       — câu ví dụ (idx = 0, 1, ...)
///   grammar/{grammarId}_E{idx}.mp3   — ví dụ ngữ pháp
///   conv/{convId}_L{idx}.mp3         — dòng hội thoại
class AudioUrls {
  const AudioUrls._();

  /// Base URL — có thể override qua `--dart-define=AUDIO_BASE_URL=...`
  static const String _base = String.fromEnvironment(
    'AUDIO_BASE_URL',
    defaultValue: 'https://pub-7d5fb452d3c14b469b1d630f885dfa87.r2.dev/audio/v1',
  );

  static String forVocab(String vocabId) => '$_base/vocab/$vocabId.mp3';

  static String forVocabExample(String vocabId, int exampleIdx) =>
      '$_base/vocab/${vocabId}_E$exampleIdx.mp3';

  static String forGrammarExample(String grammarId, int exampleIdx) =>
      '$_base/grammar/${grammarId}_E$exampleIdx.mp3';

  static String forConversationLine(String convId, int lineIdx) =>
      '$_base/conv/${convId}_L$lineIdx.mp3';
}
