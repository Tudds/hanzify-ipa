import 'package:flutter/material.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/typography.dart';
import '../../domain/short_feed_item.dart';
import 'short_context_cards.dart' show ShowShortVocabDetail;

/// Card hình ảnh: một vật / khung cảnh kèm câu mô tả tiếng Hán và nhãn từ vựng.
class ShortSceneView extends StatelessWidget {
  const ShortSceneView({
    super.key,
    required this.payload,
    required this.onShowVocabDetail,
  });

  final ShortScene payload;
  final ShowShortVocabDetail onShowVocabDetail;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = MediaQuery.sizeOf(context).width;
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : fallbackWidth;
        final compact = width < 430;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _SceneImage(url: payload.imageUrl),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    payload.captionHanzi,
                    style:
                        (compact ? text.headlineSmall : text.displaySmall)
                            ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                if (payload.audioUrl != null && payload.audioUrl!.isNotEmpty)
                  AudioPlayButton(url: payload.audioUrl, size: 26),
              ],
            ),
            if (payload.captionPinyin.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                payload.captionPinyin,
                style: text.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            if (payload.captionVi.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(payload.captionVi, style: text.titleMedium),
            ],
            if (payload.labels.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Từ vựng trong ảnh',
                style: text.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final label in payload.labels)
                    _LabelChip(
                      label: label,
                      onShowVocabDetail: onShowVocabDetail,
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SceneImage extends StatelessWidget {
  const _SceneImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (url.isEmpty) {
      return ColoredBox(color: colors.surfaceContainerHighest);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(
          color: colors.surfaceContainerHighest,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stack) => ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Icon(
          Icons.broken_image_outlined,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.label, required this.onShowVocabDetail});

  final ShortGlossaryEntry label;
  final ShowShortVocabDetail onShowVocabDetail;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final hasDetail =
        label.targetVocabId != null && label.targetVocabId!.isNotEmpty;
    final chip = Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.hanzi,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (label.vi.isNotEmpty) Text(label.vi, style: text.bodySmall),
        ],
      ),
    );
    if (!hasDetail) return chip;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.chip),
      onTap: () => onShowVocabDetail(label.targetVocabId!),
      child: chip,
    );
  }
}
