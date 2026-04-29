import 'dart:convert';

import 'package:flutter/services.dart';

import 'learning_path_models.dart';

class LearningPathRepository {
  const LearningPathRepository({AssetBundle? bundle}) : _bundle = bundle;

  static const assetPath = 'assets/data/learning_path/hsk_learning_path_v1.json';

  final AssetBundle? _bundle;

  Future<HskLearningPath> load() async {
    final bundle = _bundle ?? rootBundle;
    final raw = await bundle.loadString(assetPath);
    return HskLearningPath.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
