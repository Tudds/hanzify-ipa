enum ShortCardType {
  vocabContext,
  grammarContext,
  quickQuiz,
  dialogue,
  listening,
  miniTest,
  summary,
  scene,
  reader,
}

class ShortFeedItem {
  const ShortFeedItem({
    required this.id,
    required this.type,
    required this.level,
    required this.tags,
    required this.payload,
  });

  factory ShortFeedItem.fromJson(Map<String, dynamic> json) {
    final type = ShortCardType.values.byName(json['type'] as String);
    final payloadJson = (json['payload'] as Map).cast<String, dynamic>();
    return ShortFeedItem(
      id: json['id'] as String,
      type: type,
      level: json['level'] as int? ?? 1,
      tags: List<String>.from(json['tags'] as List? ?? const []),
      payload: switch (type) {
        ShortCardType.vocabContext => ShortVocabContext.fromJson(payloadJson),
        ShortCardType.grammarContext => ShortGrammarContext.fromJson(
          payloadJson,
        ),
        ShortCardType.quickQuiz ||
        ShortCardType.listening => ShortQuickQuiz.fromJson(payloadJson),
        ShortCardType.dialogue => ShortDialogue.fromJson(payloadJson),
        ShortCardType.miniTest => ShortMiniTest.fromJson(payloadJson),
        ShortCardType.summary => ShortSummary.fromJson(payloadJson),
        ShortCardType.scene => ShortScene.fromJson(payloadJson),
        ShortCardType.reader => ShortReader.fromJson(payloadJson),
      },
    );
  }

  final String id;
  final ShortCardType type;
  final int level;
  final List<String> tags;
  final Object payload;
}

class ShortVocabContext {
  const ShortVocabContext({
    required this.situation,
    required this.hanzi,
    required this.pinyin,
    required this.vi,
    required this.targetVocabId,
    this.audioUrl,
  });

  factory ShortVocabContext.fromJson(Map<String, dynamic> json) {
    return ShortVocabContext(
      situation: json['situation'] as String,
      hanzi: json['hanzi'] as String,
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String,
      targetVocabId: json['targetVocabId'] as String,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  final String situation;
  final String hanzi;
  final String pinyin;
  final String vi;
  final String targetVocabId;
  final String? audioUrl;
}

class ShortGrammarFormulaPart {
  const ShortGrammarFormulaPart({
    required this.text,
    required this.isHighlighted,
  });

  factory ShortGrammarFormulaPart.fromJson(Map<String, dynamic> json) {
    return ShortGrammarFormulaPart(
      text: json['text'] as String? ?? '',
      isHighlighted: json['isHighlighted'] as bool? ?? false,
    );
  }

  final String text;
  final bool isHighlighted;
}

class ShortGrammarExample {
  const ShortGrammarExample({
    required this.hanzi,
    required this.pinyin,
    required this.vi,
  });

  factory ShortGrammarExample.fromJson(Map<String, dynamic> json) {
    return ShortGrammarExample(
      hanzi: json['hanzi'] as String? ?? json['zh'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
    );
  }

  final String hanzi;
  final String pinyin;
  final String vi;
}

class ShortGrammarContext {
  const ShortGrammarContext({
    required this.title,
    required this.structure,
    required this.explanation,
    required this.targetGrammarId,
    required this.formulaParts,
    required this.examples,
  });

  factory ShortGrammarContext.fromJson(Map<String, dynamic> json) {
    return ShortGrammarContext(
      title: json['title'] as String,
      structure: json['structure'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      targetGrammarId: json['targetGrammarId'] as String,
      formulaParts: (json['formulaParts'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ShortGrammarFormulaPart.fromJson)
          .toList(growable: false),
      examples: (json['examples'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ShortGrammarExample.fromJson)
          .toList(growable: false),
    );
  }

  final String title;
  final String structure;
  final String explanation;
  final String targetGrammarId;
  final List<ShortGrammarFormulaPart> formulaParts;
  final List<ShortGrammarExample> examples;
}

class ShortQuickQuiz {
  const ShortQuickQuiz({
    required this.prompt,
    required this.choices,
    required this.answer,
    required this.explanation,
    this.audioUrl,
    this.targetVocabId,
    this.targetGrammarIds = const [],
    this.sourceCollocationId,
    this.quizType,
    this.promptPinyin,
    this.promptMeaning,
  });

  factory ShortQuickQuiz.fromJson(Map<String, dynamic> json) {
    return ShortQuickQuiz(
      prompt: json['prompt'] as String,
      choices: List<String>.from(json['choices'] as List),
      answer: json['answer'] as String,
      explanation: json['explanation'] as String? ?? '',
      audioUrl: json['audioUrl'] as String?,
      targetVocabId: json['targetVocabId'] as String?,
      targetGrammarIds: List<String>.from(
        json['targetGrammarIds'] as List? ?? const [],
      ),
      sourceCollocationId: json['sourceCollocationId'] as String?,
      quizType: json['quizType'] as String?,
      promptPinyin: json['promptPinyin'] as String?,
      promptMeaning: json['promptMeaning'] as String?,
    );
  }

  final String prompt;
  final List<String> choices;
  final String answer;
  final String explanation;
  final String? audioUrl;
  final String? targetVocabId;
  final List<String> targetGrammarIds;
  final String? sourceCollocationId;
  final String? quizType;
  final String? promptPinyin;
  final String? promptMeaning;
}

class ShortDialogueLine {
  const ShortDialogueLine({
    required this.speaker,
    required this.hanzi,
    required this.pinyin,
    required this.vi,
    this.audioUrl,
    this.startMs,
    this.endMs,
  });

  factory ShortDialogueLine.fromJson(Map<String, dynamic> json) {
    return ShortDialogueLine(
      speaker: json['speaker'] as String,
      hanzi: json['hanzi'] as String,
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String,
      audioUrl: json['audioUrl'] as String?,
      startMs: (json['startMs'] as num?)?.toInt(),
      endMs: (json['endMs'] as num?)?.toInt(),
    );
  }

  final String speaker;
  final String hanzi;
  final String pinyin;
  final String vi;
  final String? audioUrl;

  /// Mốc bắt đầu/kết thúc dòng này trong track audio liền mạch (ms).
  /// Có giá trị → bật phụ đề chạy theo audio (sub sync).
  final int? startMs;
  final int? endMs;
}

class ShortDialogue {
  const ShortDialogue({
    required this.title,
    required this.context,
    required this.lines,
    this.audioUrl,
  });

  factory ShortDialogue.fromJson(Map<String, dynamic> json) {
    return ShortDialogue(
      title: json['title'] as String,
      context: json['context'] as String? ?? '',
      lines: (json['lines'] as List)
          .cast<Map<String, dynamic>>()
          .map(ShortDialogueLine.fromJson)
          .toList(growable: false),
      audioUrl: json['audioUrl'] as String?,
    );
  }

  final String title;
  final String context;
  final List<ShortDialogueLine> lines;

  /// Track audio liền mạch cho cả đoạn hội thoại (tùy chọn). Khi có cùng với
  /// [ShortDialogueLine.startMs]/[ShortDialogueLine.endMs] → phụ đề tự highlight
  /// theo vị trí phát.
  final String? audioUrl;

  /// Có đủ dữ liệu để chạy phụ đề đồng bộ theo audio hay không.
  bool get hasSyncedSubtitles =>
      audioUrl != null &&
      audioUrl!.isNotEmpty &&
      lines.any((line) => line.startMs != null && line.endMs != null);
}

/// Một dòng văn bản song ngữ (Hán/pinyin/Việt) tùy chọn kèm mốc thời gian audio,
/// dùng cho card đọc (truyện/thơ/bài) và caption của scene.
class ReaderLine {
  const ReaderLine({
    required this.zh,
    required this.pinyin,
    required this.vi,
    this.startMs,
    this.endMs,
  });

  factory ReaderLine.fromJson(Map<String, dynamic> json) {
    return ReaderLine(
      zh: json['zh'] as String? ?? json['hanzi'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
      startMs: (json['startMs'] as num?)?.toInt(),
      endMs: (json['endMs'] as num?)?.toInt(),
    );
  }

  final String zh;
  final String pinyin;
  final String vi;
  final int? startMs;
  final int? endMs;
}

/// Mục từ vựng chú giải (glossary) hoặc nhãn vật thể trong scene.
class ShortGlossaryEntry {
  const ShortGlossaryEntry({
    required this.hanzi,
    required this.pinyin,
    required this.vi,
    this.targetVocabId,
    this.x,
    this.y,
  });

  factory ShortGlossaryEntry.fromJson(Map<String, dynamic> json) {
    return ShortGlossaryEntry(
      hanzi: json['hanzi'] as String? ?? json['zh'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
      targetVocabId: json['targetVocabId'] as String?,
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
    );
  }

  final String hanzi;
  final String pinyin;
  final String vi;

  /// ID từ vựng để mở detail sheet khi tap (nếu khớp thư viện).
  final String? targetVocabId;

  /// Tọa độ tỉ lệ [0,1] của nhãn trên ảnh scene (tùy chọn, cho hotspot).
  final double? x;
  final double? y;
}

/// Card hình ảnh: một vật/khung cảnh kèm câu mô tả tiếng Hán và nhãn từ vựng.
class ShortScene {
  const ShortScene({
    required this.imageUrl,
    required this.captionHanzi,
    required this.captionPinyin,
    required this.captionVi,
    this.labels = const [],
    this.audioUrl,
  });

  factory ShortScene.fromJson(Map<String, dynamic> json) {
    final caption = json['caption'];
    final captionMap = caption is Map
        ? caption.cast<String, dynamic>()
        : const <String, dynamic>{};
    return ShortScene(
      imageUrl: json['imageUrl'] as String? ?? '',
      captionHanzi:
          captionMap['hanzi'] as String? ??
          captionMap['zh'] as String? ??
          json['captionHanzi'] as String? ??
          '',
      captionPinyin:
          captionMap['pinyin'] as String? ??
          json['captionPinyin'] as String? ??
          '',
      captionVi:
          captionMap['vi'] as String? ?? json['captionVi'] as String? ?? '',
      labels: (json['labels'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ShortGlossaryEntry.fromJson)
          .toList(growable: false),
      audioUrl: json['audioUrl'] as String?,
    );
  }

  final String imageUrl;
  final String captionHanzi;
  final String captionPinyin;
  final String captionVi;
  final List<ShortGlossaryEntry> labels;
  final String? audioUrl;
}

/// Card đọc: truyện ngắn / bài viết / bài thơ song ngữ (tùy chọn kèm audio + sub).
class ShortReader {
  const ShortReader({
    required this.kind,
    required this.title,
    required this.paragraphs,
    this.titleZh = '',
    this.glossary = const [],
    this.audioUrl,
    this.sourceName,
    this.sourceUrl,
  });

  factory ShortReader.fromJson(Map<String, dynamic> json) {
    return ShortReader(
      kind: ShortReaderKind.fromName(json['kind'] as String?),
      title: json['title'] as String? ?? '',
      titleZh: json['titleZh'] as String? ?? '',
      paragraphs: (json['paragraphs'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ReaderLine.fromJson)
          .toList(growable: false),
      glossary: (json['glossary'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ShortGlossaryEntry.fromJson)
          .toList(growable: false),
      audioUrl: json['audioUrl'] as String?,
      sourceName: json['sourceName'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
    );
  }

  final ShortReaderKind kind;
  final String title;
  final String titleZh;
  final List<ReaderLine> paragraphs;
  final List<ShortGlossaryEntry> glossary;
  final String? audioUrl;
  final String? sourceName;
  final String? sourceUrl;

  bool get hasSyncedSubtitles =>
      audioUrl != null &&
      audioUrl!.isNotEmpty &&
      paragraphs.any((line) => line.startMs != null && line.endMs != null);
}

enum ShortReaderKind {
  story,
  article,
  poem;

  static ShortReaderKind fromName(String? name) {
    return ShortReaderKind.values.firstWhere(
      (kind) => kind.name == name,
      orElse: () => ShortReaderKind.story,
    );
  }
}

class ShortMiniTest {
  const ShortMiniTest({required this.title, required this.quizzes});

  factory ShortMiniTest.fromJson(Map<String, dynamic> json) {
    return ShortMiniTest(
      title: json['title'] as String,
      quizzes: (json['quizzes'] as List)
          .cast<Map<String, dynamic>>()
          .map(ShortQuickQuiz.fromJson)
          .toList(growable: false),
    );
  }

  final String title;
  final List<ShortQuickQuiz> quizzes;
}

class ShortSummary {
  const ShortSummary({required this.title, required this.message});

  factory ShortSummary.fromJson(Map<String, dynamic> json) {
    return ShortSummary(
      title: json['title'] as String,
      message: json['message'] as String,
    );
  }

  final String title;
  final String message;
}
