import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/audio/audio_player_service.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/learning/learning_widgets.dart';
import '../../domain/short_feed_item.dart';

class ShortDialogueView extends ConsumerStatefulWidget {
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
  ConsumerState<ShortDialogueView> createState() => _ShortDialogueViewState();
}

class _ShortDialogueViewState extends ConsumerState<ShortDialogueView> {
  Timer? _lineRevealTimer;
  StreamSubscription<Duration>? _positionSub;
  var _visibleLineCount = 0;
  var _showPinyin = false;
  var _showMeaning = false;
  var _activeLineIndex = -1;
  List<GlobalKey> _lineKeys = const [];

  bool get _synced => widget.payload.hasSyncedSubtitles;

  @override
  void initState() {
    super.initState();
    _rebuildLineKeys();
    _reset();
  }

  @override
  void didUpdateWidget(covariant ShortDialogueView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payload != widget.payload ||
        oldWidget.active != widget.active ||
        oldWidget.performance != widget.performance) {
      if (oldWidget.payload != widget.payload) _rebuildLineKeys();
      _reset();
    }
  }

  @override
  void dispose() {
    _lineRevealTimer?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  void _rebuildLineKeys() {
    _lineKeys = List.generate(
      widget.payload.lines.length,
      (_) => GlobalKey(),
      growable: false,
    );
  }

  void _reset() {
    _lineRevealTimer?.cancel();
    _positionSub?.cancel();
    _positionSub = null;
    _activeLineIndex = -1;

    if (_synced) {
      // Phụ đề chạy theo audio: hiện hết dòng, highlight dòng đang đọc.
      _visibleLineCount = widget.payload.lines.length;
      if (widget.active) _listenPosition();
      return;
    }

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

  void _listenPosition() {
    final player = ref.read(audioPlayerProvider);
    _positionSub = player.positionStream.listen((position) {
      if (!mounted) return;
      if (player.currentUrl != widget.payload.audioUrl) {
        if (_activeLineIndex != -1) setState(() => _activeLineIndex = -1);
        return;
      }
      final ms = position.inMilliseconds;
      final lines = widget.payload.lines;
      final index = lines.indexWhere(
        (line) =>
            line.startMs != null &&
            line.endMs != null &&
            ms >= line.startMs! &&
            ms < line.endMs!,
      );
      if (index != _activeLineIndex) {
        setState(() => _activeLineIndex = index);
        if (index >= 0) _ensureVisible(index);
      }
    });
  }

  void _ensureVisible(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || index < 0 || index >= _lineKeys.length) return;
      final ctx = _lineKeys[index].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: MotionTokens.medium,
        alignment: 0.4,
        curve: Curves.easeInOut,
      );
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
          final isActive = _synced && index == _activeLineIndex;
          final bubble = LearningDialogueBubble(
            speakerLabel: line.speaker,
            speakerInitial: line.speaker,
            hanzi: line.hanzi,
            pinyin: line.pinyin,
            meaning: line.vi,
            audioUrl: _synced ? null : line.audioUrl,
            isSelf: index.isOdd,
            showPinyin: _showPinyin || isActive,
            showMeaning: _showMeaning,
            maxWidth: bubbleMaxWidth,
          );

          Widget content = bubble;
          if (_synced) {
            // Highlight dòng đang đọc, làm mờ nhẹ dòng còn lại.
            content = AnimatedOpacity(
              duration: MotionTokens.fast,
              opacity: _activeLineIndex < 0 || isActive ? 1.0 : 0.5,
              child: AnimatedContainer(
                duration: MotionTokens.fast,
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  color: isActive
                      ? context.colors.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: bubble,
              ),
            );
          }

          content = KeyedSubtree(key: _lineKeys[index], child: content);

          if (widget.performance || !widget.active || _synced) return content;
          return content
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
            if (_synced)
              Row(
                children: [
                  AudioPlayButton(
                    url: payload.audioUrl,
                    tooltip: 'Nghe hội thoại',
                    size: 26,
                  ),
                  const SizedBox(width: 6),
                  Text('Nghe & xem phụ đề', style: textTheme.bodyMedium),
                ],
              ),
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
