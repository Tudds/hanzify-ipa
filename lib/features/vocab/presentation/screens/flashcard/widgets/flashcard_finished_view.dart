import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/widgets/vocab_card.dart';
import 'package:hanzify/core/widgets/hanzify_button.dart';
import 'package:hanzify/core/widgets/hanzify_result_header.dart';

class FlashcardFinishedView extends ConsumerWidget {
  final int reviewedCount;
  final List<Vocab> reviewedCards;

  const FlashcardFinishedView({
    super.key,
    required this.reviewedCount,
    required this.reviewedCards,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = themeColorsOf(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 60, AppSpacing.xxl, AppSpacing.xl),
              child: Column(
                children: [
                  HanzifyResultHeader(emoji: '🏆', color: c.primary),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Hoàn thành!',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Bạn đã ôn tập $reviewedCount từ vựng',
                    style: TextStyle(fontSize: 16, color: c.placeholder),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  HanzifyButton(
                    label: 'Về Trang Chủ',
                    width: 240,
                    onTap: () => ref.read(navigationProvider.notifier).navigate(AppRoutes.home),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return VocabCardWidget(item: reviewedCards[index], colors: c);
              }, childCount: reviewedCards.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }

}
