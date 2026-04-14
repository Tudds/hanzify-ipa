import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class SearchBarWidget extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String placeholder;
  final AppThemeColors colors;
  final TextEditingController controller;

  const SearchBarWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.colors,
    required this.controller,
    this.placeholder = 'Tìm kiếm...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(color: colors.text, fontSize: 16),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: colors.placeholder),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              autocorrect: false,
            ),
          ),
          if (value.isNotEmpty)
            GestureDetector(
              onTap: () { controller.clear(); onChanged(''); },
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text('✕', style: TextStyle(color: colors.placeholder, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}
