import 'package:flutter/material.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/audio/audio_urls.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/pos_label.dart';
import '../../../character/presentation/widgets/stroke_order_widget.dart';
import '../../domain/vocab_item.dart';
import 'vocab_meaning_views.dart';

class VocabDetailSheet extends StatefulWidget {
  const VocabDetailSheet({
    super.key,
    required this.item,
    this.scrollController,
  });

  final VocabItem item;
  final ScrollController? scrollController;

  static Future<void> show(BuildContext context, VocabItem item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => VocabDetailSheet(
          item: item,
          scrollController: controller,
        ),
      ),
    );
  }

  @override
  State<VocabDetailSheet> createState() => _VocabDetailSheetState();
}

class _VocabDetailSheetState extends State<VocabDetailSheet> {
  late int _activeChar = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final item = widget.item;
    final chars = item.characters.isNotEmpty
        ? item.characters
        : [item.hanzi];

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
          _Handle(),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.hanzi,
                            style: AppTypography.hanziDisplay(
                              size: 56,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.pinyin,
                            style: AppTypography.pinyin(
                              size: 22,
                              color: colors.primary,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AudioPlayButton(
                      url: AudioUrls.forVocab(item.id),
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Chip(
                      label: Text('HSK ${item.level}'),
                      backgroundColor: colors.primaryContainer,
                      side: BorderSide.none,
                    ),
                    if (item.wordType.isNotEmpty)
                      Chip(
                        label: Text(PosLabel.vietnamese(item.wordType)),
                        side: BorderSide.none,
                        backgroundColor: PosLabel.color(
                          item.wordType,
                          colors,
                        ).withValues(alpha: 0.14),
                        labelStyle: TextStyle(
                          color: PosLabel.color(item.wordType, colors),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    for (final tag in item.tags.take(4))
                      Chip(
                        label: Text(tag),
                        side: BorderSide.none,
                        backgroundColor: colors.surfaceContainerHigh,
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                if (chars.length > 1) ...[
                  Text(
                    'Các ký tự',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var i = 0; i < chars.length; i++)
                        ChoiceChip(
                          selected: _activeChar == i,
                          label: Text(
                            chars[i],
                            style: const TextStyle(fontSize: 18),
                          ),
                          onSelected: (_) => setState(() => _activeChar = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Center(
                  child: StrokeOrderWidget(
                    character: chars[_activeChar],
                    size: 240,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nghĩa',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                for (final group in groupMeaningsByPos(item.meanings))
                  MeaningPosGroupView(pos: group.pos, items: group.items),
                if (item.examples.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Ví dụ',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < item.examples.length; i++)
                    VocabExampleTile(
                      example: item.examples[i],
                      audioUrl: AudioUrls.forVocabExample(item.id, i),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: colors.outlineVariant,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
