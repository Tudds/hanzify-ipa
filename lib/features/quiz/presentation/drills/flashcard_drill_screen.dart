import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/audio/audio_urls.dart';
import '../../../../core/providers/performance_provider.dart';
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
  List<VocabItem>? _cards;
  int _index = 0;
  int _score = 0;
  bool _flipped = false;
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    final asyncPool = ref.watch(quizPoolProvider);
    return asyncPool.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Lỗi: $e'))),
      data: (pool) {
        _cards ??= pool.sample(level: widget.level, count: 8).vocab;
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
                  _cards = pool.sample(level: widget.level, count: 8).vocab;
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
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _grade(false),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Chưa nhớ'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.error,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _grade(true),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Nhớ rõ'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
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

  void _grade(bool correct) {
    HanzifyHaptic.selection();
    final cards = _cards!;
    setState(() {
      if (correct) _score++;
      if (_index + 1 >= cards.length) {
        _finished = true;
      } else {
        _index++;
        _flipped = false;
      }
    });
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
