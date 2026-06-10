import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/hsk_levels.dart';

class HskGrammarAssetRepository {
  const HskGrammarAssetRepository({AssetBundle? bundle}) : _bundle = bundle;

  static const _assetPaths = {
    1: 'assets/data/grammar_hsk1.json',
    2: 'assets/data/grammar_hsk2.json',
    3: 'assets/data/grammar_hsk3.json',
    4: 'assets/data/grammar_hsk4.json',
  };

  final AssetBundle? _bundle;

  Future<List<HskGrammarItem>> loadGrammar({
    List<int> levels = kHskLevels,
  }) async {
    final bundle = _bundle ?? rootBundle;
    final itemsByLevel = <int, List<HskGrammarItem>>{};

    for (final level in levels) {
      final path = _assetPaths[level];
      if (path == null) continue;
      try {
        final raw = await bundle.loadString(path);
        final json = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        itemsByLevel[level] = json
            .map(HskGrammarItem.fromJson)
            .where((item) => item.title.isNotEmpty)
            .toList(growable: false);
      } catch (_) {
        itemsByLevel[level] = const [];
      }
    }

    return _roundRobin(levels, itemsByLevel);
  }

  List<HskGrammarItem> _roundRobin(
    List<int> levels,
    Map<int, List<HskGrammarItem>> itemsByLevel,
  ) {
    final orderedLevels = [
      for (final level in levels)
        if (_assetPaths.containsKey(level)) level,
    ];
    final result = <HskGrammarItem>[];
    var index = 0;

    while (true) {
      var added = false;
      for (final level in orderedLevels) {
        final items = itemsByLevel[level] ?? const <HskGrammarItem>[];
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

class HskGrammarItem {
  const HskGrammarItem({
    required this.id,
    required this.title,
    required this.structure,
    required this.explanation,
    required this.level,
    required this.category,
    required this.formulaParts,
    required this.examples,
    required this.usages,
  });

  factory HskGrammarItem.fromJson(Map<String, dynamic> json) {
    return HskGrammarItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      structure: json['structure'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      level: json['level'] as int? ?? 1,
      category: json['category'] as String? ?? '',
      formulaParts: (json['formulaParts'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(HskGrammarFormulaPart.fromJson)
          .toList(growable: false),
      examples: (json['examples'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(HskGrammarExample.fromJson)
          .toList(growable: false),
      usages: (json['usages'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(HskGrammarUsage.fromJson)
          .where((usage) => usage.title.isNotEmpty)
          .toList(growable: false),
    );
  }

  final String id;
  final String title;
  final String structure;
  final String explanation;
  final int level;
  final String category;
  final List<HskGrammarFormulaPart> formulaParts;
  final List<HskGrammarExample> examples;
  final List<HskGrammarUsage> usages;
}

class HskGrammarUsage {
  const HskGrammarUsage({required this.title, required this.description});

  factory HskGrammarUsage.fromJson(Map<String, dynamic> json) {
    return HskGrammarUsage(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  final String title;
  final String description;
}

class HskGrammarFormulaPart {
  const HskGrammarFormulaPart({
    required this.text,
    required this.isHighlighted,
  });

  factory HskGrammarFormulaPart.fromJson(Map<String, dynamic> json) {
    return HskGrammarFormulaPart(
      text: json['text'] as String? ?? '',
      isHighlighted: json['isHighlighted'] as bool? ?? false,
    );
  }

  final String text;
  final bool isHighlighted;
}

class HskGrammarExample {
  const HskGrammarExample({
    required this.hanzi,
    required this.pinyin,
    required this.vi,
  });

  factory HskGrammarExample.fromJson(Map<String, dynamic> json) {
    return HskGrammarExample(
      hanzi: json['zh'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      vi: json['vi'] as String? ?? '',
    );
  }

  final String hanzi;
  final String pinyin;
  final String vi;
}
