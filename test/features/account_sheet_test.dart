import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/auth/auth_providers.dart';
import 'package:hanzify/features/account/presentation/account_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _RecordingAuthService implements AuthService {
  var signInCalls = 0;
  var signOutCalls = 0;

  @override
  Future<void> signInWithGoogle() async => signInCalls += 1;

  @override
  Future<void> signOut() async => signOutCalls += 1;
}

final _user = User(
  id: 'user-1',
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  createdAt: '2026-01-01T00:00:00Z',
  email: 'hoc-vien@hanzify.app',
);

Widget _wrap(_RecordingAuthService auth, User? user) {
  return ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(auth),
      authUserProvider.overrideWith((ref) => Stream<User?>.value(user)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showAccountSheet(context),
              child: const Text('open-sheet'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('signed-out sheet offers Google sign-in', (tester) async {
    final auth = _RecordingAuthService();
    await tester.pumpWidget(_wrap(auth, null));
    await tester.tap(find.text('open-sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Tài khoản'), findsOneWidget);
    expect(find.textContaining('đồng bộ tiến độ học'), findsOneWidget);

    await tester.tap(find.text('Đăng nhập với Google'));
    await tester.pump();
    expect(auth.signInCalls, 1);
  });

  testWidgets('signed-in sheet shows email, sync status, and sign-out', (
    tester,
  ) async {
    final auth = _RecordingAuthService();
    await tester.pumpWidget(_wrap(auth, _user));
    await tester.tap(find.text('open-sheet'));
    await tester.pumpAndSettle();

    expect(find.text('hoc-vien@hanzify.app'), findsOneWidget);
    expect(find.text('Chưa đồng bộ trong phiên này.'), findsOneWidget);
    expect(find.text('Đồng bộ ngay'), findsOneWidget);

    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, 1);
    // Sheet tự đóng sau khi đăng xuất.
    expect(find.text('Đồng bộ ngay'), findsNothing);
  });
}
