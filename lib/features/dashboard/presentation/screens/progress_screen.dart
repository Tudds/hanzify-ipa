import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';


import 'package:hanzify/core/widgets/circular_progress_painter.dart';
import 'package:hanzify/core/widgets/hanzify_screen_header.dart';
import 'package:hanzify/core/utils/hanzify_haptic.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final c = themeColorsOfRef(ref);
    final allVocabAsync = ref.watch(allVocabProvider);
    final dueVocabAsync = ref.watch(dueVocabProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: allVocabAsync.when(
        data: (allVocab) {
          final dueCount = dueVocabAsync.asData?.value.length ?? 0;
          final mastered = allVocab.where((v) => v.interval >= 7).length;
          final total = allVocab.length;
          final progress = total > 0 ? (dueCount / total).clamp(0.0, 1.0) : 0.0;
          const streak = 15;
          final easyToForget = allVocab.where((v) => v.easeFactor < 2.0).length;

          return CustomScrollView(
            slivers: [
              const HanzifyScreenHeader(
                title: 'Ôn Tập',
                subtitle: 'Hệ thống lặp lại ngắt quãng giúp bạn ghi nhớ lâu hơn.',
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.subsectionGap),

                      // ── Compact Hero: Progress ring + Stats side by side ──
                      _buildCompactHero(cs, theme, c, dueCount, mastered, streak, progress),

                      const SizedBox(height: AppSpacing.subsectionGap),

                      // ── CTA Buttons — Horizontal layout ──
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              emoji: '🗂',
                              title: 'Flashcard',
                              subtitle: 'Lướt nhanh',
                              gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                              onTap: () {
                                HanzifyHaptic.action();
                                ref.read(navigationProvider.notifier).navigate(AppRoutes.flashcard);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.cardListGap),
                          Expanded(
                            child: _ActionCard(
                              emoji: '🧠',
                              title: 'Quiz',
                              subtitle: 'Kiểm tra',
                              gradient: LinearGradient(colors: [cs.secondary, cs.primary]),
                              onTap: () {
                                HanzifyHaptic.action();
                                ref.read(navigationProvider.notifier).navigate(AppRoutes.quiz);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sectionGap),

                      // ── HSK Chart ──
                      _buildHskChart(cs, theme, c, allVocab),

                      // ── Warning: Easy to forget ──
                      if (easyToForget > 0) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Card.filled(
                          color: cs.errorContainer.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: cs.errorContainer.withValues(alpha: 0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: cs.error, size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('CẦN XEM LẠI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.error, letterSpacing: 1.1)),
                                      Text('Phát hiện $easyToForget từ dễ quên', style: TextStyle(fontSize: 14, color: cs.error)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  // ── Compact Hero: ring + 3 stat rows ──
  Widget _buildCompactHero(ColorScheme cs, ThemeData theme, AppThemeColors c, int dueCount, int mastered, int streak, double progress) {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, child) {
        final currentProgress = progress * _progressAnim.value;
        final currentCount = (dueCount * _progressAnim.value).round();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primaryContainer.withValues(alpha: 0.3),
                cs.surfaceContainerLow,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              // Progress ring — smaller
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: CircularProgressPainter(
                        progress: currentProgress,
                        backgroundColor: cs.surfaceContainerHighest,
                        progressColor: cs.primary,
                        endColor: cs.primaryContainer,
                        strokeWidth: 12,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$currentCount', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: cs.onSurface)),
                          Text('CẦN ÔN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant, letterSpacing: 1.1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Stats column
              Expanded(
                child: Column(
                  children: [
                    _StatRow(icon: Icons.local_fire_department_rounded, iconColor: Colors.orange, value: '$streak', label: 'Ngày liên tiếp'),
                    const SizedBox(height: 12),
                    _StatRow(icon: Icons.verified_rounded, iconColor: Colors.green, value: '$mastered', label: 'Đã thuộc lòng'),
                    const SizedBox(height: 12),
                    _StatRow(icon: Icons.schedule_rounded, iconColor: cs.primary, value: '$currentCount', label: 'Chờ ôn tập'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHskChart(ColorScheme cs, ThemeData theme, AppThemeColors c, List<dynamic> allVocab) {
    final levels = [1, 2, 3];
    final data = levels.map((lvl) {
      final lvlVocabs = allVocab.where((v) => v.level == lvl).toList();
      final total = lvlVocabs.length;
      final mastered = lvlVocabs.where((v) => v.interval >= 7).length;
      return (lvl, total, mastered);
    }).toList();

    final maxY = data.map((d) => d.$2).fold<int>(0, (a, b) => a > b ? a : b).toDouble();

    return Card.filled(
      color: cs.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TIẾN ĐỘ THEO CẤP HSK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant, letterSpacing: 1.1)),
            const SizedBox(height: 24),
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
                        getTitlesWidget: (value, meta) {
                          final lvl = value.toInt() + 1;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('HSK $lvl', style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
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
                            color: cs.surfaceContainerHighest,
                            width: 24,
                            borderRadius: BorderRadius.circular(4),
                            rodStackItems: [
                              BarChartRodStackItem(0, data[i].$3.toDouble(), cs.primary),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _legendDot(cs.primary, 'Đã thuộc'),
                const SizedBox(width: 16),
                _legendDot(cs.surfaceContainerHighest, 'Tổng số'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ── Compact stat row ──
class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatRow({required this.icon, required this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Action Card (horizontal CTA) ──
class _ActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({required this.emoji, required this.title, required this.subtitle, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
