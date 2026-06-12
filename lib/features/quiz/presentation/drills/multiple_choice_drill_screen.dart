import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/performance_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/hanzify_haptic.dart';
import '../../../dictionary/domain/vocab_item.dart';
import '../../application/quiz_pool.dart';
import '../widgets/drill_scaffold.dart';

class _ChoiceQuestion {
  const _ChoiceQuestion({
    required this.prompt,
    required this.pinyin,
    required this.answer,
    required this.choices,
  });

  final String prompt;
  final String pinyin;
  final String answer;
  final List<String> choices;
}

class MultipleChoiceDrillScreen extends ConsumerStatefulWidget {
  const MultipleChoiceDrillScreen({super.key, required this.level});

  final int level;

  @override
  ConsumerState<MultipleChoiceDrillScreen> createState() =>
      _MultipleChoiceDrillScreenState();
}

class _MultipleChoiceDrillScreenState
    extends ConsumerState<MultipleChoiceDrillScreen> {
  List<_ChoiceQuestion>? _questions;
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
        final questions = _questions!;
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chọn từ')),
            body: const Center(child: Text('Không đủ dữ liệu để luyện.')),
          );
        }
        if (_finished) {
          return Scaffold(
            body: DrillSummary(
              score: _score,
              total: questions.length,
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
          title: 'Chọn từ',
          progress: _index / questions.length,
          score: _score,
          body: _buildQuestion(questions[_index]),
        );
      },
    );
  }

  List<_ChoiceQuestion> _build(List<VocabItem> vocab) {
    final pool = vocab
        .where((v) => v.level == widget.level && v.viShort.isNotEmpty)
        .toList();
    if (pool.length < 4) return const [];
    final rng = Random();
    pool.shuffle(rng);
    final questions = <_ChoiceQuestion>[];
    for (final item in pool.take(8)) {
      final distractors = pool
          .where((other) => other.id != item.id && other.viShort.isNotEmpty)
          .map((other) => other.viShort)
          .toList()
        ..shuffle(rng);
      final choices = <String>{item.viShort, ...distractors.take(3)}.toList()
        ..shuffle(rng);
      if (choices.length < 4) continue;
      questions.add(
        _ChoiceQuestion(
          prompt: item.hanzi,
          pinyin: item.pinyin,
          answer: item.viShort,
          choices: choices,
        ),
      );
    }
    return questions;
  }

  Widget _buildQuestion(_ChoiceQuestion question) {
    final colors = Theme.of(context).colorScheme;
    final performance = readPerformance(ref);
    final picked = _picked;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              children: [
                Text(
                  question.prompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (question.pinyin.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    question.pinyin,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: question.choices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final choice = question.choices[index];
                return _ChoiceButton(
                  text: choice,
                  state: _stateOf(choice, question.answer, picked),
                  onTap: picked == null
                      ? () => _pick(choice, question.answer)
                      : null,
                )
                    .animate(autoPlay: !performance)
                    .fadeIn(duration: 180.ms, delay: (index * 35).ms)
                    .slideY(begin: 0.04, end: 0, duration: 220.ms);
              },
            ),
          ),
          if (picked != null)
            FilledButton(
              onPressed: _next,
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

  void _pick(String choice, String answer) {
    final correct = choice == answer;
    if (correct) {
      HanzifyHaptic.success();
    } else {
      HanzifyHaptic.error();
    }
    setState(() {
      _picked = choice;
      if (correct) _score++;
    });
  }

  void _next() {
    setState(() {
      if (_index + 1 >= _questions!.length) {
        _finished = true;
      } else {
        _index++;
        _picked = null;
      }
    });
  }
}

enum _ChoiceState { idle, correct, wrong, dim }

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.text, required this.state, this.onTap});

  final String text;
  final _ChoiceState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semantic;
    final background = switch (state) {
      _ChoiceState.idle => colors.surfaceContainerHigh,
      _ChoiceState.correct => semantic.success.withValues(alpha: 0.22),
      _ChoiceState.wrong => semantic.danger.withValues(alpha: 0.22),
      _ChoiceState.dim => colors.surfaceContainerHigh.withValues(alpha: 0.45),
    };
    final foreground = switch (state) {
      _ChoiceState.correct => semantic.success,
      _ChoiceState.wrong => semantic.danger,
      _ => colors.onSurface,
    };
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        disabledBackgroundColor: background,
        foregroundColor: foreground,
        disabledForegroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}
