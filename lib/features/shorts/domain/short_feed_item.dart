enum ShortCardType {
  vocabContext,
  grammarContext,
  quickQuiz,
  dialogue,
  listening,
  miniTest,
  summary,
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
  });

  factory ShortDialogueLine.fromJson(Map<String, dynamic> json) {
    return ShortDialogueLine(
      speaker: json['speaker'] as String,
      hanzi: json['hanzi'] as String,
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  final String speaker;
  final String hanzi;
  final String pinyin;
  final String vi;
  final String? audioUrl;
}

class ShortDialogue {
  const ShortDialogue({
    required this.title,
    required this.context,
    required this.lines,
  });

  factory ShortDialogue.fromJson(Map<String, dynamic> json) {
    return ShortDialogue(
      title: json['title'] as String,
      context: json['context'] as String? ?? '',
      lines: (json['lines'] as List)
          .cast<Map<String, dynamic>>()
          .map(ShortDialogueLine.fromJson)
          .toList(growable: false),
    );
  }

  final String title;
  final String context;
  final List<ShortDialogueLine> lines;
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
