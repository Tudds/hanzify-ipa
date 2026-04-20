import 'package:flutter/material.dart';

class HanzifyGradientFab extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final double size;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const HanzifyGradientFab({
    super.key,
    required this.icon,
    this.iconColor,
    this.size = 56,
    this.onTap,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: onTap,
      child: Icon(icon, size: 32),
    );
  }
}
