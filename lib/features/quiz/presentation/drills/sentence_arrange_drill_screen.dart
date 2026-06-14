import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/learning/application/study_session_recorder.dart';
import '../../../../core/learning/domain/fsrs.dart';
import '../../../../core/providers/performance_provider.dart';
import '../../../../core/widgets/hanzify_haptic.dart';
import '../../../dictionary/domain/vocab_item.dart';
import '../../application/quiz_pool.dart';
import '../widgets/drill_scaffold.dart';

class _ArrangeQuestion {
  _ArrangeQuestion({
    required this.vocabId,
    required this.tokens,
    required this.translation,
  }) : answer = tokens.join();

  final String vocabId;
  final List<String> tokens;
  final String answer;
  final String translation;
}

class SentenceArrangeDrillScreen extends ConsumerStatefulWidget {
  const SentenceArrangeDrillScreen({super.key, required this.level});

  final int level;

  @override
  ConsumerState<SentenceArrangeDrillScreen> createState() =>
      _SentenceArrangeDrillScreenState();
}

class _SentenceArrangeDrillScreenState
    extends ConsumerState<SentenceArrangeDrillScreen> {
  List<_ArrangeQuestion>? _questions;
  int _index = 0;
  int _score = 0;
  late List<int> _bank;
  late List<int> _placed;
  bool _checked = false;
  bool _correct = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _bank = [];
    _placed = [];
  }

  @override
  Widget build(BuildContext context) {
    final asyncPool = ref.watch(quizPoolProvider);
    return asyncPool.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Lỗi: $e'))),
      data: (pool) {
        if (_questions == null) {
          _questions = _build(pool.vocab);
          _resetBank();
        }
        final qs = _questions!;
        if (qs.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sắp xếp câu')),
            body: const Center(
              child: Text('Không đủ câu ngắn để luyện.'),
            ),
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
                  _finished = false;
                  _resetBank();
                });
              },
            ),
          );
        }
        return DrillScaffold(
          title: 'Sắp xếp câu',
          progress: _index / qs.length,
          score: _score,
          body: _buildBoard(qs[_index]),
        );
      },
    );
  }

  List<_ArrangeQuestion> _build(List<VocabItem> vocab) {
    final pool = vocab
        .where(
          (v) =>
              v.level == widget.level &&
              v.examples.isNotEmpty &&
              v.examples.first.cn.length >= 3 &&
              v.examples.first.cn.length <= 10,
        )
        .toList();
    if (pool.length < 4) return const [];
    final rng = Random();
    pool.shuffle(rng);
    final out = <_ArrangeQuestion>[];
    for (final v in pool.take(8)) {
      final example = v.examples.first;
      final cn = example.cn;
      final tokens = _tokenize(cn);
      if (tokens.length < 2 || tokens.length > 8) continue;
      out.add(
        _ArrangeQuestion(
          vocabId: v.id,
          tokens: tokens,
          translation: example.vi,
        ),
      );
    }
    return out;
  }

  List<String> _tokenize(String text) {
    final tokens = <String>[];
    for (final ch in text.runes) {
      final s = String.fromCharCode(ch);
      if (RegExp(r'[\u4e00-\u9fff]').hasMatch(s)) {
        tokens.add(s);
      } else if (s.trim().isNotEmpty) {
        tokens.add(s);
      }
    }
    return tokens;
  }

  void _resetBank() {
    if (_questions == null || _questions!.isEmpty) return;
    final q = _questions![_index];
    final indices = List<int>.generate(q.tokens.length, (i) => i);
    indices.shuffle();
    _bank = indices;
    _placed = [];
    _checked = false;
    _correct = false;
  }

  Widget _buildBoard(_ArrangeQuestion q) {
    final colors = Theme.of(context).colorScheme;
    final performance = readPerformance(ref);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sắp xếp từ thành câu đúng',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          if (q.translation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              q.translation,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 20),
          _SlotArea(
            tokens: q.tokens,
            placed: _placed,
            checked: _checked,
            correct: _correct,
            onTap: _checked ? null : _undo,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in _bank)
                _Chip(
                  text: q.tokens[i],
                  onTap: _checked ? null : () => _place(i),
                )
                    .animate(autoPlay: !performance)
                    .fadeIn(duration: 220.ms),
            ],
          ),
          const Spacer(),
          if (_checked)
            FilledButton(
              onPressed: () => _next(q),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _index + 1 == _questions!.length ? 'Hoàn thành' : 'Tiếp theo',
              ),
            )
          else
            FilledButton(
              onPressed: _placed.length == q.tokens.length
                  ? () => _check(q)
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Kiểm tra'),
            ),
        ],
      ),
    );
  }

  void _place(int tokenIndex) {
    HanzifyHaptic.selection();
    setState(() {
      _bank.remove(tokenIndex);
      _placed.add(tokenIndex);
    });
  }

  void _undo(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= _placed.length) return;
    HanzifyHaptic.selection();
    setState(() {
      final removed = _placed.removeAt(slotIndex);
      _bank.add(removed);
    });
  }

  void _check(_ArrangeQuestion q) {
    final attempt = _placed.map((i) => q.tokens[i]).join();
    final correct = attempt == q.answer;
    if (correct) {
      HanzifyHaptic.success();
    } else {
      HanzifyHaptic.error();
    }
    ref
        .read(studySessionRecorderProvider)
        .record(
          targetType: 'vocab',
          targetId: q.vocabId,
          rating: correct ? SrsRating.good : SrsRating.again,
        );
    setState(() {
      _checked = true;
      _correct = correct;
      if (correct) _score++;
    });
  }

  void _next(_ArrangeQuestion q) {
    setState(() {
      if (_index + 1 >= _questions!.length) {
        _finished = true;
      } else {
        _index++;
        _resetBank();
      }
    });
  }
}

class _SlotArea extends StatelessWidget {
  const _SlotArea({
    required this.tokens,
    required this.placed,
    required this.checked,
    required this.correct,
    required this.onTap,
  });

  final List<String> tokens;
  final List<int> placed;
  final bool checked;
  final bool correct;
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final borderColor = checked
        ? (correct ? colors.primary : colors.error)
        : colors.outlineVariant;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: placed.isEmpty
          ? Center(
              child: Text(
                'Chạm vào từ ở dưới để thêm vào đây',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            )
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < placed.length; i++)
                  _Chip(
                    text: tokens[placed[i]],
                    onTap: onTap == null ? null : () => onTap!(i),
                    filled: true,
                  ),
              ],
            ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.onTap, this.filled = false});

  final String text;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? colors.primaryContainer : colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filled
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: filled ? colors.onPrimaryContainer : colors.onSurface,
          ),
        ),
      ),
    );
  }
}
