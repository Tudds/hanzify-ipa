import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/features/vocab/presentation/providers/quiz_state.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_app_bar.dart';
import 'package:hanzify/core/widgets/hanzify_progress_bar.dart';
import 'package:hanzify/core/widgets/hanzify_quiz_option.dart';
import 'package:hanzify/core/utils/vocab_meaning_helper.dart';

class QuizQuestionView extends ConsumerStatefulWidget {
  const QuizQuestionView({super.key});

  @override
  ConsumerState<QuizQuestionView> createState() => _QuizQuestionViewState();
}

class _QuizQuestionViewState extends ConsumerState<QuizQuestionView> with TickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeCtrl.forward().then((_) => _shakeCtrl.reset());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final c = themeColorsOf(context);

    if (state.questions.isEmpty) return const SizedBox.shrink();
    
    final question = state.questions[state.currentIndex];
    final progress = (state.currentIndex + 1) / state.questions.length;

    // Listen to feedback for shake effect
    ref.listen(quizProvider.select((s) => s.answerFeedback), (previous, next) {
      if (next == false) _triggerShake();
    });

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          _buildProgressHeader(c, state),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: HanzifyProgressBar(
              progress: progress,
              height: 6,
              borderRadius: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Câu ${state.currentIndex + 1} / ${state.questions.length}',
            style: TextStyle(fontSize: 13, color: c.placeholder),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: Column(
                children: [
                  _buildQuestionCard(c, question, state.showPinyin),
                  _buildOptionsList(c, question, state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(AppThemeColors c, QuizState state) {
    final q = state.questions[state.currentIndex];
    final label = q.mode == QuizMode.hanziToMeaning ? '🀄 Hanzi → Nghĩa' : '🇻🇳 Nghĩa → Hanzi';
    
    return HanzifyAppBar(
      backStyle: HanzifyBackButtonStyle.pill,
      backLabel: '← Thoát',
      onBackTap: () => ref.read(quizProvider.notifier).reset(),
      title: label,
      titleStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.placeholder),
      trailing: _buildStreakBadge(c, state.streak),
    );
  }

  Widget _buildStreakBadge(AppThemeColors c, int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: streak > 0 ? Colors.orange.withValues(alpha: 0.15) : c.disabled.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: TextStyle(fontSize: 12, color: streak > 0 ? Colors.orange : c.disabled)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: streak > 0 ? Colors.orange : c.placeholder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(AppThemeColors c, QuizQuestion q, bool showPinyin) {
    final isHanziMode = q.mode == QuizMode.hanziToMeaning;
    
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(sin(_shakeAnim.value * pi * 4) * 8, 0),
        child: child,
      ),
      child: HanzifyCard(
        margin: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        borderRadius: AppRadii.xxl,
        child: Column(
          children: [
            Text(
              isHanziMode ? q.vocab.hanzi : q.vocab.primaryMeaningVi,
              style: GoogleFonts.notoSansSc(
                fontSize: isHanziMode ? 56 : 22,
                fontWeight: FontWeight.w800,
                color: c.text,
              ),
              textAlign: TextAlign.center,
            ),
            if (isHanziMode) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    showPinyin ? q.vocab.pinyin : '• • •',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: showPinyin ? c.primary : c.disabled,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildTogglePinyinButton(c, showPinyin),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTogglePinyinButton(AppThemeColors c, bool showPinyin) {
    return GestureDetector(
      onTap: () => ref.read(quizProvider.notifier).togglePinyin(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: c.disabled.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadii.lg)),
        child: Text(
          showPinyin ? '🙈 Ẩn' : '👁 Hiện',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.placeholder),
        ),
      ),
    );
  }

  Widget _buildOptionsList(AppThemeColors c, QuizQuestion q, QuizState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: List.generate(q.options.length, (idx) {
          final isSelected = state.selectedAnswer == idx;
          final isCorrect = idx == q.correctIndex;
          final showResult = state.selectedAnswer != null;

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
            child: HanzifyQuizOption(
              label: String.fromCharCode(65 + idx),
              text: q.options[idx],
              state: optState,
              isHanzi: q.mode == QuizMode.meaningToHanzi,
              onTap: () => ref.read(quizProvider.notifier).selectAnswer(idx),
            ),
          );
        }),
      ),
    );
  }
}
