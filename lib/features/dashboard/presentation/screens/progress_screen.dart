import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/core/theme/theme_state.dart';

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
        vsync: this, duration: const Duration(milliseconds: 1500));
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
    final c = ref.watch(themeColorsProvider);
    
    final allVocabAsync = ref.watch(allVocabProvider);
    final dueVocabAsync = ref.watch(dueVocabProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: allVocabAsync.when(
        data: (allVocab) {
          final dueCount = dueVocabAsync.asData?.value.length ?? 0;
          final mastered = allVocab.where((v) => v.interval >= 7).length;
          final learning = allVocab.where((v) => v.interval > 0 && v.interval < 7).length;
          final newWords = allVocab.where((v) => v.interval == 0).length;
          final total = allVocab.length;
          final progressPercent = total > 0 ? (mastered / total) : 0.0;
          final progressPct = (progressPercent * 100).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.xxxl, AppSpacing.xl, AppSpacing.lg),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PROGRESS',
                            style: TextStyle(
                                fontSize: AppFontSizes.labelSm,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: c.placeholder)),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Mastery',
                            style: TextStyle(
                                fontSize: AppFontSizes.headlineLg,
                                fontWeight: FontWeight.w800,
                                color: c.text)),
                        const SizedBox(height: 4),
                        Text('Your journey through the path of silence and wisdom.',
                            style: TextStyle(
                                fontSize: AppFontSizes.bodyMd,
                                color: c.onSurfaceVariant)),
                      ]),
                ),
                
                _buildAnimatedMasteryCard(c, progressPercent, progressPct),
                
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text('Knowledge Sphere',
                      style: TextStyle(
                          fontSize: AppFontSizes.titleLg,
                          fontWeight: FontWeight.w700,
                          color: c.text)),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _SphereCard(
                          value: '$mastered',
                          label: 'Mastered',
                          valueColor: c.accent,
                          colors: c),
                      _SphereCard(
                          value: '$learning',
                          label: 'Learning',
                          valueColor: c.secondary,
                          colors: c),
                      _SphereCard(
                          value: '$newWords',
                          label: 'New',
                          valueColor: c.primary,
                          colors: c),
                      _SphereCard(
                          value: '$dueCount',
                          label: 'Due Today',
                          valueColor: c.warning,
                          colors: c),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                      color: c.surfaceLow,
                      borderRadius: BorderRadius.circular(AppRadii.lg)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Goal',
                            style: TextStyle(
                                fontSize: AppFontSizes.titleMd,
                                fontWeight: FontWeight.w700,
                                color: c.text)),
                        const SizedBox(height: 4),
                        Text(
                            'Review $dueCount cards today to maintain your streak and keep knowledge fresh.',
                            style: TextStyle(
                                fontSize: AppFontSizes.bodyMd,
                                color: c.onSurfaceVariant,
                                height: 1.5)),
                      ]),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildAnimatedMasteryCard(AppThemeColors c, double targetProgress, int targetPct) {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, child) {
        final currentProgress = targetProgress * _progressAnim.value;
        final currentPct = (targetPct * _progressAnim.value).round();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.primaryContainer, c.primary.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    progress: currentProgress,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    progressColor: Colors.white,
                    strokeWidth: 16,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          '$currentPct%',
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'Mastered',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Overall Progress Through The Path',
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [progressColor, progressColor.withValues(alpha: 0.7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, 
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SphereCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final AppThemeColors colors;
  const _SphereCard(
      {required this.value,
      required this.label,
      required this.valueColor,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    final w =
        (MediaQuery.of(context).size.width - AppSpacing.xl * 2 - AppSpacing.md) /
            2;
    return Container(
      width: w,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
          color: colors.surfaceLowest,
          borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: Column(children: [
        Text(value,
            style: TextStyle(
                fontSize: AppFontSizes.headlineMd,
                fontWeight: FontWeight.w800,
                color: valueColor)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: AppFontSizes.labelMd,
                fontWeight: FontWeight.w500,
                color: colors.placeholder)),
      ]),
    );
  }
}


