import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

/// Wrapper quanh [awesome_snackbar_content] để giữ style nhất quán.
class HanzifySnack {
  static void _show(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType type,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: type,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  static void success(BuildContext context, String message, {String title = 'Thành công'}) =>
      _show(context, title: title, message: message, type: ContentType.success);

  static void error(BuildContext context, String message, {String title = 'Có lỗi'}) =>
      _show(context, title: title, message: message, type: ContentType.failure);

  static void info(BuildContext context, String message, {String title = 'Thông báo'}) =>
      _show(context, title: title, message: message, type: ContentType.help);

  static void warning(BuildContext context, String message, {String title = 'Cảnh báo'}) =>
      _show(context, title: title, message: message, type: ContentType.warning);
}
