import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/audio/audio_player_service.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/typography.dart';
import '../../domain/short_feed_item.dart';
import 'short_context_cards.dart' show ShowShortVocabDetail;

/// Card đọc: truyện ngắn / bài viết / bài thơ song ngữ, tùy chọn kèm audio +
/// phụ đề chạy theo audio (sub sync).
class ShortReaderView extends ConsumerStatefulWidget {
  const ShortReaderView({
    super.key,
    required this.payload,
    required this.active,
    required this.performance,
    required this.onShowVocabDetail,
  });

  final ShortReader payload;
  final bool active;
  final bool performance;
  final ShowShortVocabDetail onShowVocabDetail;

  @override
  ConsumerState<ShortReaderView> createState() => _ShortReaderViewState();
}

class _ShortReaderViewState extends ConsumerState<ShortReaderView> {
  StreamSubscription<Duration>? _positionSub;
  var _showPinyin = false;
  var _showMeaning = false;
  var _activeIndex = -1;
  List<GlobalKey> _lineKeys = const [];

  bool get _synced => widget.payload.hasSyncedSubtitles;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void didUpdateWidget(covariant ShortReaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payload != widget.payload ||
        oldWidget.active != widget.active) {
      _rebuild();
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  void _rebuild() {
    _positionSub?.cancel();
    _positionSub = null;
    _activeIndex = -1;
    _lineKeys = List.generate(
      widget.payload.paragraphs.length,
      (_) => GlobalKey(),
      growable: false,
    );
    if (_synced && widget.active) _listenPosition();
  }

  void _listenPosition() {
    final player = ref.read(audioPlayerProvider);
    _positionSub = player.positionStream.listen((position) {
      if (!mounted) return;
      if (player.currentUrl != widget.payload.audioUrl) {
        if (_activeIndex != -1) setState(() => _activeIndex = -1);
        return;
      }
      final ms = position.inMilliseconds;
      final lines = widget.payload.paragraphs;
      final index = lines.indexWhere(
        (line) =>
            line.startMs != null &&
            line.endMs != null &&
            ms >= line.startMs! &&
            ms < line.endMs!,
      );
      if (index != _activeIndex) {
        setState(() => _activeIndex = index);
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
    final text = context.text;
    final colors = context.colors;
    final payload = widget.payload;
    final isPoem = payload.kind == ShortReaderKind.poem;
    final align = isPoem ? TextAlign.center : TextAlign.start;
    final crossAxis = isPoem
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        _KindBadge(kind: payload.kind),
        const SizedBox(height: AppSpacing.md),
        if (payload.titleZh.isNotEmpty)
          Text(
            payload.titleZh,
            textAlign: align,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        if (payload.title.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            payload.title,
            textAlign: align,
            style: text.titleMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            if (payload.audioUrl != null && payload.audioUrl!.isNotEmpty) ...[
              AudioPlayButton(
                url: payload.audioUrl,
                tooltip: 'Nghe bài',
                size: 26,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            _Toggle(
              label: 'Pinyin',
              selected: _showPinyin,
              onChanged: () => setState(() => _showPinyin = !_showPinyin),
            ),
            const SizedBox(width: AppSpacing.sm),
            _Toggle(
              label: 'Nghĩa',
              selected: _showMeaning,
              onChanged: () => setState(() => _showMeaning = !_showMeaning),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < payload.paragraphs.length; i++)
          _ParagraphView(
            key: _lineKeys[i],
            line: payload.paragraphs[i],
            align: align,
            showPinyin: _showPinyin || (_synced && i == _activeIndex),
            showMeaning: _showMeaning,
            active: _synced && i == _activeIndex,
            dimmed: _synced && _activeIndex >= 0 && i != _activeIndex,
            performance: widget.performance,
          ),
        if (payload.glossary.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Từ vựng',
            style: text.labelLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final entry in payload.glossary)
                _GlossaryChip(
                  entry: entry,
                  onShowVocabDetail: widget.onShowVocabDetail,
                ),
            ],
          ),
        ],
        if (payload.sourceName != null && payload.sourceName!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nguồn: ${payload.sourceName}',
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _ParagraphView extends StatelessWidget {
  const _ParagraphView({
    super.key,
    required this.line,
    required this.align,
    required this.showPinyin,
    required this.showMeaning,
    required this.active,
    required this.dimmed,
    required this.performance,
  });

  final ReaderLine line;
  final TextAlign align;
  final bool showPinyin;
  final bool showMeaning;
  final bool active;
  final bool dimmed;
  final bool performance;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final column = Column(
      crossAxisAlignment: align == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (showPinyin && line.pinyin.isNotEmpty)
          Text(
            line.pinyin,
            textAlign: align,
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        Text(
          line.zh,
          textAlign: align,
          style: text.titleLarge?.copyWith(height: 1.5),
        ),
        if (showMeaning && line.vi.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              line.vi,
              textAlign: align,
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
      ],
    );
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadii.button),
      color: active
          ? colors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
    );
    const margin = EdgeInsets.only(bottom: AppSpacing.md);
    const padding = EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    );
    final opacity = dimmed ? 0.5 : 1.0;

    // Performance mode: giữ highlight tĩnh, bỏ transition.
    if (performance) {
      return Opacity(
        opacity: opacity,
        child: Container(
          margin: margin,
          padding: padding,
          decoration: decoration,
          child: column,
        ),
      );
    }

    return AnimatedOpacity(
      duration: MotionTokens.fast,
      opacity: opacity,
      child: AnimatedContainer(
        duration: MotionTokens.fast,
        margin: margin,
        padding: padding,
        decoration: decoration,
        child: column,
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.kind});

  final ShortReaderKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (label, icon) = switch (kind) {
      ShortReaderKind.story => ('Truyện ngắn', Icons.auto_stories_outlined),
      ShortReaderKind.article => ('Bài viết', Icons.article_outlined),
      ShortReaderKind.poem => ('Bài thơ', Icons.format_quote_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onSecondaryContainer),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.text.labelMedium?.copyWith(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      label: Text(label),
      onSelected: (_) => onChanged(),
    );
  }
}

class _GlossaryChip extends StatelessWidget {
  const _GlossaryChip({required this.entry, required this.onShowVocabDetail});

  final ShortGlossaryEntry entry;
  final ShowShortVocabDetail onShowVocabDetail;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final hasDetail =
        entry.targetVocabId != null && entry.targetVocabId!.isNotEmpty;
    final chip = Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.pinyin.isEmpty
                ? entry.hanzi
                : '${entry.hanzi} · ${entry.pinyin}',
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (entry.vi.isNotEmpty) Text(entry.vi, style: text.bodySmall),
        ],
      ),
    );
    if (!hasDetail) return chip;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.chip),
      onTap: () => onShowVocabDetail(entry.targetVocabId!),
      child: chip,
    );
  }
}
