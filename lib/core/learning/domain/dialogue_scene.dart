import 'package:flutter/material.dart';

class DialogueScene {
  const DialogueScene({
    required this.id,
    required this.level,
    required this.title,
    required this.titleZh,
    required this.titlePinyin,
    required this.description,
    required this.category,
    required this.icon,
    required this.speakers,
    required this.lines,
    this.cultureTip,
    this.relatedGrammar = const [],
    this.vocabulary = const [],
  });

  factory DialogueScene.fromJson(Map<String, dynamic> json) {
    final speakerList = (json['speakers'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(DialogueSpeaker.fromJson)
        .toList(growable: false);
    final lineList = (json['lines'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    return DialogueScene(
      id: json['id'] as String,
      level: (json['level'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      titleZh: json['titleZh'] as String? ?? '',
      titlePinyin: json['titlePinyin'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      speakers: speakerList,
      lines: [
        for (var i = 0; i < lineList.length; i++)
          DialogueLine.fromJson(lineList[i], index: i),
      ],
      cultureTip: (json['cultureTip'] as String?)?.trim().isEmpty ?? true
          ? null
          : json['cultureTip'] as String,
      relatedGrammar: List<String>.from(
        json['relatedGrammar'] as List? ?? const [],
      ),
      vocabulary: (json['vocabulary'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(DialogueVocabulary.fromJson)
          .toList(growable: false),
    );
  }

  final String id;
  final int level;
  final String title;
  final String titleZh;
  final String titlePinyin;
  final String description;
  final String category;
  final String icon;
  final List<DialogueSpeaker> speakers;
  final List<DialogueLine> lines;
  final String? cultureTip;
  final List<String> relatedGrammar;
  final List<DialogueVocabulary> vocabulary;

  DialogueSpeaker speakerOf(String code) {
    for (final speaker in speakers) {
      if (speaker.code == code) return speaker;
    }
    return DialogueSpeaker.fallback(code);
  }
}

class DialogueVocabulary {
  const DialogueVocabulary({
    required this.zh,
    required this.pinyin,
    required this.vi,
    required this.pos,
  });

  factory DialogueVocabulary.fromJson(Map<String, dynamic> json) {
    return DialogueVocabulary(
      zh: json['zh'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
      pos: json['pos'] as String? ?? '',
    );
  }

  final String zh;
  final String pinyin;
  final String vi;
  final String pos;
}

class DialogueSpeaker {
  const DialogueSpeaker({
    required this.code,
    required this.nameVi,
    required this.role,
    required this.avatarColor,
  });

  factory DialogueSpeaker.fromJson(Map<String, dynamic> json) {
    return DialogueSpeaker(
      code: json['code'] as String? ?? '',
      nameVi: json['nameVi'] as String? ?? '',
      role: json['role'] as String? ?? '',
      avatarColor: parseHexColor(json['avatarColor'] as String?),
    );
  }

  factory DialogueSpeaker.fallback(String code) {
    return DialogueSpeaker(
      code: code,
      nameVi: 'Người $code',
      role: '',
      avatarColor: null,
    );
  }

  final String code;
  final String nameVi;
  final String role;
  final Color? avatarColor;

  String get initial {
    final trimmed = nameVi.trim();
    if (trimmed.isEmpty) return code;
    return trimmed.characters.first.toUpperCase();
  }
}

class DialogueLine {
  const DialogueLine({
    required this.index,
    required this.speakerCode,
    required this.zh,
    required this.pinyin,
    required this.vi,
  });

  factory DialogueLine.fromJson(
    Map<String, dynamic> json, {
    required int index,
  }) {
    return DialogueLine(
      index: index,
      speakerCode: json['speaker'] as String? ?? '',
      zh: json['zh'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
    );
  }

  final int index;
  final String speakerCode;
  final String zh;
  final String pinyin;
  final String vi;
}

@visibleForTesting
Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  var value = hex.trim();
  if (value.isEmpty) return null;
  if (value.startsWith('#')) value = value.substring(1);
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(parsed);
}
