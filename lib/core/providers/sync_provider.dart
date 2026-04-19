import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/sync_service.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

part 'sync_provider.g.dart';

@Riverpod(keepAlive: true)
SyncService? syncService(Ref ref) {
  if (kIsWeb) return null;
  final db = ref.watch(appDatabaseProvider);
  return SyncService(db);
}

@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivityStream(Ref ref) =>
    Connectivity().onConnectivityChanged;

/// Reacts to auth events (pull on login) and connectivity (push on reconnect).
@Riverpod(keepAlive: true)
class SyncNotifier extends _$SyncNotifier {
  @override
  void build() {
    if (kIsWeb) return;

    ref.listen<AsyncValue<AuthState>>(authStateChangesProvider, (prev, next) {
      next.whenData((authState) {
        if (authState.event == AuthChangeEvent.signedIn) {
          final userId = authState.session?.user.id;
          if (userId != null) _onLogin(userId);
        }
      });
    });

    ref.listen<AsyncValue<List<ConnectivityResult>>>(
      connectivityStreamProvider,
      (prev, next) {
        next.whenData((results) {
          final hasConnection = results.any(
            (r) => r != ConnectivityResult.none,
          );
          if (hasConnection) push();
        });
      },
    );
  }

  Future<void> push() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;
    final service = ref.read(syncServiceProvider);
    if (service == null) return;
    try {
      await service.pushPendingChanges(userId);
    } catch (_) {
      // Silent fail — will retry on next push trigger
    }
  }

  Future<void> _onLogin(String userId) async {
    final service = ref.read(syncServiceProvider);
    if (service == null) return;
    try {
      await service.pullUserProgress(userId);
      await service.pushPendingChanges(userId);
    } catch (_) {}
  }
}
