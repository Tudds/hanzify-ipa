import 'package:equatable/equatable.dart';

class GrammarExample extends Equatable {
  final String zh;
  final String pinyin;
  final String vi;

  const GrammarExample({
    required this.zh,
    required this.pinyin,
    required this.vi,
  });

  GrammarExample copyWith({
    String? zh,
    String? pinyin,
    String? vi,
  }) {
    return GrammarExample(
      zh: zh ?? this.zh,
      pinyin: pinyin ?? this.pinyin,
      vi: vi ?? this.vi,
    );
  }

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      zh: json['zh'] ?? '',
      pinyin: json['pinyin'] ?? '',
      vi: json['vi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'zh': zh, 'pinyin': pinyin, 'vi': vi};

  @override
  List<Object?> get props => [zh, pinyin, vi];
}

class GrammarPoint extends Equatable {
  final String id;
  final String title;
  final String structure;
  final String explanation;
  final int level;
  final String category;
  final List<GrammarExample> examples;
  final List<String> relatedGrammar;
  final bool isBookmarked;
  final bool isMastered;

  const GrammarPoint({
    required this.id,
    required this.title,
    required this.structure,
    required this.explanation,
    required this.level,
    required this.category,
    required this.examples,
    this.relatedGrammar = const [],
    this.isBookmarked = false,
    this.isMastered = false,
  });

  GrammarPoint copyWith({bool? isBookmarked, bool? isMastered}) {
    return GrammarPoint(
      id: id,
      title: title,
      structure: structure,
      explanation: explanation,
      level: level,
      category: category,
      examples: examples,
      relatedGrammar: relatedGrammar,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isMastered: isMastered ?? this.isMastered,
    );
  }

  factory GrammarPoint.fromJson(String id, Map<String, dynamic> json) {
    return GrammarPoint(
      id: id,
      title: json['title'] ?? '',
      structure: json['structure'] ?? '',
      explanation: json['explanation'] ?? '',
      level: json['level'] ?? 1,
      category: json['category'] ?? 'basic',
      examples:
          (json['examples'] as List?)
              ?.map((e) => GrammarExample.fromJson(e))
              .toList() ??
          [],
      relatedGrammar: List<String>.from(json['relatedGrammar'] ?? []),
      isBookmarked: json['isBookmarked'] == true,
      isMastered: json['isMastered'] == true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    structure,
    explanation,
    level,
    category,
    examples,
    relatedGrammar,
    isBookmarked,
    isMastered,
  ];
}
