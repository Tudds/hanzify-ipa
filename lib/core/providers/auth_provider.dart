import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

/// Stream toàn bộ sự kiện auth (login, logout, token refresh...).
@Riverpod(keepAlive: true)
Stream<AuthState> authStateChanges(Ref ref) =>
    Supabase.instance.client.auth.onAuthStateChange;

/// User hiện tại, null nếu chưa login.
@Riverpod(keepAlive: true)
User? currentUser(Ref ref) {
  ref.watch(authStateChangesProvider);
  return Supabase.instance.client.auth.currentUser;
}

/// Tiện ích: client Supabase truy cập nhanh.
SupabaseClient get supabase => Supabase.instance.client;
