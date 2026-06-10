class GrammarItem {
  const GrammarItem({
    required this.id,
    required this.title,
    required this.structure,
    required this.explanation,
    required this.level,
    required this.category,
    required this.formulaParts,
    required this.usages,
    required this.examples,
    required this.commonMistakes,
    required this.relatedGrammar,
  });

  factory GrammarItem.fromJson(Map<String, dynamic> json) {
    return GrammarItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      structure: json['structure'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      level: json['level'] as int? ?? 1,
      category: json['category'] as String? ?? 'basic',
      formulaParts: (json['formulaParts'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(GrammarFormulaPart.fromJson)
          .toList(growable: false),
      usages: (json['usages'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(GrammarUsage.fromJson)
          .toList(growable: false),
      examples: (json['examples'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(GrammarExample.fromJson)
          .toList(growable: false),
      commonMistakes: (json['commonMistakes'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(GrammarMistake.fromJson)
          .toList(growable: false),
      relatedGrammar: (json['relatedGrammar'] as List<dynamic>? ?? const [])
          .cast<String>(),
    );
  }

  final String id;
  final String title;
  final String structure;
  final String explanation;
  final int level;
  final String category;
  final List<GrammarFormulaPart> formulaParts;
  final List<GrammarUsage> usages;
  final List<GrammarExample> examples;
  final List<GrammarMistake> commonMistakes;
  final List<String> relatedGrammar;
}

class GrammarFormulaPart {
  const GrammarFormulaPart({required this.text, required this.isHighlighted});

  factory GrammarFormulaPart.fromJson(Map<String, dynamic> json) {
    return GrammarFormulaPart(
      text: json['text'] as String? ?? '',
      isHighlighted: json['isHighlighted'] as bool? ?? false,
    );
  }

  final String text;
  final bool isHighlighted;
}

class GrammarUsage {
  const GrammarUsage({
    required this.icon,
    required this.title,
    required this.description,
  });

  factory GrammarUsage.fromJson(Map<String, dynamic> json) {
    return GrammarUsage(
      icon: json['icon'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  final String icon;
  final String title;
  final String description;
}

class GrammarExample {
  const GrammarExample({
    required this.zh,
    required this.pinyin,
    required this.vi,
  });

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      zh: json['zh'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
    );
  }

  final String zh;
  final String pinyin;
  final String vi;
}

class GrammarMistake {
  const GrammarMistake({
    required this.wrong,
    required this.right,
    required this.note,
  });

  factory GrammarMistake.fromJson(Map<String, dynamic> json) {
    return GrammarMistake(
      wrong: json['wrong'] as String? ?? '',
      right: json['right'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );
  }

  final String wrong;
  final String right;
  final String note;
}
