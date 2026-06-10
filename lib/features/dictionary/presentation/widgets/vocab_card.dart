import 'package:flutter/material.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/audio/audio_urls.dart';
import '../../../../core/utils/pos_label.dart';
import '../../../../core/widgets/hanzify_haptic.dart';
import '../../domain/vocab_item.dart';

class VocabCard extends StatelessWidget {
  const VocabCard({super.key, required this.item, required this.onTap});

  final VocabItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        HanzifyHaptic.selection();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            _LevelBadge(level: item.level),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.hanzi,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.pinyin,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.meanings.isNotEmpty &&
                          item.meanings.first.pos.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _PosChip(pos: item.meanings.first.pos),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.viShort,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AudioPlayButton(url: AudioUrls.forVocab(item.id), size: 26),
          ],
        ),
      ),
    );
  }
}

class _PosChip extends StatelessWidget {
  const _PosChip({required this.pos});

  final String pos;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = PosLabel.color(pos, scheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tint.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        PosLabel.short(pos),
        style: TextStyle(
          color: tint,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'H$level',
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
