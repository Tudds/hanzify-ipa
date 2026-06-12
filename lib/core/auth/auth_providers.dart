import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Đăng nhập/đăng xuất qua Supabase Auth. Web-first: Google OAuth dùng
/// full-page redirect; native cần deep link `redirectTo` (làm sau).
class AuthService {
  const AuthService();

  Future<void> signInWithGoogle() async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      // Web: quay lại đúng origin đang chạy (localhost dev / prod host).
      redirectTo: kIsWeb ? Uri.base.origin : null,
    );
  }

  Future<void> signOut() async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.instance.client.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => const AuthService());

/// User hiện tại (null = chưa đăng nhập / chưa cấu hình Supabase).
/// `onAuthStateChange` của supabase_flutter emit `initialSession` ngay khi
/// listen nên provider có giá trị ngay từ frame đầu.
final authUserProvider = StreamProvider<User?>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return Stream<User?>.value(null);
  }
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});
