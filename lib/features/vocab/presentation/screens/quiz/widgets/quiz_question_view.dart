import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/app_curves.dart';
import 'package:hanzify/core/theme/app_durations.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/widgets/hanzify_app_bar.dart';
import 'package:hanzify/core/widgets/hanzify_quiz_option.dart';
import 'package:hanzify/core/widgets/hanzify_streak_badge.dart';
import 'package:hanzify/core/widgets/shake_widget.dart';
import 'package:hanzify/features/vocab/presentation/providers/quiz_state.dart';
import 'package:hanzify/core/utils/vocab_meaning_helper.dart';

class QuizQuestionView extends ConsumerWidget {
  const QuizQuestionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizProvider);
    final c = themeColorsOf(context);

    if (state.questions.isEmpty) return const SizedBox.shrink();

    final question = state.questions[state.currentIndex];
    final progress = (state.currentIndex + 1) / state.questions.length;
    final modeLabel = question.mode == QuizMode.hanziToMeaning
        ? '🀄 Hanzi → Nghĩa'
        : '🇻🇳 Nghĩa → Hanzi';

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          // Header: back + mode label + streak badge + progress bar
          HanzifyAppBar(
            backStyle: HanzifyBackButtonStyle.pill,
            backLabel: '← Thoát',
            onBackTap: () => ref.read(quizProvider.notifier).reset(),
            title: modeLabel,
            titleStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.placeholder),
            trailing: HanzifyStreakBadge(
              count: state.streak,
              compact: true,
            ),
            progress: progress,
          ),

          // Question area with AnimatedSwitcher (slide+fade between questions)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: Column(
                children: [
                  // Question card — keyed by currentIndex for AnimatedSwitcher
                  AnimatedSwitcher(
                    duration: AppDurations.normal,
                    switchInCurve: AppCurves.enter,
                    switchOutCurve: AppCurves.exit,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _QuestionCard(
                      key: ValueKey(state.currentIndex),
                      question: question,
                      showPinyin: state.showPinyin,
                      onTogglePinyin: () =>
                          ref.read(quizProvider.notifier).togglePinyin(),
                      colors: c,
                    ),
                  ),

                  // Options
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl),
                    child: Column(
                      children: List.generate(question.options.length, (idx) {
                        final isSelected = state.selectedAnswer == idx;
                        final isCorrect = idx == question.correctIndex;
                        final showResult = state.selectedAnswer != null;
                        final isWrong =
                            showResult && isSelected && !isCorrect;

                        QuizOptionState optState = QuizOptionState.normal;
                        if (showResult) {
                          if (isCorrect) {
                            optState = QuizOptionState.correct;
                          } else if (isSelected) {
                            optState = QuizOptionState.wrong;
                          } else {
                            optState = QuizOptionState.disabled;
                          }
                        } else if (isSelected) {
                          optState = QuizOptionState.selected;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: ShakeWidget(
                            trigger: isWrong,
                            child: HanzifyQuizOption(
                              label: String.fromCharCode(65 + idx),
                              text: question.options[idx],
                              state: optState,
                              isHanzi:
                                  question.mode == QuizMode.meaningToHanzi,
                              onTap: () => ref
                                  .read(quizProvider.notifier)
                                  .selectAnswer(idx),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Question card ─────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final bool showPinyin;
  final VoidCallback onTogglePinyin;
  final AppThemeColors colors;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.showPinyin,
    required this.onTogglePinyin,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final isHanziMode = question.mode == QuizMode.hanziToMeaning;
    final vocab = question.vocab;
    final semanticLabel = isHanziMode
        ? 'Câu hỏi: ${vocab.hanzi}, phát âm ${vocab.pinyin}. Chọn nghĩa đúng.'
        : 'Câu hỏi: ${vocab.primaryMeaningVi}. Chọn từ tiếng Trung đúng.';

    return Semantics(
      label: semanticLabel,
      child: Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: c.glassSurface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: c.glassBorder),
        boxShadow: c.cardShadow,
      ),
      child: Column(
        children: [
          if (isHanziMode) ...[
            Text(
              vocab.hanzi,
              textAlign: TextAlign.center,
              style: AppTypography.hanziDisplay(
                fontSize: vocab.hanzi.length > 3
                    ? AppFontSizes.displaySm
                    : AppFontSizes.displayMd,
                color: c.text,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: AppDurations.fast,
                  child: Text(
                    showPinyin ? vocab.pinyin : '• • •',
                    key: ValueKey(showPinyin),
                    style: AppTypography.pinyin(
                      fontSize: AppFontSizes.titleMd,
                      color: showPinyin ? c.primary : c.disabled,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _PinyinToggle(
                    showPinyin: showPinyin, onTap: onTogglePinyin, colors: c),
              ],
            ),
          ] else
            Text(
              vocab.primaryMeaningVi,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                fontSize: AppFontSizes.titleLg,
                fontWeight: FontWeight.w700,
                color: c.text,
                height: 1.4,
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _PinyinToggle extends StatelessWidget {
  final bool showPinyin;
  final VoidCallback onTap;
  final AppThemeColors colors;

  const _PinyinToggle({
    required this.showPinyin,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 5),
        decoration: BoxDecoration(
          color: c.disabled.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Text(
          showPinyin ? '🙈 Ẩn' : '👁 Hiện',
          style: AppTypography.label(
              fontSize: AppFontSizes.labelSm,
              fontWeight: FontWeight.w600,
              color: c.placeholder),
        ),
      ),
    );
  }
}
