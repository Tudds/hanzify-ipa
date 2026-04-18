/// Điền URL và anon key từ Supabase Dashboard → Settings → API.
/// Không commit key thật lên git — dùng --dart-define hoặc .env loader.
class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT.supabase.co',
  );
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_ANON_KEY',
  );
}
