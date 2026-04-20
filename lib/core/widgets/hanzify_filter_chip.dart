import 'package:flutter/material.dart';

class HanzifyFilterChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;

  const HanzifyFilterChip({
    super.key,
    required this.label,
    this.emoji,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        avatar: emoji != null ? Text(emoji!) : null,
        selected: isActive,
        onSelected: (_) => onTap(),
        selectedColor: activeColor,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : null,
        ),
      ),
    );
  }
}
