import 'package:flutter/material.dart';

import '../../../../core/widgets/hanzify_haptic.dart';
import '../../domain/grammar_item.dart';

class GrammarCard extends StatelessWidget {
  const GrammarCard({super.key, required this.item, required this.onTap});

  final GrammarItem item;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Formula(parts: item.formulaParts, fallback: item.structure),
            if (item.examples.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                item.examples.first.zh,
                style: TextStyle(
                  fontSize: 15,
                  color: colors.onSurface,
                ),
              ),
              if (item.examples.first.vi.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    item.examples.first.vi,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Formula extends StatelessWidget {
  const _Formula({required this.parts, required this.fallback});

  final List<GrammarFormulaPart> parts;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (parts.isEmpty) {
      return Text(
        fallback,
        style: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      );
    }
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final part in parts)
          Text(
            part.text,
            style: TextStyle(
              fontWeight: part.isHighlighted
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: part.isHighlighted
                  ? colors.primary
                  : colors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}
