import 'dart:convert';

import 'package:flutter/services.dart';

import 'learning_path_models.dart';

class LearningPathRepository {
  const LearningPathRepository({AssetBundle? bundle}) : _bundle = bundle;

  static const assetPath =
      'assets/data/learning_path/hsk_learning_path_v1.json';

  final AssetBundle? _bundle;

  Future<HskLearningPath> load() async {
    final bundle = _bundle ?? rootBundle;
    final raw = await bundle.loadString(assetPath);
    return HskLearningPath.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<LearningLessonMatch?> findLessonByConversationId(
    String conversationId,
  ) async {
    final path = await load();
    for (final stage in path.stages) {
      for (final module in stage.modules) {
        for (final lesson in module.lessons) {
          if (lesson.conversationIds.contains(conversationId)) {
            return LearningLessonMatch(
              stage: stage,
              module: module,
              lesson: lesson,
              lessonUnitId: '${module.id}-L${lesson.index}',
            );
          }
        }
      }
    }
    return null;
  }
}

class LearningLessonMatch {
  const LearningLessonMatch({
    required this.stage,
    required this.module,
    required this.lesson,
    required this.lessonUnitId,
  });

  final LearningStage stage;
  final LearningModule module;
  final LearningLesson lesson;
  final String lessonUnitId;
}
