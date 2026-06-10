import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning_path/learning_path_models.dart';
import 'package:hanzify/core/learning_path/learning_path_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads HSK1-HSK4 learning path from asset', () async {
    const repository = LearningPathRepository();

    final path = await repository.load();

    expect(path.stages.length, 4);
    expect(path.stages.map((stage) => stage.id), [
      'HSK1',
      'HSK2',
      'HSK3',
      'HSK4',
    ]);
    expect(path.stages.expand((stage) => stage.modules).length, 27);
    expect(path.stages.expand((stage) => stage.checkpoints).length, 8);
    expect(path.stages[1].modules.first.id, 'H2-M1');
    expect(
      path.stages[1].modules.first.lessons.first.title,
      'Từ vựng mục tiêu',
    );
    expect(path.stages[1].modules.first.phases.length, 1);
    expect(path.stages[1].modules.first.phases.first.type, 'legacy');
  });

  test('parses module phases and keeps flat lessons order', () {
    final module = LearningModule.fromJson({
      'id': 'H1-M1',
      'title': 'Module',
      'type': 'conversation',
      'phases': [
        {
          'id': 'intake',
          'title': 'Intake',
          'type': 'intake',
          'lessons': [
            {'index': 1, 'type': 'preview', 'title': 'Preview'},
            {'index': 2, 'type': 'input', 'title': 'Input'},
          ],
        },
        {
          'id': 'practice',
          'title': 'Practice',
          'type': 'practice',
          'lessons': [
            {'index': 3, 'type': 'pattern_a', 'title': 'Pattern A'},
          ],
        },
      ],
    });

    expect(module.phases.map((phase) => phase.id), ['intake', 'practice']);
    expect(module.lessons.map((lesson) => lesson.index), [1, 2, 3]);
  });
}
