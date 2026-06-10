import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/performance_provider.dart';
import '../../../../core/widgets/hanzify_haptic.dart';
import '../../../dictionary/domain/vocab_item.dart';
import '../../application/quiz_pool.dart';
import '../widgets/drill_scaffold.dart';

class _ClozeQuestion {
  const _ClozeQuestion({
    required this.fullSentence,
    required this.answer,
    required this.choices,
    required this.translation,
  });

  final String fullSentence;
  final String answer;
  final List<String> choices;
  final String translation;

  String get prompt => fullSentence.replaceFirst(answer, '____');
}

class ClozeDrillScreen extends ConsumerStatefulWidget {
  const ClozeDrillScreen({super.key, required this.level});

  final int level;

  @override
  ConsumerState<ClozeDrillScreen> createState() => _ClozeDrillScreenState();
}

class _ClozeDrillScreenState extends ConsumerState<ClozeDrillScreen> {
  List<_ClozeQuestion>? _questions;
  int _index = 0;
  int _score = 0;
  String? _picked;
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    final asyncPool = ref.watch(quizPoolProvider);
    return asyncPool.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Lỗi: $e'))),
      data: (pool) {
        _questions ??= _build(pool.vocab);
        final qs = _questions!;
        if (qs.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Điền từ')),
            body: const Center(child: Text('Không đủ dữ liệu để luyện.')),
          );
        }
        if (_finished) {
          return Scaffold(
            body: DrillSummary(
              score: _score,
              total: qs.length,
              onRestart: () {
                setState(() {
                  _questions = _build(pool.vocab);
                  _index = 0;
                  _score = 0;
                  _picked = null;
                  _finished = false;
                });
              },
            ),
          );
        }
        return DrillScaffold(
          title: 'Điền từ',
          progress: _index / qs.length,
          score: _score,
          body: _buildQuestion(qs[_index]),
        );
      },
    );
  }

  List<_ClozeQuestion> _build(List<VocabItem> vocab) {
    final pool = vocab
        .where(
          (v) =>
              v.level == widget.level &&
              v.examples.isNotEmpty &&
              v.examples.first.cn.contains(v.hanzi),
        )
        .toList();
    if (pool.length < 4) return const [];
    final rng = Random();
    pool.shuffle(rng);
    final questions = <_ClozeQuestion>[];
    for (final v in pool.take(8)) {
      final example = v.examples.first;
      final distractors =
          pool
              .where((other) => other.hanzi != v.hanzi)
              .map((other) => other.hanzi)
              .toList()
            ..shuffle(rng);
      final choices = <String>{v.hanzi, ...distractors.take(3)}.toList()
        ..shuffle(rng);
      if (choices.length < 4) continue;
      questions.add(
        _ClozeQuestion(
          fullSentence: example.cn,
          answer: v.hanzi,
          choices: choices,
          translation: example.vi,
        ),
      );
    }
    return questions;
  }

  Widget _buildQuestion(_ClozeQuestion q) {
    final colors = Theme.of(context).colorScheme;
    final performance = readPerformance(ref);
    final picked = _picked;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Điền từ thích hợp',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.prompt,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                    height: 1.4,
                  ),
                ),
                if (q.translation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    q.translation,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.4,
              children: [
                for (final choice in q.choices)
                  _ChoiceTile(
                    text: choice,
                    state: _stateOf(choice, q.answer, picked),
                    onTap: picked == null ? () => _pick(choice, q) : null,
                  ).animate(autoPlay: !performance).fadeIn(duration: 220.ms),
              ],
            ),
          ),
          if (picked != null)
            FilledButton(
              onPressed: () => _next(q),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _index + 1 == _questions!.length ? 'Hoàn thành' : 'Tiếp theo',
              ),
            ),
        ],
      ),
    );
  }

  _ChoiceState _stateOf(String choice, String answer, String? picked) {
    if (picked == null) return _ChoiceState.idle;
    if (choice == answer) return _ChoiceState.correct;
    if (choice == picked) return _ChoiceState.wrong;
    return _ChoiceState.dim;
  }

  void _pick(String choice, _ClozeQuestion q) {
    HanzifyHaptic.selection();
    setState(() {
      _picked = choice;
      if (choice == q.answer) _score++;
    });
  }

  void _next(_ClozeQuestion q) {
    final qs = _questions!;
    setState(() {
      if (_index + 1 >= qs.length) {
        _finished = true;
      } else {
        _index++;
        _picked = null;
      }
    });
  }
}

enum _ChoiceState { idle, correct, wrong, dim }

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _ChoiceState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    Color border;
    switch (state) {
      case _ChoiceState.correct:
        bg = colors.primaryContainer;
        fg = colors.onPrimaryContainer;
        border = colors.primary;
      case _ChoiceState.wrong:
        bg = colors.errorContainer;
        fg = colors.onErrorContainer;
        border = colors.error;
      case _ChoiceState.dim:
        bg = colors.surfaceContainerHigh;
        fg = colors.onSurfaceVariant.withValues(alpha: 0.6);
        border = colors.outlineVariant;
      case _ChoiceState.idle:
        bg = colors.surfaceContainerHigh;
        fg = colors.onSurface;
        border = colors.outlineVariant.withValues(alpha: 0.5);
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
