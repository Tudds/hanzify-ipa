import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../learning/data/dialogue_scene_repository.dart';
import '../learning/domain/dialogue_scene.dart';

final dialogueSceneRepositoryProvider = Provider<DialogueSceneRepository>(
  (ref) => DialogueSceneRepository(),
);

final dialogueScenesProvider = FutureProvider<Map<String, DialogueScene>>((
  ref,
) async {
  final repository = ref.watch(dialogueSceneRepositoryProvider);
  return repository.loadScenes();
});
