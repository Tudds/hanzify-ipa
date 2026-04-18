import 'package:equatable/equatable.dart';

/// Một dòng hội thoại (câu nói của một người trong đoạn chat).
class DialogueLine extends Equatable {
  /// Người nói: 'A', 'B', 'C'... hoặc tên nhân vật
  final String speaker;

  /// Câu tiếng Trung
  final String zh;

  /// Pinyin của câu
  final String pinyin;

  /// Dịch nghĩa tiếng Việt
  final String vi;

  const DialogueLine({
    required this.speaker,
    required this.zh,
    required this.pinyin,
    required this.vi,
  });

  DialogueLine copyWith({
    String? speaker,
    String? zh,
    String? pinyin,
    String? vi,
  }) {
    return DialogueLine(
      speaker: speaker ?? this.speaker,
      zh: zh ?? this.zh,
      pinyin: pinyin ?? this.pinyin,
      vi: vi ?? this.vi,
    );
  }

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      speaker: json['speaker'] ?? 'A',
      zh: json['zh'] ?? '',
      pinyin: json['pinyin'] ?? '',
      vi: json['vi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'speaker': speaker,
        'zh': zh,
        'pinyin': pinyin,
        'vi': vi,
      };

  @override
  List<Object?> get props => [speaker, zh, pinyin, vi];
}

/// Từ vựng xuất hiện trong bối cảnh hội thoại (giúp người học nắm bắt từ khóa).
class VocabInContext extends Equatable {
  /// Từ tiếng Trung
  final String zh;

  /// Pinyin
  final String pinyin;

  /// Nghĩa tiếng Việt
  final String vi;

  /// Loại từ (danh từ, động từ, v.v.)
  final String pos;

  /// ID của từ vựng tương ứng trong bảng VocabsTable (nếu có)
  final String? vocabId;

  const VocabInContext({
    required this.zh,
    required this.pinyin,
    required this.vi,
    this.pos = '',
    this.vocabId,
  });

  factory VocabInContext.fromJson(Map<String, dynamic> json) {
    return VocabInContext(
      zh: json['zh'] ?? '',
      pinyin: json['pinyin'] ?? '',
      vi: json['vi'] ?? '',
      pos: json['pos'] ?? '',
      vocabId: json['vocabId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'zh': zh,
        'pinyin': pinyin,
        'vi': vi,
        'pos': pos,
        if (vocabId != null) 'vocabId': vocabId,
      };

  @override
  List<Object?> get props => [zh, pinyin, vi, pos, vocabId];
}

/// Thông tin nhân vật trong hội thoại.
class SpeakerInfo extends Equatable {
  /// Mã người nói (khớp với DialogueLine.speaker)
  final String code;

  /// Tên hiển thị tiếng Việt
  final String nameVi;

  /// Mô tả vai (ví dụ: "Nhân viên cửa hàng", "Khách hàng")
  final String role;

  /// Màu avatar (hex string, ví dụ '#FF6B6B')
  final String avatarColor;

  const SpeakerInfo({
    required this.code,
    required this.nameVi,
    this.role = '',
    this.avatarColor = '#6C63FF',
  });

  factory SpeakerInfo.fromJson(Map<String, dynamic> json) {
    return SpeakerInfo(
      code: json['code'] ?? 'A',
      nameVi: json['nameVi'] ?? '',
      role: json['role'] ?? '',
      avatarColor: json['avatarColor'] ?? '#6C63FF',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'nameVi': nameVi,
        'role': role,
        'avatarColor': avatarColor,
      };

  @override
  List<Object?> get props => [code, nameVi, role, avatarColor];
}

/// Một bài hội thoại hoàn chỉnh với bối cảnh.
class ConversationContext extends Equatable {
  /// ID duy nhất của bài hội thoại
  final String id;

  /// Tiêu đề bài hội thoại (tiếng Việt)
  final String title;

  /// Tiêu đề tiếng Trung
  final String titleZh;

  /// Pinyin của tiêu đề tiếng Trung
  final String titlePinyin;

  /// Mô tả ngắn bối cảnh (tiếng Việt)
  final String description;

  /// Cấp độ HSK (1, 2, 3)
  final int level;

  /// Thể loại hội thoại: greeting, shopping, transport, restaurant, daily, school, travel, phone, workplace
  final String category;

  /// Icon đại diện (emoji hoặc icon name)
  final String icon;

  /// Các dòng hội thoại
  final List<DialogueLine> lines;

  /// Từ vựng quan trọng trong bài
  final List<VocabInContext> vocabulary;

  /// Thông tin người nói
  final List<SpeakerInfo> speakers;

  /// ID các điểm ngữ pháp liên quan (tham chiếu đến GrammarPoint.id)
  final List<String> relatedGrammar;

  /// Gợi ý văn hóa (tips về cách giao tiếp trong bối cảnh này)
  final String cultureTip;

  /// Đã đánh dấu (bookmark)
  final bool isBookmarked;

  /// Đã hoàn thành (mastered)
  final bool isMastered;

  const ConversationContext({
    required this.id,
    required this.title,
    required this.titleZh,
    required this.titlePinyin,
    required this.description,
    required this.level,
    required this.category,
    required this.icon,
    required this.lines,
    this.vocabulary = const [],
    this.speakers = const [],
    this.relatedGrammar = const [],
    this.cultureTip = '',
    this.isBookmarked = false,
    this.isMastered = false,
  });

  ConversationContext copyWith({
    bool? isBookmarked,
    bool? isMastered,
  }) {
    return ConversationContext(
      id: id,
      title: title,
      titleZh: titleZh,
      titlePinyin: titlePinyin,
      description: description,
      level: level,
      category: category,
      icon: icon,
      lines: lines,
      vocabulary: vocabulary,
      speakers: speakers,
      relatedGrammar: relatedGrammar,
      cultureTip: cultureTip,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isMastered: isMastered ?? this.isMastered,
    );
  }

  factory ConversationContext.fromJson(String id, Map<String, dynamic> json) {
    return ConversationContext(
      id: id,
      title: json['title'] ?? '',
      titleZh: json['titleZh'] ?? '',
      titlePinyin: json['titlePinyin'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? 1,
      category: json['category'] ?? 'greeting',
      icon: json['icon'] ?? '💬',
      lines: (json['lines'] as List?)
              ?.map((e) => DialogueLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vocabulary: (json['vocabulary'] as List?)
              ?.map((e) => VocabInContext.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      speakers: (json['speakers'] as List?)
              ?.map((e) => SpeakerInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      relatedGrammar: List<String>.from(json['relatedGrammar'] ?? []),
      cultureTip: json['cultureTip'] ?? '',
      isBookmarked: json['isBookmarked'] == true,
      isMastered: json['isMastered'] == true,
    );
  }

  /// Tạo ConversationContext từ Drift DbModel (thay thế _mapToDomain trong datasource).
  factory ConversationContext.fromDbModel(dynamic model) {
    return ConversationContext(
      id: model.id as String,
      title: model.title as String,
      titleZh: model.titleZh as String,
      titlePinyin: model.titlePinyin as String,
      description: model.description as String,
      level: model.level as int,
      category: model.category as String,
      icon: model.icon as String,
      lines: List<DialogueLine>.from(model.lines as List),
      vocabulary: List<VocabInContext>.from(model.vocabulary as List),
      speakers: List<SpeakerInfo>.from(model.speakers as List),
      relatedGrammar: List<String>.from(model.relatedGrammar as List),
      cultureTip: model.cultureTip as String,
      isBookmarked: model.isBookmarked as bool,
      isMastered: model.isMastered as bool,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleZh,
        titlePinyin,
        description,
        level,
        category,
        icon,
        lines,
        vocabulary,
        speakers,
        relatedGrammar,
        cultureTip,
        isBookmarked,
        isMastered,
      ];
}
