class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');

  /// Key mới dạng `sb_publishable_...` (khuyến nghị) hoặc legacy anon JWT —
  /// `Supabase.initialize(publishableKey:)` nhận cả hai.
  static const _publishable = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const _legacyAnon = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String get publishableKey =>
      _publishable.isNotEmpty ? _publishable : _legacyAnon;

  static bool get isConfigured =>
      url.isNotEmpty && publishableKey.isNotEmpty;
}
