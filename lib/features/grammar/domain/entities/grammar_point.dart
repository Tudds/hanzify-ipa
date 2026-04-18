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

/// Mô tả một cách dùng cụ thể của cấu trúc ngữ pháp.
class GrammarUsage extends Equatable {
  final String icon;  // emoji hoặc icon name
  final String title;
  final String description;

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

  Map<String, dynamic> toJson() => {
        'icon': icon,
        'title': title,
        'description': description,
      };

  @override
  List<Object?> get props => [icon, title, description];
}

/// Một phần tử trong công thức ngữ pháp (e.g. "S", "+", "是", "[Thông tin nhấn mạnh]")
class FormulaPart extends Equatable {
  final String text;
  final bool isHighlighted; // true = keyword Hanzi (có nền màu), false = label thường

  const FormulaPart({required this.text, this.isHighlighted = false});

  factory FormulaPart.fromJson(Map<String, dynamic> json) {
    return FormulaPart(
      text: json['text'] as String? ?? '',
      isHighlighted: json['isHighlighted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'isHighlighted': isHighlighted,
      };

  @override
  List<Object?> get props => [text, isHighlighted];
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

  /// Công thức phân tích (hiển thị dạng S + 是 + V + 的)
  final List<FormulaPart> formulaParts;

  /// Các cách dùng cụ thể (thời gian, địa điểm, cách thức...)
  final List<GrammarUsage> usages;

  /// Tag phân loại ví dụ theo cách dùng (e.g. ['THỜI GIAN', 'ĐỊA ĐIỂM', 'CÁCH THỨC'])
  final List<String> exampleTags;

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
    this.formulaParts = const [],
    this.usages = const [],
    this.exampleTags = const [],
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
      formulaParts: formulaParts,
      usages: usages,
      exampleTags: exampleTags,
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
      isBookmarked: false,
      isMastered: false,
      formulaParts: (json['formulaParts'] as List?)
              ?.map((e) => FormulaPart(
                    text: e['text'] ?? '',
                    isHighlighted: e['isHighlighted'] == true,
                  ))
              .toList() ??
          [],
      usages: (json['usages'] as List?)
              ?.map((e) => GrammarUsage(
                    icon: e['icon'] ?? '',
                    title: e['title'] ?? '',
                    description: e['description'] ?? '',
                  ))
              .toList() ??
          [],
      exampleTags: List<String>.from(json['exampleTags'] ?? []),
    );
  }

  /// Tạo GrammarPoint từ Drift DbModel (thay thế _mapToDomain trong datasource).
  factory GrammarPoint.fromDbModel(dynamic model) {
    return GrammarPoint(
      id: model.id as String,
      title: model.title as String,
      structure: model.structure as String,
      explanation: model.explanation as String,
      level: model.level as int,
      category: model.category as String,
      examples: List<GrammarExample>.from(model.examples as List),
      relatedGrammar: List<String>.from(model.relatedGrammar as List),
      isBookmarked: model.isBookmarked as bool,
      isMastered: model.isMastered as bool,
      formulaParts: List<FormulaPart>.from(model.formulaParts as List),
      usages: List<GrammarUsage>.from(model.usages as List),
      exampleTags: List<String>.from(model.exampleTags as List),
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
    formulaParts,
    usages,
    exampleTags,
  ];
}
