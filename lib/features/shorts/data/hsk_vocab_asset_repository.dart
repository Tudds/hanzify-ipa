import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/hsk_levels.dart';

class HskVocabAssetRepository {
  const HskVocabAssetRepository({AssetBundle? bundle}) : _bundle = bundle;

  static const _assetPaths = {
    1: 'assets/data/hsk1.json',
    2: 'assets/data/hsk2.json',
    3: 'assets/data/hsk3.json',
    4: 'assets/data/hsk4.json',
  };

  final AssetBundle? _bundle;

  Future<List<HskVocabItem>> loadVocab({
    List<int> levels = kHskLevels,
  }) async {
    final bundle = _bundle ?? rootBundle;
    final itemsByLevel = <int, List<HskVocabItem>>{};

    for (final level in levels) {
      final path = _assetPaths[level];
      if (path == null) continue;
      try {
        final raw = await bundle.loadString(path);
        final json = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        itemsByLevel[level] = json
            .map(HskVocabItem.fromJson)
            .where((item) => item.hanzi.isNotEmpty)
            .toList(growable: false);
      } catch (_) {
        itemsByLevel[level] = const [];
      }
    }

    return _roundRobin(levels, itemsByLevel);
  }

  List<HskVocabItem> _roundRobin(
    List<int> levels,
    Map<int, List<HskVocabItem>> itemsByLevel,
  ) {
    final orderedLevels = [
      for (final level in levels)
        if (_assetPaths.containsKey(level)) level,
    ];
    final result = <HskVocabItem>[];
    var index = 0;

    while (true) {
      var added = false;
      for (final level in orderedLevels) {
        final items = itemsByLevel[level] ?? const <HskVocabItem>[];
        if (index >= items.length) continue;
        result.add(items[index]);
        added = true;
      }
      if (!added) break;
      index++;
    }

    return List.unmodifiable(result);
  }
}

class HskVocabItem {
  const HskVocabItem({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    required this.meanings,
    required this.examples,
    required this.level,
    required this.wordType,
    required this.tags,
    required this.frequency,
  });

  factory HskVocabItem.fromJson(Map<String, dynamic> json) {
    return HskVocabItem(
      id: json['id'] as String,
      hanzi: json['hanzi'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      meanings: (json['meanings'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(HskVocabMeaning.fromJson)
          .toList(growable: false),
      examples: (json['exampleSentences'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(HskVocabExample.fromJson)
          .toList(growable: false),
      level: json['level'] as int? ?? 1,
      wordType: json['wordType'] as String? ?? '',
      tags: (json['tags'] as List? ?? const []).cast<String>(),
      frequency: json['frequency'] as String? ?? '',
    );
  }

  final String id;
  final String hanzi;
  final String pinyin;
  final List<HskVocabMeaning> meanings;
  final List<HskVocabExample> examples;
  final int level;
  final String wordType;
  final List<String> tags;
  final String frequency;

  String get viShort => meanings.isEmpty ? '' : meanings.first.vi;
}

class HskVocabMeaning {
  const HskVocabMeaning({
    required this.pos,
    required this.vi,
    required this.en,
  });

  factory HskVocabMeaning.fromJson(Map<String, dynamic> json) {
    return HskVocabMeaning(
      pos: json['pos'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );
  }

  final String pos;
  final String vi;
  final String en;
}

class HskVocabExample {
  const HskVocabExample({
    required this.cn,
    required this.pinyin,
    required this.vi,
  });

  factory HskVocabExample.fromJson(Map<String, dynamic> json) {
    return HskVocabExample(
      cn: json['cn'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
    );
  }

  final String cn;
  final String pinyin;
  final String vi;
}
