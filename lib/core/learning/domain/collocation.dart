class CollocationItem {
  const CollocationItem({
    required this.id,
    required this.level,
    required this.source,
    required this.textCn,
    required this.pinyin,
    required this.textVi,
    required this.targetVocabIds,
    required this.targetGrammarIds,
    required this.conversationIds,
    required this.tags,
    required this.difficulty,
    this.audioUrl,
  });

  factory CollocationItem.fromJson(Map<String, dynamic> json) {
    return CollocationItem(
      id: json['id'] as String,
      level: json['level'] as int,
      source: json['source'] as String,
      textCn: json['textCn'] as String,
      pinyin: json['pinyin'] as String? ?? '',
      textVi: json['textVi'] as String? ?? '',
      targetVocabIds: List<String>.from(
        json['targetVocabIds'] as List? ?? const [],
      ),
      targetGrammarIds: List<String>.from(
        json['targetGrammarIds'] as List? ?? const [],
      ),
      conversationIds: List<String>.from(
        json['conversationIds'] as List? ?? const [],
      ),
      tags: List<String>.from(json['tags'] as List? ?? const []),
      difficulty: (json['difficulty'] as num).toDouble(),
      audioUrl: json['audioUrl'] as String?,
    );
  }

  final String id;
  final int level;
  final String source;
  final String textCn;
  final String pinyin;
  final String textVi;
  final List<String> targetVocabIds;
  final List<String> targetGrammarIds;
  final List<String> conversationIds;
  final List<String> tags;
  final double difficulty;
  final String? audioUrl;

  CollocationItem copyWith({String? audioUrl}) {
    return CollocationItem(
      id: id,
      level: level,
      source: source,
      textCn: textCn,
      pinyin: pinyin,
      textVi: textVi,
      targetVocabIds: targetVocabIds,
      targetGrammarIds: targetGrammarIds,
      conversationIds: conversationIds,
      tags: tags,
      difficulty: difficulty,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}
