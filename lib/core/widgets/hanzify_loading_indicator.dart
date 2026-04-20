import 'package:flutter/material.dart';

class HanzifyLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const HanzifyLoadingIndicator({
    super.key,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          color: color ?? cs.primary,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }
}
