enum ChatMessageRole { user, assistant }

class GenUiChatMessage {
  const GenUiChatMessage({
    required this.id,
    required this.role,
    this.text = '',
    this.blocks = const [],
  });

  final String id;
  final ChatMessageRole role;
  final String text;
  final List<GenUiBlock> blocks;
}

sealed class GenUiBlock {
  const GenUiBlock();
}

final class ChatBubbleBlock extends GenUiBlock {
  const ChatBubbleBlock(this.text);

  final String text;
}

final class VocabCardBlock extends GenUiBlock {
  const VocabCardBlock({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    required this.vi,
    required this.level,
  });

  final String id;
  final String hanzi;
  final String pinyin;
  final String vi;
  final int level;
}

final class GrammarCardBlock extends GenUiBlock {
  const GrammarCardBlock({
    required this.id,
    required this.title,
    required this.structure,
    required this.explanation,
    required this.level,
  });

  final String id;
  final String title;
  final String structure;
  final String explanation;
  final int level;
}

final class QuickQuizBlock extends GenUiBlock {
  const QuickQuizBlock({
    required this.prompt,
    required this.choices,
    required this.answer,
    required this.explanation,
  });

  final String prompt;
  final List<String> choices;
  final String answer;
  final String explanation;
}

final class SentenceArrangeBlock extends GenUiBlock {
  const SentenceArrangeBlock({
    required this.translation,
    required this.tokens,
    required this.answer,
  });

  final String translation;
  final List<String> tokens;
  final String answer;
}

final class SuggestionActionsBlock extends GenUiBlock {
  const SuggestionActionsBlock(this.actions);

  final List<GenUiSuggestionAction> actions;
}

class GenUiSuggestionAction {
  const GenUiSuggestionAction({required this.label, required this.prompt});

  final String label;
  final String prompt;
}
