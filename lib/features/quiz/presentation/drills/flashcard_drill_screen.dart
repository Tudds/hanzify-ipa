import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/audio/audio_urls.dart';
import '../../../../core/constants/hsk_levels.dart';
import '../../../../core/learning/application/study_session_recorder.dart';
import '../../../../core/learning/domain/fsrs.dart';
import '../../../../core/providers/performance_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/hanzify_haptic.dart';
import '../../../dictionary/domain/vocab_item.dart';
import '../../../dictionary/presentation/widgets/vocab_meaning_views.dart';
import '../../application/quiz_pool.dart';
import '../widgets/drill_scaffold.dart';

class FlashcardDrillScreen extends ConsumerStatefulWidget {
  const FlashcardDrillScreen({super.key, required this.level});

  final int level;

  @override
  ConsumerState<FlashcardDrillScreen> createState() =>
      _FlashcardDrillScreenState();
}

class _FlashcardDrillScreenState extends ConsumerState<FlashcardDrillScreen> {
  late int _level = widget.level;
  List<VocabItem>? _cards;
  int _index = 0;
  int _score = 0;
  bool _flipped = false;
  bool _finished = false;

  void _changeLevel(int level) {
    if (level == _level) return;
    HanzifyHaptic.selection();
    // Đồng bộ lại level cho launcher Quiz (persist qua quizLevelProvider).
    ref.read(quizLevelProvider.notifier).set(level);
    setState(() {
      _level = level;
      _cards = null;
      _index = 0;
      _score = 0;
      _flipped = false;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncPool = ref.watch(quizPoolProvider);
    return asyncPool.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Lỗi: $e'))),
      data: (pool) {
        _cards ??= pool.sample(level: _level, count: 8).vocab;
        final cards = _cards!;
        if (cards.isEmpty) {
          return _emptyScaffold();
        }
        if (_finished) {
          return Scaffold(
            body: DrillSummary(
              score: _score,
              total: cards.length,
              onRestart: () {
                setState(() {
                  _cards = pool.sample(level: _level, count: 8).vocab;
                  _index = 0;
                  _score = 0;
                  _flipped = false;
                  _finished = false;
                });
              },
            ),
          );
        }
        return DrillScaffold(
          title: 'Flashcard',
          progress: _index / cards.length,
          score: _score,
          actions: [
            Center(child: _LevelChip(level: _level, onChanged: _changeLevel)),
          ],
          body: _buildCard(cards[_index]),
        );
      },
    );
  }

  Scaffold _emptyScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard')),
      body: const Center(child: Text('Chưa có từ vựng để luyện.')),
    );
  }

  Widget _buildCard(VocabItem item) {
    final colors = Theme.of(context).colorScheme;
    final performance = readPerformance(ref);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HanzifyHaptic.selection();
                setState(() => _flipped = !_flipped);
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.center,
                  children: [
                    ?currentChild,
                    ...previousChildren,
                  ],
                ),
                transitionBuilder: (child, anim) {
                  if (performance) {
                    return FadeTransition(opacity: anim, child: child);
                  }
                  final rotateAnim = Tween<double>(begin: math.pi, end: 0).animate(anim);
                  return AnimatedBuilder(
                    animation: rotateAnim,
                    child: child,
                    builder: (context, child) {
                      final isFront = child!.key.toString().contains('front');
                      // Front sweeps 0 -> pi (visible for the first half), back
                      // mirrors that as -rotateAnim so it lands face-on (angle 0,
                      // un-mirrored) when the flip completes instead of staying in
                      // the hidden hemisphere — which left the flipped card blank.
                      final angle = isFront ? rotateAnim.value : -rotateAnim.value;
                      final isBackHemisphere = math.cos(angle) <= 0;
                      if (isBackHemisphere) {
                        return const SizedBox.shrink();
                      }
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012) // perspective
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                  );
                },
                child: _flipped
                    ? _BackFace(
                        key: ValueKey('${item.id}-back'),
                        item: item,
                      )
                    : _FrontFace(
                        key: ValueKey('${item.id}-front'),
                        item: item,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _flipped
                ? Row(
                    key: const ValueKey('grades'),
                    children: [
                      _GradeButton(
                        label: 'Quên',
                        color: context.semantic.danger,
                        onTap: () => _grade(SrsRating.again),
                      ),
                      _GradeButton(
                        label: 'Khó',
                        color: context.semantic.warning,
                        onTap: () => _grade(SrsRating.hard),
                      ),
                      _GradeButton(
                        label: 'Được',
                        color: colors.primary,
                        onTap: () => _grade(SrsRating.good),
                      ),
                      _GradeButton(
                        label: 'Dễ',
                        color: context.semantic.success,
                        onTap: () => _grade(SrsRating.easy),
                      ),
                    ],
                  )
                : Container(
                    key: const ValueKey('hint'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Chạm vào thẻ để lật',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  )
                    .animate(
                      autoPlay: !performance,
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .fadeIn(duration: 600.ms),
          ),
        ],
      ),
    );
  }

  void _grade(SrsRating rating) {
    HanzifyHaptic.selection();
    final cards = _cards!;
    final item = cards[_index];
    ref
        .read(studySessionRecorderProvider)
        .record(targetType: 'vocab', targetId: item.id, rating: rating);
    setState(() {
      if (rating != SrsRating.again) _score++;
      if (_index + 1 >= cards.length) {
        _finished = true;
      } else {
        _index++;
        _flipped = false;
      }
    });
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton.tonal(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.18),
            foregroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level, required this.onChanged});

  final int level;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopupMenuButton<int>(
      initialValue: level,
      tooltip: 'Đổi cấp độ HSK',
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final lv in kHskLevels)
          PopupMenuItem(value: lv, child: Text('HSK $lv')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HSK $level',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _FrontFace extends StatelessWidget {
  const _FrontFace({super.key, required this.item});

  final VocabItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha:0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          item.hanzi,
          style: AppTypography.hanziDisplay(
            size: 92,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _BackFace extends StatelessWidget {
  const _BackFace({super.key, required this.item});

  final VocabItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: key,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Content can exceed the card when a word has several senses/examples, so
      // it scrolls; ConstrainedBox keeps it vertically centred when it's short.
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        item.hanzi,
                        style: AppTypography.hanziDisplay(
                          size: 48,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            item.pinyin,
                            textAlign: TextAlign.center,
                            style: AppTypography.pinyin(
                              size: 22,
                              color: colors.primary,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AudioPlayButton(
                          url: AudioUrls.forVocab(item.id),
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    for (final group in groupMeaningsByPos(item.meanings))
                      MeaningPosGroupView(pos: group.pos, items: group.items),
                    if (item.examples.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ví dụ',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
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
            ),
          );
        },
      ),
    );
  }
}
