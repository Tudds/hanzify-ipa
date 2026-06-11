import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/performance_provider.dart';
import '../../../../core/widgets/learning/quiz_victory_celebration.dart';

class DrillScaffold extends ConsumerWidget {
  const DrillScaffold({
    super.key,
    required this.title,
    required this.progress,
    required this.score,
    required this.body,
    this.onQuit,
    this.actions = const [],
  });

  final String title;
  final double progress;
  final int score;
  final Widget body;
  final VoidCallback? onQuit;

  /// Hiển thị trước badge điểm (ví dụ chip đổi cấp độ HSK).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: onQuit ?? () => Navigator.of(context).pop(),
        ),
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colors.surfaceContainerHigh,
              ),
            ),
          ),
        ),
        actions: [
          ...actions,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded, color: colors.tertiary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$score',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}

class DrillSummary extends ConsumerStatefulWidget {
  const DrillSummary({
    super.key,
    required this.score,
    required this.total,
    required this.onRestart,
  });

  final int score;
  final int total;
  final VoidCallback onRestart;

  @override
  ConsumerState<DrillSummary> createState() => _DrillSummaryState();
}

class _DrillSummaryState extends ConsumerState<DrillSummary> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1200),
    );
    final performance = ref.read(performanceProvider).value ?? false;
    if (!performance && widget.score >= widget.total / 2) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final performance = readPerformance(ref);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QuizVictoryCelebration(
                score: widget.score,
                total: widget.total,
                performance: performance,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.exit_to_app_rounded),
                    label: const Text('Thoát'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: widget.onRestart,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Làm lại'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!performance)
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 24,
            maxBlastForce: 16,
            minBlastForce: 6,
            emissionFrequency: 0.04,
            gravity: 0.3,
            colors: [colors.primary, colors.secondary, colors.tertiary],
          ),
      ],
    );
  }
}
