import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/profile/user_profile.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../domain/gen_ui_chat.dart';
import 'gen_ui_chat_responder.dart';

final genUiChatControllerProvider =
    AsyncNotifierProvider.autoDispose<GenUiChatController, GenUiChatState>(
      GenUiChatController.new,
    );

@immutable
class GenUiChatState {
  const GenUiChatState({
    required this.messages,
    this.isResponding = false,
    this.error,
  });

  final List<GenUiChatMessage> messages;
  final bool isResponding;
  final String? error;

  GenUiChatState copyWith({
    List<GenUiChatMessage>? messages,
    bool? isResponding,
    String? error,
  }) {
    return GenUiChatState(
      messages: messages ?? this.messages,
      isResponding: isResponding ?? this.isResponding,
      error: error,
    );
  }
}

class GenUiChatController extends AsyncNotifier<GenUiChatState> {
  var _nextId = 0;

  @override
  Future<GenUiChatState> build() async {
    final priority = ref.read(userProfileProvider).priority;
    return GenUiChatState(
      messages: [
        GenUiChatMessage(
          id: _id(),
          role: ChatMessageRole.assistant,
          blocks: [
            const ChatBubbleBlock(
              'Chào bạn, mình là Chat GenUI local. Mình có thể tra từ, giải thích ngữ pháp, tạo quiz và luyện nghe-viết chữ Hán từ dữ liệu offline.',
            ),
            SuggestionActionsBlock(_greetingActions(priority)),
          ],
        ),
      ],
    );
  }

  /// Chip ưu tiên từ onboarding đứng đầu danh sách gợi ý.
  static List<GenUiSuggestionAction> _greetingActions(
    LearningPriority priority,
  ) {
    const listen = GenUiSuggestionAction(
      label: 'Luyện nghe',
      prompt: 'Luyện nghe chép chính tả',
    );
    const translate = GenUiSuggestionAction(
      label: 'Luyện dịch',
      prompt: 'Luyện dịch Việt-Trung',
    );
    const lookup = GenUiSuggestionAction(label: 'Tra từ', prompt: 'Tra từ 学习');
    const quiz = GenUiSuggestionAction(
      label: 'Tạo quiz',
      prompt: 'Tạo quiz HSK 2',
    );
    const dialogue = GenUiSuggestionAction(
      label: 'Hội thoại',
      prompt: 'Cho mình hội thoại mẫu',
    );

    final first = switch (priority) {
      LearningPriority.listening => listen,
      LearningPriority.writing => translate,
      LearningPriority.conversation => dialogue,
      LearningPriority.vocabulary => quiz,
    };
    return [
      first,
      for (final action in const [lookup, quiz, dialogue, listen, translate])
        if (action != first) action,
    ];
  }

  Future<void> sendPrompt(String prompt) async {
    final text = prompt.trim();
    if (text.isEmpty) return;

    final current = state.value ?? await build();
    final userMessage = GenUiChatMessage(
      id: _id(),
      role: ChatMessageRole.user,
      text: text,
    );
    final messages = [...current.messages, userMessage];
    state = AsyncValue.data(
      current.copyWith(messages: messages, isResponding: true),
    );

    try {
      final blocks = await ref.read(genUiChatResponderProvider).respond(text);
      final assistant = GenUiChatMessage(
        id: _id(),
        role: ChatMessageRole.assistant,
        blocks: blocks,
      );
      state = AsyncValue.data(
        GenUiChatState(messages: [...messages, assistant]),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  String _id() {
    _nextId += 1;
    return 'chat_$_nextId';
  }
}
