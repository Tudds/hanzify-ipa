import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/learning/data/dialogue_scene_repository.dart';
import '../../../core/providers/dialogue_scene_provider.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../dictionary/data/library_repository.dart';
import '../../dictionary/domain/grammar_item.dart';
import '../../dictionary/domain/vocab_item.dart';
import '../domain/dictation.dart';
import '../domain/gen_ui_chat.dart';
import 'dictation_exercise_service.dart';

abstract class GenUiChatResponder {
  Future<List<GenUiBlock>> respond(String prompt);
}

class LocalGenUiChatResponder implements GenUiChatResponder {
  const LocalGenUiChatResponder({
    required LibraryRepository libraryRepository,
    required DialogueSceneRepository dialogueRepository,
    required DictationExerciseService dictationService,
    this.activeLevel = 2,
  }) : _libraryRepository = libraryRepository,
       _dialogueRepository = dialogueRepository,
       _dictationService = dictationService;

  final LibraryRepository _libraryRepository;
  final DialogueSceneRepository _dialogueRepository;
  final DictationExerciseService _dictationService;
  final int activeLevel;

  @override
  Future<List<GenUiBlock>> respond(String prompt) async {
    final normalized = prompt.trim().toLowerCase();

    // Dictation phải check trước quiz: "luyện nghe"/"luyện dịch" chứa "luyện"
    // nên sẽ bị _isQuizPrompt nuốt mất nếu để sau.
    if (_isListenDictationPrompt(normalized)) {
      return _dictationBlocks(DictationMode.listen);
    }
    if (_isTranslateDictationPrompt(normalized)) {
      return _dictationBlocks(DictationMode.readVi);
    }

    final vocab = await _libraryRepository.loadVocab();
    final grammar = await _libraryRepository.loadGrammar();
    final scenes = await _dialogueRepository.loadScenes();
    final scene = scenes.values.isEmpty ? null : scenes.values.first;
    final vocabHit = _findVocab(vocab, normalized) ?? _firstOrNull(vocab);
    final grammarHit =
        _findGrammar(grammar, normalized) ?? _firstOrNull(grammar);
    final blocks = <GenUiBlock>[];

    if (_isQuizPrompt(normalized)) {
      final quizItem = vocabHit ?? _firstOrNull(vocab);
      if (quizItem != null) {
        blocks.add(
          ChatBubbleBlock('Mình tạo nhanh một quiz local từ dữ liệu HSK.'),
        );
        blocks.add(_quickQuizFrom(quizItem, vocab));
        final arrange = _sentenceArrangeFrom(quizItem);
        if (arrange != null) blocks.add(arrange);
      }
    } else if (_isGrammarPrompt(normalized)) {
      if (grammarHit != null) {
        blocks.add(
          ChatBubbleBlock('Đây là điểm ngữ pháp phù hợp nhất mình tìm thấy.'),
        );
        blocks.add(_grammarBlock(grammarHit));
      }
    } else if (_isDialoguePrompt(normalized) && scene != null) {
      final line = scene.lines.isEmpty ? null : scene.lines.first;
      blocks.add(
        ChatBubbleBlock(
          line == null
              ? scene.description
              : '${scene.title}: ${line.zh} - ${line.vi}',
        ),
      );
      for (final item in scene.vocabulary.take(2)) {
        blocks.add(
          VocabCardBlock(
            id: item.zh,
            hanzi: item.zh,
            pinyin: item.pinyin,
            vi: item.vi,
            level: scene.level,
          ),
        );
      }
    } else {
      if (vocabHit != null) {
        blocks.add(
          ChatBubbleBlock('Mình tìm thấy từ gần với câu hỏi của bạn.'),
        );
        blocks.add(_vocabBlock(vocabHit));
      }
      if (grammarHit != null) {
        blocks.add(_grammarBlock(grammarHit));
      }
      if (vocabHit == null && grammarHit == null) {
        blocks.add(
          const ChatBubbleBlock(
            'Mình có thể tra từ, giải thích ngữ pháp, tạo quiz hoặc gợi ý câu hội thoại từ dữ liệu local.',
          ),
        );
      }
    }

    blocks.add(
      const SuggestionActionsBlock([
        GenUiSuggestionAction(label: 'Tạo quiz', prompt: 'Tạo quiz HSK 2'),
        GenUiSuggestionAction(
          label: 'Ngữ pháp',
          prompt: 'Giải thích câu với 了',
        ),
        GenUiSuggestionAction(
          label: 'Hội thoại',
          prompt: 'Cho mình hội thoại mẫu',
        ),
      ]),
    );
    return blocks;
  }

  Future<List<GenUiBlock>> _dictationBlocks(DictationMode mode) async {
    final exercise = await _dictationService.nextExercise(
      mode: mode,
      level: activeLevel,
    );
    final suggestions = SuggestionActionsBlock([
      GenUiSuggestionAction(
        label: 'Câu khác',
        prompt: mode == DictationMode.listen
            ? 'Luyện nghe chép chính tả'
            : 'Luyện dịch Việt-Trung',
      ),
      GenUiSuggestionAction(
        label: mode == DictationMode.listen ? 'Luyện dịch' : 'Luyện nghe',
        prompt: mode == DictationMode.listen
            ? 'Luyện dịch Việt-Trung'
            : 'Luyện nghe chép chính tả',
      ),
    ]);
    if (exercise == null) {
      return [
        ChatBubbleBlock('Chưa có câu luyện phù hợp cho HSK $activeLevel.'),
        suggestions,
      ];
    }
    return [
      ChatBubbleBlock(
        mode == DictationMode.listen
            ? 'Nghe audio rồi gõ lại câu bằng chữ Hán nhé.'
            : 'Dịch câu sau sang tiếng Trung nhé.',
      ),
      DictationBlock(exercise),
      suggestions,
    ];
  }

  bool _isListenDictationPrompt(String prompt) {
    return prompt.contains('luyện nghe') ||
        prompt.contains('chép chính tả') ||
        prompt.contains('nghe viết') ||
        prompt.contains('nghe gõ') ||
        prompt.contains('nghe rồi viết') ||
        prompt.contains('dictation');
  }

  bool _isTranslateDictationPrompt(String prompt) {
    return prompt.contains('luyện dịch') ||
        prompt.contains('dịch việt') ||
        prompt.contains('dịch sang tiếng trung') ||
        prompt.contains('việt-trung') ||
        prompt.contains('việt trung');
  }

  bool _isQuizPrompt(String prompt) {
    return prompt.contains('quiz') ||
        prompt.contains('luyện') ||
        prompt.contains('ôn') ||
        prompt.contains('kiem tra') ||
        prompt.contains('kiểm tra');
  }

  bool _isGrammarPrompt(String prompt) {
    return prompt.contains('ngữ pháp') || prompt.contains('grammar');
  }

  bool _isDialoguePrompt(String prompt) {
    return prompt.contains('hội thoại') ||
        prompt.contains('đối thoại') ||
        prompt.contains('dialogue') ||
        prompt.contains('conversation');
  }

  VocabItem? _findVocab(List<VocabItem> items, String prompt) {
    for (final item in items) {
      if (prompt.contains(item.hanzi.toLowerCase()) ||
          prompt.contains(item.pinyinNormalized.toLowerCase()) ||
          prompt.contains(item.pinyin.toLowerCase())) {
        return item;
      }
      for (final meaning in item.meanings) {
        if (meaning.vi.isNotEmpty &&
            prompt.contains(meaning.vi.toLowerCase())) {
          return item;
        }
      }
    }
    return null;
  }

  GrammarItem? _findGrammar(List<GrammarItem> items, String prompt) {
    for (final item in items) {
      if (prompt.contains(item.title.toLowerCase()) ||
          prompt.contains(item.structure.toLowerCase())) {
        return item;
      }
    }
    return null;
  }

  VocabCardBlock _vocabBlock(VocabItem item) {
    return VocabCardBlock(
      id: item.id,
      hanzi: item.hanzi,
      pinyin: item.pinyin,
      vi: item.viShort,
      level: item.level,
    );
  }

  GrammarCardBlock _grammarBlock(GrammarItem item) {
    return GrammarCardBlock(
      id: item.id,
      title: item.title,
      structure: item.structure,
      explanation: item.explanation,
      level: item.level,
    );
  }

  QuickQuizBlock _quickQuizFrom(VocabItem item, List<VocabItem> vocab) {
    final choices = <String>{
      item.viShort,
      for (final other in vocab)
        if (other.id != item.id && other.viShort.isNotEmpty) other.viShort,
    }.take(4).toList(growable: false);

    return QuickQuizBlock(
      prompt: '${item.hanzi} nghĩa là gì?',
      choices: choices,
      answer: item.viShort,
      explanation: item.examples.isEmpty
          ? 'Từ này thuộc HSK ${item.level}.'
          : item.examples.first.vi,
    );
  }

  SentenceArrangeBlock? _sentenceArrangeFrom(VocabItem item) {
    if (item.examples.isEmpty) return null;
    final example = item.examples.first;
    final tokens = [
      for (final rune in example.cn.runes)
        if (String.fromCharCode(rune).trim().isNotEmpty)
          String.fromCharCode(rune),
    ];
    if (tokens.length < 2 || tokens.length > 12) return null;
    final shuffled = List<String>.of(tokens)..shuffle();
    return SentenceArrangeBlock(
      translation: example.vi,
      tokens: shuffled,
      answer: tokens.join(),
    );
  }

  T? _firstOrNull<T>(List<T> items) {
    return items.isEmpty ? null : items.first;
  }
}

final genUiChatResponderProvider = Provider<GenUiChatResponder>((ref) {
  return LocalGenUiChatResponder(
    libraryRepository: ref.watch(libraryRepositoryProvider),
    dialogueRepository: ref.watch(dialogueSceneRepositoryProvider),
    dictationService: ref.watch(dictationExerciseServiceProvider),
    activeLevel: ref.watch(
      userProfileProvider.select((profile) => profile.activeLevel),
    ),
  );
});
