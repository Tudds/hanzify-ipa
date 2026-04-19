import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_app_bar.dart';
import 'package:hanzify/features/vocab/presentation/providers/quiz_state.dart';

class QuizModeSelection extends ConsumerWidget {
  const QuizModeSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = themeColorsOf(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          HanzifyAppBar(
            variant: HanzifyAppBarVariant.backOnly,
            backStyle: HanzifyBackButtonStyle.pill,
            backLabel: '← Về',
            onBackTap: () => ref.read(navigationProvider.notifier).navigate(AppRoutes.home),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  const Hero(
                    tag: 'quiz_hero',
                    child: Text('🧠', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Chọn Chế Độ',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Chọn kiểu câu hỏi bạn muốn luyện',
                    style: TextStyle(fontSize: 15, color: c.placeholder),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ...QuizMode.values.map((m) => _buildModeCard(m, c, ref)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(QuizMode m, AppThemeColors c, WidgetRef ref) {
    final String label = m == QuizMode.hanziToMeaning ? 'Hanzi → Nghĩa' : 'Nghĩa → Hanzi';
    final String emoji = m == QuizMode.hanziToMeaning ? '🀄' : '🇻🇳';

    return GestureDetector(
      onTap: () => ref.read(quizProvider.notifier).startQuiz(m),
      child: HanzifyCard(
        variant: HanzifyCardVariant.glass,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: c.accentGradient,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                boxShadow: [
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '10 câu hỏi trắc nghiệm',
                    style: TextStyle(fontSize: 13, color: c.placeholder),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c.glassSurface,
                shape: BoxShape.circle,
                border: Border.all(color: c.glassBorder, width: 1),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: c.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
