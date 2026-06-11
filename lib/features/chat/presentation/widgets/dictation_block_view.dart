import 'package:flutter/material.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/hanzi_text_compare.dart';
import '../../../../core/widgets/hanzify_haptic.dart';
import '../../domain/dictation.dart';
import '../../domain/gen_ui_chat.dart';

class DictationBlockView extends StatefulWidget {
  const DictationBlockView({super.key, required this.block});

  final DictationBlock block;

  @override
  State<DictationBlockView> createState() => _DictationBlockViewState();
}

class _DictationBlockViewState extends State<DictationBlockView> {
  late final TextEditingController _controller = TextEditingController();

  bool _checked = false;
  bool _correct = false;
  bool _showPinyin = false;
  bool _revealed = false;
  List<HanziDiffSegment> _diff = const [];

  DictationExercise get _exercise => widget.block.exercise;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Chỉ chấm khi user bấm "Kiểm tra"/submit — không validate trong onChanged
  /// để không phá composition của bộ gõ tiếng Trung trên web.
  void _check() {
    final answer = normalizeHanziAnswer(_exercise.textCn);
    final attempt = normalizeHanziAnswer(_controller.text);
    if (attempt.isEmpty) return;
    final correct = attempt == answer;
    if (correct) {
      HanzifyHaptic.success();
    } else {
      HanzifyHaptic.error();
    }
    setState(() {
      _checked = true;
      _correct = correct;
      _diff = correct ? const [] : diffHanzi(answer, attempt);
    });
  }

  void _reveal() {
    HanzifyHaptic.selection();
    setState(() {
      _revealed = true;
      _showPinyin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final exercise = _exercise;
    final isListen = exercise.mode == DictationMode.listen;
    final done = _correct || _revealed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isListen ? Icons.hearing_rounded : Icons.translate_rounded,
                color: colors.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isListen ? 'Nghe viết Hán tự' : 'Dịch Việt → Trung',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'HSK ${exercise.level}',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isListen)
            Row(
              children: [
                AudioPlayButton(
                  url: exercise.audioUrl,
                  size: 30,
                  tooltip: 'Phát audio',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bấm nghe (nghe lại được nhiều lần) rồi gõ lại câu.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              ],
            )
          else
            Text(
              exercise.textVi,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            enabled: !done,
            autocorrect: false,
            enableSuggestions: false,
            maxLines: 2,
            minLines: 1,
            style: AppTypography.hanziDisplay(
              size: 22,
              color: colors.onSurface,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _check(),
            decoration: InputDecoration(
              hintText: 'Gõ chữ Hán...',
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                onPressed: done ? null : _check,
                child: const Text('Kiểm tra'),
              ),
              TextButton(
                onPressed: _showPinyin
                    ? null
                    : () {
                        HanzifyHaptic.selection();
                        setState(() => _showPinyin = true);
                      },
                child: const Text('Gợi ý pinyin'),
              ),
              TextButton(
                onPressed: _revealed ? null : _reveal,
                child: const Text('Hiện đáp án'),
              ),
            ],
          ),
          if (_showPinyin && !done) ...[
            const SizedBox(height: 6),
            Text(
              exercise.pinyin,
              style: AppTypography.pinyin(size: 16, color: colors.primary),
            ),
          ],
          if (_checked && !_correct && !_revealed) ...[
            const SizedBox(height: 10),
            Text(
              'Chưa đúng, đối chiếu từng chữ:',
              style: TextStyle(
                color: colors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            _DiffView(segments: _diff),
            const SizedBox(height: 4),
            Text(
              'Sửa lại rồi bấm Kiểm tra lần nữa nhé.',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            ),
          ],
          if (done) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  _correct
                      ? Icons.check_circle_rounded
                      : Icons.lightbulb_rounded,
                  color: _correct ? colors.primary : colors.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  _correct ? 'Chính xác!' : 'Đáp án:',
                  style: TextStyle(
                    color: _correct ? colors.primary : colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.textCn,
                        style: AppTypography.hanziDisplay(
                          size: 24,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        exercise.pinyin,
                        style: AppTypography.pinyin(
                          size: 15,
                          color: colors.primary,
                        ),
                      ),
                      if (exercise.textVi.isNotEmpty)
                        Text(
                          exercise.textVi,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                if (exercise.audioUrl != null && !isListen)
                  AudioPlayButton(url: exercise.audioUrl, size: 24),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DiffView extends StatelessWidget {
  const _DiffView({required this.segments});

  final List<HanziDiffSegment> segments;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text.rich(
      TextSpan(
        children: [
          for (final segment in segments)
            TextSpan(
              text: segment.kind == HanziDiffKind.missing
                  ? List.filled(segment.text.runes.length, '＿').join()
                  : segment.text,
              style: switch (segment.kind) {
                HanziDiffKind.match => TextStyle(color: colors.primary),
                HanziDiffKind.wrong || HanziDiffKind.extra => TextStyle(
                  color: colors.error,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: colors.error,
                ),
                HanziDiffKind.missing => TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              },
            ),
        ],
      ),
      style: AppTypography.hanziDisplay(
        size: 22,
        color: colors.onSurface,
      ),
    );
  }
}
