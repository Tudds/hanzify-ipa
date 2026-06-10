class LessonContext {
  const LessonContext({
    required this.stageId,
    required this.moduleId,
    required this.lessonUnitId,
    required this.level,
    required this.conversationIds,
    required this.grammarIds,
    this.lessonType = '',
  });

  final String stageId;
  final String moduleId;
  final String lessonUnitId;
  final int level;
  final List<String> conversationIds;
  final List<String> grammarIds;
  final String lessonType;
}
