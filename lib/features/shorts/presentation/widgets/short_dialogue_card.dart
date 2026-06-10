import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/widgets/learning/learning_widgets.dart';
import '../../domain/short_feed_item.dart';

class ShortDialogueView extends StatefulWidget {
  const ShortDialogueView({
    super.key,
    required this.payload,
    required this.active,
    required this.performance,
  });

  final ShortDialogue payload;
  final bool active;
  final bool performance;

  @override
  State<ShortDialogueView> createState() => _ShortDialogueViewState();
}

class _ShortDialogueViewState extends State<ShortDialogueView> {
  Timer? _lineRevealTimer;
  var _visibleLineCount = 0;
  var _showPinyin = false;
  var _showMeaning = false;

  @override
  void initState() {
    super.initState();
    _resetLineReveal();
  }

  @override
  void didUpdateWidget(covariant ShortDialogueView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payload != widget.payload ||
        oldWidget.active != widget.active ||
        oldWidget.performance != widget.performance) {
      _resetLineReveal();
    }
  }

  @override
  void dispose() {
    _lineRevealTimer?.cancel();
    super.dispose();
  }

  void _resetLineReveal() {
    _lineRevealTimer?.cancel();
    if (widget.performance) {
      _visibleLineCount = widget.payload.lines.length;
      return;
    }
    _visibleLineCount = widget.payload.lines.isEmpty ? 0 : 1;
    if (!widget.active || widget.payload.lines.length <= 1) return;
    _lineRevealTimer = Timer.periodic(const Duration(milliseconds: 700), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_visibleLineCount >= widget.payload.lines.length) {
        timer.cancel();
        return;
      }
      setState(() => _visibleLineCount += 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textTheme = Theme.of(context).textTheme;
        final fallbackWidth = MediaQuery.sizeOf(context).width;
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : fallbackWidth;
        final compact = width < 430;
        final bubbleMaxWidth = (width * (compact ? 0.86 : 0.78))
            .clamp(240.0, 420.0)
            .toDouble();
        final sectionGap = (width * 0.045).clamp(14.0, 20.0).toDouble();
        final payload = widget.payload;
        final visibleLines = payload.lines.take(_visibleLineCount).toList();

        Widget buildBubble(int index) {
          final line = visibleLines[index];
          final bubble = LearningDialogueBubble(
            speakerLabel: line.speaker,
            speakerInitial: line.speaker,
            hanzi: line.hanzi,
            pinyin: line.pinyin,
            meaning: line.vi,
            audioUrl: line.audioUrl,
            isSelf: index.isOdd,
            showPinyin: _showPinyin,
            showMeaning: _showMeaning,
            maxWidth: bubbleMaxWidth,
          );
          if (widget.performance || !widget.active) return bubble;
          return bubble
              .animate()
              .fadeIn(duration: MotionTokens.fast)
              .slideY(begin: 0.05, end: 0, duration: MotionTokens.medium);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              payload.title,
              style: (compact ? textTheme.titleLarge : textTheme.headlineSmall)
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(payload.context, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                FilterChip(
                  selected: _showPinyin,
                  showCheckmark: false,
                  avatar: const Icon(
                    Icons.record_voice_over_outlined,
                    size: 16,
                  ),
                  label: const Text('Pinyin'),
                  onSelected: (_) {
                    setState(() => _showPinyin = !_showPinyin);
                  },
                ),
                FilterChip(
                  selected: _showMeaning,
                  showCheckmark: false,
                  avatar: const Icon(Icons.translate_outlined, size: 16),
                  label: const Text('Nghĩa'),
                  onSelected: (_) {
                    setState(() => _showMeaning = !_showMeaning);
                  },
                ),
              ],
            ),
            SizedBox(height: sectionGap),
            for (var i = 0; i < visibleLines.length; i++) buildBubble(i),
          ],
        );
      },
    );
  }
}
