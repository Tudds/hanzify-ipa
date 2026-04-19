import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/theme/app_durations.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/widgets/hanzify_stat_card.dart';
import 'package:hanzify/core/widgets/hanzify_action_tile.dart';
import 'package:hanzify/core/widgets/circular_progress_painter.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_screen_header.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: AppDurations.counter);
    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOfRef(ref);
    final allVocabAsync = ref.watch(allVocabProvider);
    final dueVocabAsync = ref.watch(dueVocabProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: allVocabAsync.when(
        data: (allVocab) {
          final dueCount = dueVocabAsync.asData?.value.length ?? 0;
          final mastered = allVocab.where((v) => v.interval >= 7).length;
          final total = allVocab.length;
          final progress = total > 0 ? (dueCount / total).clamp(0.0, 1.0) : 0.0;
          const streak = 15;
          final easyToForget =
              allVocab.where((v) => v.easeFactor < 2.0).length;

          return CustomScrollView(
            slivers: [
              const HanzifyScreenHeader(
                title: 'Ôn Tập',
                subtitle: 'Hệ thống lặp lại ngắt quãng giúp bạn ghi nhớ lâu hơn.',
              ),
              SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),

                // ── Circular progress ───────────────────────────────
                _buildCircularProgress(c, dueCount, progress),

                const SizedBox(height: AppSpacing.xxl),

                // ── Action buttons ──────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    children: [
                      HanzifyActionTile.variantGradient(
                        emoji: '🗂',
                        title: 'BẮT ĐẦU FLASHCARD',
                        subtitle: 'Lướt qua các từ cần ôn tập',
                        colors: c,
                        onTap: () {
                          HanzifyHaptic.action();
                          ref
                              .read(navigationProvider.notifier)
                              .navigate(AppRoutes.flashcard);
                        },
                      ),

                      // Quiz button — outlined white
                      HanzifyActionTile.variantOutlined(
                        emoji: '🧠',
                        title: 'KIỂM TRA QUIZ',
                        subtitle: 'Kiểm tra kiến thức của bạn',
                        colors: c,
                        onTap: () {
                          HanzifyHaptic.action();
                          ref
                              .read(navigationProvider.notifier)
                              .navigate(AppRoutes.quiz);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Stats grid ──────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Row(
                    children: [
                      Expanded(
                        child: HanzifyStatCard.vertical(
                          value: '$streak',
                          label: 'NGÀY LIÊN TIẾP',
                          icon: Icons.local_fire_department_rounded,
                          iconColor: c.warning,
                          colors: c,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: HanzifyStatCard.vertical(
                          value: '$mastered',
                          label: 'ĐÃ THUỘC LÒNG',
                          icon: Icons.verified_rounded,
                          iconColor: c.success,
                          colors: c,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── HSK mastery chart ───────────────────────────────
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, child) => Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - t)),
                      child: child,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: _buildHskChart(c, allVocab),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Alert card ──────────────────────────────────────
                if (easyToForget > 0)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: HanzifyCard(
                      variant: HanzifyCardVariant.glass,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      margin: EdgeInsets.zero,
                      color: c.error.withValues(alpha: 0.10),
                      border: Border.all(
                          color: c.error.withValues(alpha: 0.35), width: 1),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: c.error, size: 28),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CẦN XEM LẠI',
                                  style: AppTypography.headline(
                                    fontSize: AppFontSizes.titleSm,
                                    fontWeight: FontWeight.w800,
                                    color: c.error,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Phát hiện $easyToForget từ dễ quên',
                                  style: AppTypography.body(
                                    fontSize: AppFontSizes.bodySm,
                                    color: c.error.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.scrollBottom),
              ],
            ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Lỗi: $err', style: AppTypography.body(color: c.error))),
      ),
    );
  }

  Widget _buildHskChart(AppThemeColors c, List<dynamic> allVocab) {
    // Tính mastered / total theo mỗi HSK level
    final levels = [1, 2, 3];
    final data = levels.map((lvl) {
      final lvlVocabs = allVocab.where((v) => v.level == lvl).toList();
      final total = lvlVocabs.length;
      final mastered = lvlVocabs.where((v) => v.interval >= 7).length;
      return (lvl, total, mastered);
    }).toList();

    final maxY = data.map((d) => d.$2).fold<int>(0, (a, b) => a > b ? a : b).toDouble();

    return HanzifyCard(
      variant: HanzifyCardVariant.glass,
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIẾN ĐỘ THEO CẤP HSK',
            style: AppTypography.label(
              fontSize: AppFontSizes.labelSm,
              fontWeight: FontWeight.w700,
              color: c.primary,
            ).copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY == 0 ? 10 : maxY * 1.15,
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final lvl = value.toInt() + 1;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'HSK $lvl',
                            style: AppTypography.label(
                              fontSize: AppFontSizes.labelSm,
                              fontWeight: FontWeight.w600,
                              color: c.placeholder,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].$2.toDouble(),
                          color: c.outlineVariant.withValues(alpha: 0.4),
                          width: 22,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          rodStackItems: [
                            BarChartRodStackItem(
                              0,
                              data[i].$3.toDouble(),
                              c.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _legendDot(c.primary, 'Đã thuộc'),
              const SizedBox(width: AppSpacing.md),
              _legendDot(c.outlineVariant.withValues(alpha: 0.6), 'Tổng số'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.label(
            fontSize: AppFontSizes.labelSm,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress(
      AppThemeColors c, int dueCount, double progress) {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, child) {
        final currentProgress = progress * _progressAnim.value;
        final currentCount = (dueCount * _progressAnim.value).round();

        return Center(
          child: Container(
            width: AppSpacing.circularProgress,
            height: AppSpacing.circularProgress,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: c.primary.withValues(alpha: 0.28),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomPaint(
              painter: CircularProgressPainter(
                progress: currentProgress,
                backgroundColor: c.outlineVariant.withValues(alpha: 0.3),
                progressColor: c.primary,
                endColor: c.secondary,
                strokeWidth: 18,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentCount',
                      style: AppTypography.headline(
                        fontSize: AppFontSizes.displayMd,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TỪ CẦN ÔN TẬP',
                      style: AppTypography.label(
                        fontSize: AppFontSizes.labelSm,
                        fontWeight: FontWeight.w700,
                        color: c.placeholder,
                      ).copyWith(letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
