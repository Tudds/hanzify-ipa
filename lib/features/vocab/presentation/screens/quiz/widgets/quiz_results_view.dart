import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/features/vocab/presentation/providers/quiz_state.dart';
import 'package:hanzify/core/widgets/hanzify_button.dart';
import 'package:hanzify/core/widgets/hanzify_progress_bar.dart';
import 'package:hanzify/core/widgets/hanzify_celebration.dart';
import 'package:hanzify/core/widgets/hanzify_result_header.dart';

class QuizResultsView extends ConsumerWidget {
  const QuizResultsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final c = themeColorsOf(context);
    final theme = Theme.of(context);

    if (quizState.questions.isEmpty) return const SizedBox.shrink();

    final score = quizState.score;
    final total = quizState.questions.length;
    final pct = (score / total * 100).round();
    
    final emoji = pct >= 80 ? '🌟' : pct >= 60 ? '👍' : '💪';
    final text = pct >= 80 ? 'Xuất sắc!' : pct >= 60 ? 'Khá tốt!' : 'Cần luyện thêm!';
    final barColor = pct >= 80 ? c.success : pct >= 60 ? c.warning : c.danger;

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          if (pct >= 80)
            const Positioned.fill(
              child: HanzifyCelebration(),
            ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HanzifyResultHeader(emoji: emoji, color: barColor),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    text,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$score / $total',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: barColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$pct% chính xác',
                    style: TextStyle(fontSize: 16, color: c.placeholder),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HanzifyProgressBar(
                    progress: pct / 100,
                    height: 12,
                    barColor: barColor,
                    borderRadius: AppRadii.full,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  HanzifyButton(
                    label: '🔄 Làm lại',
                    onTap: () => ref.read(quizProvider.notifier).startQuiz(quizState.mode!),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  HanzifyButton(
                    label: '🔀 Đổi chế độ',
                    type: HanzifyButtonType.outline,
                    onTap: () => ref.read(quizProvider.notifier).reset(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  HanzifyButton(
                    label: '← Về Trang Chủ',
                    type: HanzifyButtonType.outline,
                    onTap: () => ref.read(navigationProvider.notifier).navigate(AppRoutes.home),
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
