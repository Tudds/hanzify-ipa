import 'package:flutter/material.dart';

/// Hanzify Premium Color Palette.
/// Định nghĩa hệ thống màu HSL cao cấp cho ứng dụng Hanzify,
/// cung cấp độ tương phản vượt trội trong Sleek Dark Mode.
class AppColors {
  const AppColors._();

  // --- Backgrounds & Base Colors ---
  static const background = Color(0xFF090B14);      // Deep Space Blue/Black
  static const surface = Color(0xFF121626);         // Sleek container color
  static const surfaceCard = Color(0xFF1A1F36);     // Highlighted cards color
  static const surfaceGlow = Color(0xFF222744);     // Hover/Focus state background

  // --- Accent Colors ---
  static const primary = Color(0xFF7C5CFF);         // Royal Purple (chủ đạo)
  static const primaryLight = Color(0xFF9E85FF);    // Purple tint
  static const secondary = Color(0xFF00ADB5);       // Aqua Cyan (nhấn nhá)
  static const tertiary = Color(0xFFFF2E93);        // Pink/Rose (loại từ danh từ)

  // --- Text & Content Colors ---
  static const textPrimary = Color(0xFFF1F3F9);     // Gần trắng (độ tương phản 95%)
  static const textSecondary = Color(0xFFA5ADC6);   // Xám sáng cho thông tin phụ
  static const textMuted = Color(0xFF6C7693);       // Xám tối cho chú giải/gợi ý

  // --- Status & Feedback (Mượt mà, dịu mắt) ---
  static const success = Color(0xFF00C9A7);         // Mint Green (Chọn đúng)
  static const error = Color(0xFFFF5252);           // Soft Red (Chọn sai)
  static const warning = Color(0xFFFFB300);         // Amber Gold

  // --- HSK Level Colors (Độ bão hòa vừa phải để không bị chói trong Dark Mode) ---
  static const hsk1 = Color(0xFF2ECC71);            // HSK 1 - Xanh lá
  static const hsk2 = Color(0xFF3498DB);            // HSK 2 - Xanh biển
  static const hsk3 = Color(0xFFF1C40F);            // HSK 3 - Vàng nắng
  static const hsk4 = Color(0xFFE67E22);            // HSK 4 - Cam ấm

  static Color hskColor(int level) => switch (level) {
        1 => hsk1,
        2 => hsk2,
        3 => hsk3,
        4 => hsk4,
        _ => primary,
      };
}
