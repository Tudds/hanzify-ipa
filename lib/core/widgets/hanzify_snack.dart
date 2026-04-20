import 'package:flutter/material.dart';

class HanzifySnack {
  static void _show(
    BuildContext context, {
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 4,
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
                    Text(message, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void success(BuildContext context, String message, {String title = 'Thành công'}) =>
      _show(context, title: title, message: message, color: Colors.green, icon: Icons.check_circle_rounded);

  static void error(BuildContext context, String message, {String title = 'Có lỗi'}) =>
      _show(context, title: title, message: message, color: Colors.red, icon: Icons.error_rounded);

  static void info(BuildContext context, String message, {String title = 'Thông báo'}) =>
      _show(context, title: title, message: message, color: Colors.blue, icon: Icons.info_rounded);

  static void warning(BuildContext context, String message, {String title = 'Cảnh báo'}) =>
      _show(context, title: title, message: message, color: Colors.orange, icon: Icons.warning_rounded);
}
