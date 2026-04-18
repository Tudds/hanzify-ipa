import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/features/vocab/presentation/providers/quiz_state.dart';
import 'package:hanzify/features/vocab/presentation/screens/quiz/widgets/quiz_mode_selection.dart';
import 'package:hanzify/features/vocab/presentation/screens/quiz/widgets/quiz_question_view.dart';
import 'package:hanzify/features/vocab/presentation/screens/quiz/widgets/quiz_results_view.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final c = themeColorsOf(context);

    return Stack(
      children: [
        _buildBody(quizState),
        _buildFeedbackOverlay(c, quizState.answerFeedback),
      ],
    );
  }

  Widget _buildBody(QuizState state) {
    if (state.mode == null) {
      return const QuizModeSelection();
    }
    if (state.isFinished) {
      return const QuizResultsView();
    }
    return const QuizQuestionView();
  }

  Widget _buildFeedbackOverlay(AppThemeColors c, bool? isCorrect) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation.drive(CurveTween(curve: Curves.elasticOut)),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: isCorrect == null
              ? const SizedBox.shrink(key: ValueKey('none'))
              : Center(
                  key: ValueKey(isCorrect),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: (isCorrect ? c.success : c.danger).withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isCorrect ? c.success : c.danger).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isCorrect ? '✓' : '✗',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
