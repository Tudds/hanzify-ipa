class VocabItem {
  const VocabItem({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    required this.pinyinNormalized,
    required this.characters,
    required this.meanings,
    required this.examples,
    required this.level,
    required this.wordType,
    required this.tags,
    required this.frequency,
  });

  factory VocabItem.fromJson(Map<String, dynamic> json) {
    return VocabItem(
      id: json['id'] as String,
      hanzi: json['hanzi'] as String,
      pinyin: json['pinyin'] as String? ?? '',
      pinyinNormalized: json['pinyinNormalized'] as String? ?? '',
      characters: (json['characters'] as List<dynamic>? ?? const [])
          .cast<String>(),
      meanings: (json['meanings'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(VocabMeaning.fromJson)
          .toList(growable: false),
      examples: (json['exampleSentences'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(VocabExample.fromJson)
          .toList(growable: false),
      level: json['level'] as int? ?? 1,
      wordType: json['wordType'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const []).cast<String>(),
      frequency: json['frequency'] as String? ?? '',
    );
  }

  final String id;
  final String hanzi;
  final String pinyin;
  final String pinyinNormalized;
  final List<String> characters;
  final List<VocabMeaning> meanings;
  final List<VocabExample> examples;
  final int level;
  final String wordType;
  final List<String> tags;
  final String frequency;

  String get viShort => meanings.isEmpty ? '' : meanings.first.vi;
}

class VocabMeaning {
  const VocabMeaning({required this.pos, required this.vi, required this.en});

  factory VocabMeaning.fromJson(Map<String, dynamic> json) {
    return VocabMeaning(
      pos: json['pos'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );
  }

  final String pos;
  final String vi;
  final String en;
}

class VocabExample {
  const VocabExample({
    required this.cn,
    required this.pinyin,
    required this.vi,
  });

  factory VocabExample.fromJson(Map<String, dynamic> json) {
    return VocabExample(
      cn: json['cn'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
    );
  }

  final String cn;
  final String pinyin;
  final String vi;
}
