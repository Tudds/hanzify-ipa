import 'package:flutter/material.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/audio/audio_urls.dart';
import '../../../../core/learning/collocation.dart';
import '../../../../core/learning/lesson_context.dart';
import '../../../../core/learning/learning_asset_repository.dart';
import '../../../../core/learning/quiz_generator.dart';
import '../../../../core/learning/study_session_controller.dart';
import '../../application/game_session_controller.dart';

class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({
    super.key,
    required this.session,
    required this.index,
    required this.snapshot,
    required this.lastResult,
    required this.answeredCount,
    required this.correctCount,
  });

  final HskLearningSessionSeed session;
  final int index;
  final StudySessionSnapshot snapshot;
  final StudyAnswerResult? lastResult;
  final int answeredCount;
  final int correctCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HSK${session.activeLevel} · ${session.collocations.length} collocations · Quiz ${index + 1}/${session.quizzes.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'FSRS local · ${snapshot.cards.length} cards · ${snapshot.reviewedCount} reviews · Score $correctCount/$answeredCount',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (lastResult != null) ...[
              const SizedBox(height: 4),
              Text(
                lastResult!.isCorrect
                    ? 'Last rating: Good'
                    : 'Last rating: Again',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SessionCompleteCard extends StatelessWidget {
  const SessionCompleteCard({
    super.key,
    required this.score,
    required this.failedQuizzes,
    required this.remediationGroups,
    required this.isCheckpoint,
    required this.onRetryFailed,
    required this.onRetryGroup,
  });

  final int score;
  final List<LearningQuiz> failedQuizzes;
  final List<RemediationGroup> remediationGroups;
  final bool isCheckpoint;
  final VoidCallback? onRetryFailed;
  final ValueChanged<RemediationGroup> onRetryGroup;

  @override
  Widget build(BuildContext context) {
    final passed = score >= 70;
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.85),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.verified_outlined : Icons.replay_outlined,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              passed ? 'Session passed' : 'Needs review',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Score: $score%'),
            if (passed) ...[
              const SizedBox(height: 12),
              Text(
                isCheckpoint
                    ? 'Reward unlocked: checkpoint badge + path progress.'
                    : 'Recap: bài học đã được lưu vào tiến độ học.',
                textAlign: TextAlign.center,
              ),
            ],
            if (!passed && failedQuizzes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Cần luyện lại ${failedQuizzes.length} câu sai'),
              const SizedBox(height: 4),
              Text(
                'Ưu tiên nhóm có nhiều lỗi trước, hoặc luyện lại tất cả câu sai.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final group in remediationGroups.take(4))
                _RemediationGroupTile(
                  group: group,
                  onRetry: () => onRetryGroup(group),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetryFailed,
                icon: const Icon(Icons.replay),
                label: const Text('Luyện lại câu sai'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LessonIntroCard extends StatefulWidget {
  const LessonIntroCard({
    super.key,
    required this.session,
    required this.lessonContext,
    required this.isCheckpoint,
    required this.onStart,
  });

  final HskLearningSessionSeed session;
  final LessonContext? lessonContext;
  final bool isCheckpoint;
  final VoidCallback onStart;

  @override
  State<LessonIntroCard> createState() => _LessonIntroCardState();
}

class _LessonIntroCardState extends State<LessonIntroCard> {
  var _step = 0;

  List<CollocationItem> get _conversationLines {
    final conversationIds = widget.lessonContext?.conversationIds.toSet();
    final lines = widget.session.collocations
        .where((item) {
          if (item.source != 'conversation_line') return false;
          if (conversationIds == null || conversationIds.isEmpty) return true;
          return item.conversationIds.any(conversationIds.contains);
        })
        .toList(growable: false);
    return [...lines]..sort((a, b) {
      final convCompare = _conversationId(a).compareTo(_conversationId(b));
      if (convCompare != 0) return convCompare;
      return _lineIndex(a).compareTo(_lineIndex(b));
    });
  }

  int get _totalSteps => 2 + _conversationLines.length;

  @override
  Widget build(BuildContext context) {
    final totalSteps = _totalSteps;
    final isLastStep = _step == totalSteps - 1;
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.85),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.isCheckpoint
                      ? Icons.flag_outlined
                      : Icons.route_outlined,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isCheckpoint
                            ? 'Checkpoint'
                            : 'Bài học hội thoại',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        _stepLabel(totalSteps),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StepProgress(currentStep: _step, totalSteps: totalSteps),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 390),
              child: SingleChildScrollView(child: _buildStep(context)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step -= 1),
                      child: const Text('Quay lại'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isLastStep
                        ? widget.onStart
                        : () => setState(() => _step += 1),
                    icon: Icon(
                      isLastStep ? Icons.play_arrow : Icons.arrow_forward,
                    ),
                    label: Text(isLastStep ? 'Bắt đầu quiz' : 'Tiếp tục'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    if (_step == 0) {
      return _LessonGoalStep(
        session: widget.session,
        lessonContext: widget.lessonContext,
      );
    }
    if (_step == 1) return _FullDialogueStep(lines: _conversationLines);
    return _DialogueLineStep(
      line: _conversationLines[_step - 2],
      activeLevel: widget.session.activeLevel,
      lineNumber: _step - 1,
      totalLines: _conversationLines.length,
      fallbackGrammarIds: widget.lessonContext?.grammarIds ?? const [],
    );
  }

  String _stepLabel(int totalSteps) {
    if (_step == 0) return 'Bước 1/$totalSteps · Mục tiêu bài';
    if (_step == 1) return 'Bước 2/$totalSteps · Hội thoại đầy đủ';
    return 'Câu ${_step - 1}/${_conversationLines.length} · từ vựng + mẫu câu';
  }

  String _conversationId(CollocationItem item) {
    return item.conversationIds.isEmpty ? '' : item.conversationIds.first;
  }

  int _lineIndex(CollocationItem item) {
    final audioUrl = item.audioUrl;
    if (audioUrl == null) return 999;
    final match = RegExp(r'_L(\d+)\.mp3$').firstMatch(audioUrl);
    return int.tryParse(match?.group(1) ?? '') ?? 999;
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var index = 0; index < totalSteps; index++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: index <= currentStep
                    ? colors.primary
                    : colors.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          if (index != totalSteps - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _LessonGoalStep extends StatelessWidget {
  const _LessonGoalStep({required this.session, required this.lessonContext});

  final HskLearningSessionSeed session;
  final LessonContext? lessonContext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mục tiêu bài', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Hiểu hội thoại, nắm từ khóa trong từng câu, nhận ra mẫu câu chính, rồi mới làm quiz.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('HSK${session.activeLevel}')),
            if (lessonContext != null)
              Chip(label: Text(lessonContext!.lessonUnitId)),
            Chip(label: Text('${session.quizzes.length} quiz')),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Thứ tự học: hội thoại đầy đủ → tách từng câu → từ vựng từng câu → grammar từng câu.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _FullDialogueStep extends StatelessWidget {
  const _FullDialogueStep({required this.lines});

  final List<CollocationItem> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hội thoại đầy đủ',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < lines.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (lines[index].audioUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: AudioPlayButton(
                      url: lines[index].audioUrl!,
                      size: 18,
                      tooltip: 'Nghe câu ${index + 1}',
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lines[index].textCn),
                      if (lines[index].textVi.isNotEmpty)
                        Text(
                          lines[index].textVi,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DialogueLineStep extends StatelessWidget {
  const _DialogueLineStep({
    required this.line,
    required this.activeLevel,
    required this.lineNumber,
    required this.totalLines,
    required this.fallbackGrammarIds,
  });

  final CollocationItem line;
  final int activeLevel;
  final int lineNumber;
  final int totalLines;
  final List<String> fallbackGrammarIds;

  @override
  Widget build(BuildContext context) {
    final vocab = _vocabForLine();
    final grammar = line.targetGrammarIds.isEmpty
        ? fallbackGrammarIds
        : line.targetGrammarIds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu $lineNumber/$totalLines',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (line.audioUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
                child: AudioPlayButton(
                  url: line.audioUrl!,
                  size: 24,
                  tooltip: 'Nghe câu này',
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.textCn,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (line.pinyin.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      line.pinyin,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (line.textVi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      line.textVi,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Từ vựng trong câu',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        vocab.isEmpty
            ? const Text('Không có từ khóa riêng cho câu này.')
            : _VocabChips(items: vocab),
        const SizedBox(height: 14),
        Text(
          'Grammar trong câu',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        _GrammarChips(values: grammar),
      ],
    );
  }

  List<({String id, String label})> _vocabForLine() {
    final values = <({String id, String label})>[];
    final seen = <String>{};
    for (final id in line.targetVocabIds) {
      if (!id.startsWith('hsk${activeLevel}_')) continue;
      final label = _idTail(id);
      if (label.isEmpty || !seen.add(label)) continue;
      values.add((id: id, label: label));
    }
    if (values.isNotEmpty) return values.take(6).toList(growable: false);
    for (final id in line.targetVocabIds) {
      final label = _idTail(id);
      if (label.isEmpty || !seen.add(label)) continue;
      values.add((id: id, label: label));
    }
    return values.take(6).toList(growable: false);
  }
}

class _VocabChips extends StatelessWidget {
  const _VocabChips({required this.items});

  final List<({String id, String label})> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final item in items)
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text(item.label),
            avatar: AudioPlayButton(
              url: AudioUrls.forVocab(item.id),
              size: 16,
              tooltip: 'Phát âm ${item.label}',
            ),
          ),
      ],
    );
  }
}

class _GrammarChips extends StatelessWidget {
  const _GrammarChips({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final value in values.take(4))
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text(_grammarLabel(value)),
          ),
      ],
    );
  }
}

String _idTail(String id) {
  final separator = id.indexOf('_');
  if (separator == -1 || separator == id.length - 1) return id;
  return id.substring(separator + 1);
}

String _grammarLabel(String id) {
  return switch (id) {
    'g_zěnmeyàng' => '怎么样 — thế nào?',
    'g_youdianr' => '有点儿 — hơi...',
    'g_bi' => '比 — so sánh hơn',
    'g_geng' => '更 — hơn nữa',
    'g_zui' => '最 — nhất',
    'g_mei_you' => '没有 — không bằng',
    'g_you_you' => '又...又... — vừa...vừa...',
    'g_de_attr' => '的 — bổ nghĩa danh từ',
    'g_ma' => '吗 — câu hỏi yes/no',
    'g_you' => '有 — có',
    'g_neg_bu' => '不 — phủ định',
    _ => id,
  };
}

class _RemediationGroupTile extends StatelessWidget {
  const _RemediationGroupTile({required this.group, required this.onRetry});

  final RemediationGroup group;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final example = group.quizzes.first;
    return Card.filled(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${group.kind}: ${group.label} · ${group.quizzes.length} lỗi',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text('Gợi ý: xem lại “${example.prompt}”'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.replay, size: 18),
                label: const Text('Luyện nhóm này'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
