import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return GenUiChatState(
      messages: [
        GenUiChatMessage(
          id: _id(),
          role: ChatMessageRole.assistant,
          blocks: const [
            ChatBubbleBlock(
              'Chào bạn, mình là Chat GenUI local. Mình có thể tra từ, giải thích ngữ pháp và tạo quiz nhanh từ dữ liệu offline.',
            ),
            SuggestionActionsBlock([
              GenUiSuggestionAction(label: 'Tra từ', prompt: 'Tra từ 学习'),
              GenUiSuggestionAction(
                label: 'Tạo quiz',
                prompt: 'Tạo quiz HSK 2',
              ),
              GenUiSuggestionAction(
                label: 'Hội thoại',
                prompt: 'Cho mình hội thoại mẫu',
              ),
            ]),
          ],
        ),
      ],
    );
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
