import 'package:flutter/material.dart';

import '../../audio/audio_play_button.dart';

class LearningDialogueBubble extends StatelessWidget {
  const LearningDialogueBubble({
    super.key,
    required this.speakerLabel,
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
    required this.isSelf,
    required this.showPinyin,
    required this.showMeaning,
    this.audioUrl,
    this.speakerInitial,
    this.speakerColor,
    this.onTap,
    this.hanziChild,
    this.hiddenMeaningLabel,
    this.maxWidth = 320,
  });

  final String speakerLabel;
  final String hanzi;
  final String pinyin;
  final String meaning;
  final bool isSelf;
  final bool showPinyin;
  final bool showMeaning;
  final String? audioUrl;
  final String? speakerInitial;
  final Color? speakerColor;
  final VoidCallback? onTap;
  final Widget? hanziChild;
  final String? hiddenMeaningLabel;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avatarColor = speakerColor ?? colors.primary;
    final hasAvatar = speakerInitial?.trim().isNotEmpty ?? false;
    final foreground = isSelf ? colors.onPrimaryContainer : colors.onSurface;
    final bubble = _LearningDialogueBubbleContent(
      hanzi: hanzi,
      pinyin: pinyin,
      meaning: meaning,
      showPinyin: showPinyin,
      showMeaning: showMeaning,
      audioUrl: audioUrl,
      onTap: onTap,
      hanziChild: hanziChild,
      hiddenMeaningLabel: hiddenMeaningLabel,
      background: isSelf
          ? colors.primaryContainer
          : colors.surfaceContainerHigh,
      foreground: foreground,
    );
    final bubbleSlot = Flexible(
      child: Align(
        alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: bubble,
        ),
      ),
    );
    final avatar = _LearningDialogueAvatar(
      initial: speakerInitial ?? '',
      color: avatarColor,
    );
    final children = isSelf
        ? [
            bubbleSlot,
            if (hasAvatar) ...[const SizedBox(width: 8), avatar],
          ]
        : [
            if (hasAvatar) ...[avatar, const SizedBox(width: 8)],
            bubbleSlot,
          ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: isSelf
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: !isSelf && hasAvatar ? 40 : 0,
              right: isSelf && hasAvatar ? 40 : 0,
              bottom: 2,
            ),
            child: Text(
              speakerLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: avatarColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ],
      ),
    );
  }
}

class _LearningDialogueAvatar extends StatelessWidget {
  const _LearningDialogueAvatar({required this.initial, required this.color});

  final String initial;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _LearningDialogueBubbleContent extends StatelessWidget {
  const _LearningDialogueBubbleContent({
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
    required this.showPinyin,
    required this.showMeaning,
    required this.background,
    required this.foreground,
    this.audioUrl,
    this.onTap,
    this.hanziChild,
    this.hiddenMeaningLabel,
  });

  final String hanzi;
  final String pinyin;
  final String meaning;
  final bool showPinyin;
  final bool showMeaning;
  final Color background;
  final Color foreground;
  final String? audioUrl;
  final VoidCallback? onTap;
  final Widget? hanziChild;
  final String? hiddenMeaningLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(color: foreground.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    hanziChild ??
                    Text(
                      hanzi,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                        height: 1.18,
                      ),
                    ),
              ),
              if (audioUrl != null) ...[
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: AudioPlayButton(
                    url: audioUrl,
                    size: 22,
                    color: foreground,
                    tooltip: 'Nghe câu này',
                  ),
                ),
              ],
            ],
          ),
          if (showPinyin && pinyin.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              pinyin,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foreground.withValues(alpha: 0.75),
              ),
            ),
          ],
          if (showMeaning && meaning.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                meaning,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foreground.withValues(alpha: 0.85),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else if (hiddenMeaningLabel != null && meaning.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                hiddenMeaningLabel!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.55),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, borderRadius: radius, child: content);
  }
}
