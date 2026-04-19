import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/providers/performance_provider.dart';
import 'package:hanzify/core/theme/theme_state.dart';

/// Small pulsing dot indicator for "due" or "live" status.
///
/// Pulse animation automatically disabled when performanceProvider is true.
class HanzifyPulseDot extends ConsumerStatefulWidget {
  final Color? color;
  final double size;

  const HanzifyPulseDot({
    super.key,
    this.color,
    this.size = 8,
  });

  @override
  ConsumerState<HanzifyPulseDot> createState() => _HanzifyPulseDotState();
}

class _HanzifyPulseDotState extends ConsumerState<HanzifyPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppThemeExtension>()?.colors
        ?? AppThemeColors.light;
    final isLowPerf = ref.watch(performanceProvider) ||
        MediaQuery.disableAnimationsOf(context);
    final dotColor = widget.color ?? c.studyDue;

    if (!isLowPerf) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.repeat(reverse: true);
      });
    } else {
      _ctrl.stop();
    }

    return ScaleTransition(
      scale: isLowPerf ? const AlwaysStoppedAnimation(1.0) : _scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
