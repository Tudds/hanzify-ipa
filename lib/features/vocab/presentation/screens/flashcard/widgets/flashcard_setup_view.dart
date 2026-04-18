import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';

class FlashcardSetupView extends ConsumerWidget {
  final int selectedHsk;
  final bool onlyDue;
  final bool onlyBookmarked;
  final int limit;
  final Function(int) onHskChanged;
  final Function(bool, bool) onModeChanged;
  final Function(int) onLimitChanged;
  final VoidCallback onStart;
  final Widget header;

  const FlashcardSetupView({
    super.key,
    required this.selectedHsk,
    required this.onlyDue,
    required this.onlyBookmarked,
    required this.limit,
    required this.onHskChanged,
    required this.onModeChanged,
    required this.onLimitChanged,
    required this.onStart,
    required this.header,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = themeColorsOf(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            header,
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cấu hình bộ thẻ',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tùy chỉnh để bắt đầu phiên học hiệu quả nhất.',
                      style: TextStyle(fontSize: 15, color: c.placeholder),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    _sectionTitle('Cấp độ HSK', c),
                    const SizedBox(height: AppSpacing.md),
                    _buildHskChips(c),
                    const SizedBox(height: AppSpacing.xxl),

                    _sectionTitle('Chế độ học', c),
                    const SizedBox(height: AppSpacing.md),
                    _buildModeTiles(c, ref),
                    const SizedBox(height: AppSpacing.xxl),

                    _sectionTitle('Số lượng từ vựng', c),
                    const SizedBox(height: AppSpacing.md),
                    _buildLimitOptions(c),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
            _buildStartButton(c),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, AppThemeColors c) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: c.accent,
      ),
    );
  }

  Widget _buildHskChips(AppThemeColors c) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [0, 1, 2, 3, 4, 5, 6].map((lvl) {
        final isSelected = selectedHsk == lvl;
        return ChoiceChip(
          label: Text(lvl == 0 ? 'Tất cả' : 'HSK $lvl'),
          selected: isSelected,
          onSelected: (_) => onHskChanged(lvl),
          selectedColor: c.primary.withValues(alpha: 0.2),
          checkmarkColor: c.primary,
          labelStyle: TextStyle(
            color: isSelected ? c.primary : c.text,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModeTiles(AppThemeColors c, WidgetRef ref) {
    final dueCount = ref.watch(dueVocabProvider).value?.length ?? 0;
    final isDueEnabled = dueCount > 0;

    return Column(
      children: [
        _buildModeTile(
          title: 'Ôn luyện định kỳ',
          subtitle: isDueEnabled ? 'Có $dueCount từ đã đến hạn ôn tập.' : 'Chưa có từ nào đến hạn ôn tập.',
          icon: Icons.history_rounded,
          isSelected: onlyDue && !onlyBookmarked,
          c: c,
          enabled: isDueEnabled,
          onTap: () => onModeChanged(true, false),
        ),
        _buildModeTile(
          title: 'Học mọi từ',
          subtitle: 'Bao gồm cả từ mới chưa học.',
          icon: Icons.auto_awesome_rounded,
          isSelected: !onlyDue && !onlyBookmarked,
          c: c,
          onTap: () => onModeChanged(false, false),
        ),
        _buildModeTile(
          title: 'Chỉ mục Yêu thích',
          subtitle: 'Ôn tập các từ bạn đã đánh dấu ⭐.',
          icon: Icons.star_rounded,
          isSelected: onlyBookmarked,
          c: c,
          onTap: () => onModeChanged(false, true),
        ),
      ],
    );
  }

  Widget _buildModeTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required AppThemeColors c,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? c.primary.withValues(alpha: 0.08) : c.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(
              color: isSelected ? c.primary : c.disabled.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? c.primary : c.disabled.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Icon(icon, color: isSelected ? Colors.white : c.placeholder, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? c.primary : c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: c.placeholder)),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle_rounded, color: c.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitOptions(AppThemeColors c) {
    return Row(
      children: [10, 20, 50, -1].map((limitVal) {
        final isSelected = limit == limitVal;
        return Expanded(
          child: GestureDetector(
            onTap: () => onLimitChanged(limitVal),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? c.primary : c.surface,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: isSelected ? c.primary : c.disabled.withValues(alpha: 0.3)),
              ),
              child: Text(
                limitVal == -1 ? 'Tất cả' : '$limitVal',
                textAlign: TextAlign.center,
                style: TextStyle(color: isSelected ? Colors.white : c.text, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartButton(AppThemeColors c) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: c.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
            elevation: 4,
          ),
          child: const Text('Bắt đầu học ngay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
