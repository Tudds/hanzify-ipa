class HskLearningPath {
  const HskLearningPath({required this.version, required this.title, required this.stages});

  factory HskLearningPath.fromJson(Map<String, dynamic> json) {
    return HskLearningPath(
      version: json['version'] as String? ?? '',
      title: json['title'] as String? ?? '',
      stages: (json['stages'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(LearningStage.fromJson)
          .toList(growable: false),
    );
  }

  final String version;
  final String title;
  final List<LearningStage> stages;
}

class LearningStage {
  const LearningStage({
    required this.id,
    required this.goal,
    required this.modules,
    required this.checkpoints,
  });

  factory LearningStage.fromJson(Map<String, dynamic> json) {
    return LearningStage(
      id: json['stage'] as String,
      goal: json['goal'] as String? ?? '',
      modules: (json['modules'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(LearningModule.fromJson)
          .toList(growable: false),
      checkpoints: (json['checkpoints'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(LearningCheckpoint.fromJson)
          .toList(growable: false),
    );
  }

  final String id;
  final String goal;
  final List<LearningModule> modules;
  final List<LearningCheckpoint> checkpoints;

  int get level => int.tryParse(id.replaceAll('HSK', '')) ?? 1;
}

class LearningModule {
  const LearningModule({
    required this.id,
    required this.title,
    required this.type,
    required this.canDo,
    required this.sourceConversationIds,
    required this.primaryGrammarIds,
    required this.lessons,
  });

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    return LearningModule(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      canDo: json['canDo'] as String? ?? '',
      sourceConversationIds: List<String>.from(json['sourceConversationIds'] as List? ?? const []),
      primaryGrammarIds: List<String>.from(json['primaryGrammarIds'] as List? ?? const []),
      lessons: (json['lessons'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(LearningLesson.fromJson)
          .toList(growable: false),
    );
  }

  final String id;
  final String title;
  final String type;
  final String canDo;
  final List<String> sourceConversationIds;
  final List<String> primaryGrammarIds;
  final List<LearningLesson> lessons;
}

class LearningLesson {
  const LearningLesson({
    required this.index,
    required this.type,
    required this.title,
    required this.conversationIds,
    required this.focusGrammarIds,
  });

  factory LearningLesson.fromJson(Map<String, dynamic> json) {
    return LearningLesson(
      index: json['index'] as int,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      conversationIds: List<String>.from(json['conversationIds'] as List? ?? const []),
      focusGrammarIds: List<String>.from(json['focusGrammarIds'] as List? ?? const []),
    );
  }

  final int index;
  final String type;
  final String title;
  final List<String> conversationIds;
  final List<String> focusGrammarIds;
}

class LearningCheckpoint {
  const LearningCheckpoint({required this.id, required this.afterModule, required this.focus});

  factory LearningCheckpoint.fromJson(Map<String, dynamic> json) {
    return LearningCheckpoint(
      id: json['id'] as String,
      afterModule: json['afterModule'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
    );
  }

  final String id;
  final String afterModule;
  final String focus;
}
