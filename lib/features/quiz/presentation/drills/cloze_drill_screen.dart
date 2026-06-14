import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/learning/application/study_session_recorder.dart';
import '../../../../core/learning/domain/fsrs.dart';
import '../../../../core/providers/performance_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/hanzify_haptic.dart';
import '../../../dictionary/domain/vocab_item.dart';
import '../../application/quiz_pool.dart';
import '../widgets/drill_scaffold.dart';

class _ClozeQuestion {
  const _ClozeQuestion({
    required this.vocabId,
    required this.fullSentence,
    required this.pinyin,
    required this.answer,
    required this.choices,
    required this.translation,
  });

  final String vocabId;
  final String fullSentence;
  final String pinyin;
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
  bool _showPinyin = false;
  Timer? _advanceTimer;

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

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
          vocabId: v.id,
          fullSentence: example.cn,
          pinyin: example.pinyin,
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
    final answered = picked != null;

    return GestureDetector(
      onTap: answered ? () => _next(q) : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Câu hỏi ở trung tâm; sau khi trả lời đổi sang panel kết quả.
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: answered
                      ? _ResultPanel(
                          key: const ValueKey('result'),
                          question: q,
                          correct: picked == q.answer,
                        )
                      : _PromptPanel(
                          key: const ValueKey('prompt'),
                          question: q,
                          showPinyin: _showPinyin,
                          onTogglePinyin: () =>
                              setState(() => _showPinyin = !_showPinyin),
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
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
            if (answered) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Chạm để tiếp tục',
                textAlign: TextAlign.center,
                style: context.text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
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
    final correct = choice == q.answer;
    ref
        .read(studySessionRecorderProvider)
        .record(
          targetType: 'vocab',
          targetId: q.vocabId,
          rating: correct ? SrsRating.good : SrsRating.again,
        );
    setState(() {
      _picked = choice;
      if (correct) _score++;
    });
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 2500), () => _next(q));
  }

  void _next(_ClozeQuestion q) {
    _advanceTimer?.cancel();
    if (!mounted) return;
    final qs = _questions!;
    setState(() {
      if (_index + 1 >= qs.length) {
        _finished = true;
      } else {
        _index++;
        _picked = null;
        _showPinyin = false;
      }
    });
  }
}

enum _ChoiceState { idle, correct, wrong, dim }

/// Câu hỏi (còn ____) ở trung tâm + toggle hiện/ẩn pinyin.
class _PromptPanel extends StatelessWidget {
  const _PromptPanel({
    super.key,
    required this.question,
    required this.showPinyin,
    required this.onTogglePinyin,
  });

  final _ClozeQuestion question;
  final bool showPinyin;
  final VoidCallback onTogglePinyin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question.prompt,
            textAlign: TextAlign.center,
            style: AppTypography.hanziDisplay(size: 30, color: colors.onSurface),
          ),
          if (showPinyin && question.pinyin.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              question.pinyin,
              textAlign: TextAlign.center,
              style: AppTypography.pinyin(size: 16, color: colors.primary),
            ),
          ],
          if (question.translation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              question.translation,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onTogglePinyin,
            icon: Icon(
              showPinyin
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 18,
            ),
            label: Text(showPinyin ? 'Ẩn pinyin' : 'Hiện pinyin'),
          ),
        ],
      ),
    );
  }
}

/// Sau khi chọn: câu đầy đủ (đã điền) + pinyin + dịch + dấu đúng/sai.
class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    super.key,
    required this.question,
    required this.correct,
  });

  final _ClozeQuestion question;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = correct ? context.semantic.success : context.semantic.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                correct ? 'Chính xác!' : 'Đáp án: ${question.answer}',
                style: context.text.titleMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            question.fullSentence,
            textAlign: TextAlign.center,
            style: AppTypography.hanziDisplay(size: 26, color: colors.onSurface),
          ),
          if (question.pinyin.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              question.pinyin,
              textAlign: TextAlign.center,
              style: AppTypography.pinyin(size: 15, color: colors.primary),
            ),
          ],
          if (question.translation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              question.translation,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
