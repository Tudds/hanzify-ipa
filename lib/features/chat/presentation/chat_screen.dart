import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/performance_provider.dart';
import '../../../core/widgets/hanzify_haptic.dart';
import '../../../core/widgets/sliver_page_scaffold.dart';
import '../application/chat_controller.dart';
import '../domain/gen_ui_chat.dart';
import 'widgets/dictation_block_view.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(genUiChatControllerProvider);
    return chat.when(
      loading: () => const SliverPageScaffold(
        title: 'Chat',
        subtitle: 'GenUI local với từ vựng, ngữ pháp và quiz.',
        headerAssetPath: 'assets/images/gen_header_chat.svg',
        slivers: [
          SliverStateMessage(
            icon: Icons.forum_rounded,
            title: 'Đang mở chat',
            message: 'Chuẩn bị GenUI local...',
            illustrationAssetPath: 'assets/images/gen_chat_empty.svg',
          ),
        ],
      ),
      error: (error, _) => SliverPageScaffold(
        title: 'Chat',
        subtitle: 'GenUI local với từ vựng, ngữ pháp và quiz.',
        headerAssetPath: 'assets/images/gen_header_chat.svg',
        slivers: [
          SliverStateMessage(
            icon: Icons.error_outline_rounded,
            title: 'Không phản hồi được',
            message: '$error',
          ),
          SliverToBoxAdapter(child: _Composer(onSend: _send)),
        ],
      ),
      data: (state) => SliverPageScaffold(
        title: 'Chat',
        subtitle: 'GenUI local trước, LLM remote có thể cắm sau.',
        headerAssetPath: 'assets/images/gen_header_chat.svg',
        slivers: [
          SliverList.builder(
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return _MessageView(message: message, onSuggestion: _send)
                  .animate(autoPlay: !readPerformance(ref))
                  .fadeIn(duration: 180.ms, delay: (index * 40).ms)
                  .slideY(begin: 0.03, end: 0, duration: 220.ms);
            },
          ),
          if (state.isResponding)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: _TypingIndicator(),
              ),
            ),
          SliverToBoxAdapter(child: _Composer(onSend: _send)),
        ],
      ),
    );
  }

  void _send(String prompt) {
    final text = prompt.trim();
    if (text.isEmpty) return;
    HanzifyHaptic.selection();
    ref.read(genUiChatControllerProvider.notifier).sendPrompt(text);
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message, required this.onSuggestion});

  final GenUiChatMessage message;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    if (message.role == ChatMessageRole.user) {
      return _UserBubble(text: message.text);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final block in message.blocks)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BlockView(block: block, onSuggestion: onSuggestion),
            ),
        ],
      ),
    );
  }
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block, required this.onSuggestion});

  final GenUiBlock block;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      ChatBubbleBlock(:final text) => _AssistantBubble(text: text),
      VocabCardBlock() => _VocabGenUiCard(block: block as VocabCardBlock),
      GrammarCardBlock() => _GrammarGenUiCard(block: block as GrammarCardBlock),
      QuickQuizBlock() => _QuickQuiz(block: block as QuickQuizBlock),
      SentenceArrangeBlock() => _SentenceArrangePrompt(
        block: block as SentenceArrangeBlock,
      ),
      DictationBlock() => DictationBlockView(block: block as DictationBlock),
      SuggestionActionsBlock(:final actions) => _SuggestionActions(
        actions: actions,
        onSuggestion: onSuggestion,
      ),
    };
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.fromLTRB(64, 6, 20, 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Text(text),
    );
  }
}

class _VocabGenUiCard extends StatelessWidget {
  const _VocabGenUiCard({required this.block});

  final VocabCardBlock block;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _GenUiSurface(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'H${block.level}',
              style: TextStyle(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.hanzi,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (block.pinyin.isNotEmpty)
                  Text(
                    block.pinyin,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (block.vi.isNotEmpty)
                  Text(
                    block.vi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GrammarGenUiCard extends StatelessWidget {
  const _GrammarGenUiCard({required this.block});

  final GrammarCardBlock block;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _GenUiSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: colors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text('HSK ${block.level}'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            block.structure,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            block.explanation,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _QuickQuiz extends StatefulWidget {
  const _QuickQuiz({required this.block});

  final QuickQuizBlock block;

  @override
  State<_QuickQuiz> createState() => _QuickQuizState();
}

class _QuickQuizState extends State<_QuickQuiz> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final picked = _picked;
    return _GenUiSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz_rounded, color: colors.tertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.block.prompt,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final choice in widget.block.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: picked == null
                    ? () {
                        HanzifyHaptic.selection();
                        setState(() => _picked = choice);
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _choiceColor(colors, choice, picked),
                  side: BorderSide(color: _choiceColor(colors, choice, picked)),
                  minimumSize: const Size.fromHeight(44),
                ),
                child: Text(choice),
              ),
            ),
          if (picked != null)
            Text(
              picked == widget.block.answer
                  ? 'Đúng rồi. ${widget.block.explanation}'
                  : 'Đáp án đúng: ${widget.block.answer}. ${widget.block.explanation}',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Color _choiceColor(ColorScheme colors, String choice, String? picked) {
    if (picked == null) return colors.outline;
    if (choice == widget.block.answer) return colors.primary;
    if (choice == picked) return colors.error;
    return colors.outlineVariant;
  }
}

class _SentenceArrangePrompt extends StatefulWidget {
  const _SentenceArrangePrompt({required this.block});

  final SentenceArrangeBlock block;

  @override
  State<_SentenceArrangePrompt> createState() => _SentenceArrangePromptState();
}

class _SentenceArrangePromptState extends State<_SentenceArrangePrompt> {
  late final List<String> _bank = List<String>.of(widget.block.tokens);
  final List<String> _placed = [];
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final attempt = _placed.join();
    final correct = attempt == widget.block.answer;
    return _GenUiSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.reorder_rounded, color: colors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sắp xếp câu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (widget.block.translation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(widget.block.translation),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _checked
                    ? (correct ? colors.primary : colors.error)
                    : colors.outlineVariant,
              ),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < _placed.length; i++)
                  InputChip(
                    label: Text(_placed[i]),
                    onDeleted: _checked
                        ? null
                        : () {
                            setState(() {
                              _bank.add(_placed.removeAt(i));
                            });
                          },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final token in _bank)
                ActionChip(
                  label: Text(token),
                  onPressed: _checked
                      ? null
                      : () {
                          HanzifyHaptic.selection();
                          setState(() {
                            _bank.remove(token);
                            _placed.add(token);
                          });
                        },
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _placed.isEmpty || _checked
                ? null
                : () {
                    HanzifyHaptic.selection();
                    setState(() => _checked = true);
                  },
            child: const Text('Kiểm tra'),
          ),
          if (_checked)
            Text(
              correct ? 'Câu đúng.' : 'Đáp án: ${widget.block.answer}',
              style: TextStyle(
                color: correct ? colors.primary : colors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionActions extends StatelessWidget {
  const _SuggestionActions({required this.actions, required this.onSuggestion});

  final List<GenUiSuggestionAction> actions;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          ActionChip(
            avatar: const Icon(Icons.bolt_rounded, size: 18),
            label: Text(action.label),
            onPressed: () => onSuggestion(action.prompt),
          ),
      ],
    );
  }
}

class _Composer extends ConsumerStatefulWidget {
  const _Composer({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: widget.onSend,
                decoration: const InputDecoration(
                  hintText: 'Hỏi về từ vựng, ngữ pháp hoặc quiz...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(16, 14, 10, 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 7),
              child: IconButton.filled(
                tooltip: 'Gửi',
                icon: const Icon(Icons.send_rounded),
                onPressed: () {
                  final text = _controller.text;
                  _controller.clear();
                  widget.onSend(text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends ConsumerWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final performance = readPerformance(ref);

    if (performance) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '● ● ●',
            style: TextStyle(color: colors.primary, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Text(
            'Đang dựng GenUI...',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
        ],
      );
    }

    Widget buildDot(int index) {
      return Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
        ),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -5,
            duration: 380.ms,
            delay: (index * 130).ms,
            curve: Curves.easeInOutQuad,
          );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDot(0),
          const SizedBox(width: 4),
          buildDot(1),
          const SizedBox(width: 4),
          buildDot(2),
          const SizedBox(width: 12),
          Text(
            'Đang dựng GenUI...',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenUiSurface extends StatelessWidget {
  const _GenUiSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: child,
    );
  }
}
