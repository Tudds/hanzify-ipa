import 'package:flutter/material.dart';

/// Quy ước viết tắt loại từ trong dữ liệu HSK.
///
/// Map sang nhãn tiếng Việt + màu nền chip để hiển thị nhất quán
/// trên VocabCard, VocabDetailSheet, FlashcardDrill...
class PosLabel {
  const PosLabel._();

  static const _vietnamese = <String, String>{
    'v': 'Động từ',
    'n': 'Danh từ',
    'adj': 'Tính từ',
    'adv': 'Trạng từ',
    'num': 'Số từ',
    'pron': 'Đại từ',
    'prep': 'Giới từ',
    'conj': 'Liên từ',
    'interj': 'Thán từ',
    'mw': 'Lượng từ',
    'aux': 'Trợ động từ',
    'prefix': 'Tiền tố',
    'suffix': 'Hậu tố',
    'other': 'Khác',
  };

  static const _shortLabel = <String, String>{
    'v': 'đg',
    'n': 'dt',
    'adj': 'tt',
    'adv': 'trt',
    'num': 'số',
    'pron': 'đại',
    'prep': 'giới',
    'conj': 'liên',
    'interj': 'thán',
    'mw': 'lượng',
    'aux': 'trợ',
    'prefix': 'tiền',
    'suffix': 'hậu',
    'other': '·',
  };

  /// Nhãn đầy đủ tiếng Việt — dùng trong detail sheet.
  static String vietnamese(String pos) => _vietnamese[pos] ?? pos;

  /// Nhãn rút gọn 2-3 ký tự — dùng trên card nhỏ.
  static String short(String pos) => _shortLabel[pos] ?? pos;

  /// Màu nền chip dựa theo loại từ — semantic nhẹ, ổn định giữa light/dark.
  static Color color(String pos, ColorScheme scheme) {
    return switch (pos) {
      'v' => scheme.primary,
      'n' => scheme.tertiary,
      'adj' => scheme.secondary,
      'adv' => scheme.error,
      'num' || 'mw' => scheme.primary,
      'pron' => scheme.tertiary,
      'aux' => scheme.secondary,
      _ => scheme.outline,
    };
  }
}
