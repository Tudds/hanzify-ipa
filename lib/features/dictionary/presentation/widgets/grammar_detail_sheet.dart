import 'package:flutter/material.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/audio/audio_urls.dart';
import '../../domain/grammar_item.dart';

class GrammarDetailSheet extends StatelessWidget {
  const GrammarDetailSheet({
    super.key,
    required this.item,
    this.scrollController,
  });

  final GrammarItem item;
  final ScrollController? scrollController;

  static Future<void> show(BuildContext context, GrammarItem item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => GrammarDetailSheet(
          item: item,
          scrollController: controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'HSK ${item.level}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _FormulaCard(parts: item.formulaParts, fallback: item.structure),
                const SizedBox(height: 16),
                Text(
                  item.explanation,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                if (item.usages.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Cách dùng',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  for (final u in item.usages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (u.icon.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8, top: 2),
                              child: Text(
                                u.icon,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (u.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      u.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                if (item.examples.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Ví dụ',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < item.examples.length; i++)
                    _ExampleTile(
                      example: item.examples[i],
                      audioUrl: AudioUrls.forGrammarExample(item.id, i),
                    ),
                ],
                if (item.commonMistakes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Lỗi thường gặp',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  for (final m in item.commonMistakes)
                    _MistakeTile(mistake: m),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaCard extends StatelessWidget {
  const _FormulaCard({required this.parts, required this.fallback});

  final List<GrammarFormulaPart> parts;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: parts.isEmpty
          ? Text(
              fallback,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final part in parts)
                  Text(
                    part.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: part.isHighlighted
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: part.isHighlighted
                          ? colors.primary
                          : colors.onSurface,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({required this.example, required this.audioUrl});

  final GrammarExample example;
  final String audioUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  example.zh,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
                if (example.pinyin.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    example.pinyin,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (example.vi.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    example.vi,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AudioPlayButton(url: audioUrl, size: 22),
        ],
      ),
    );
  }
}

class _MistakeTile extends StatelessWidget {
  const _MistakeTile({required this.mistake});

  final GrammarMistake mistake;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mistake.wrong,
            style: TextStyle(
              fontSize: 15,
              color: colors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mistake.right,
            style: TextStyle(
              fontSize: 15,
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (mistake.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              mistake.note,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
