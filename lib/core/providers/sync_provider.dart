import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/sync_service.dart';
import '../services/sync_web_service.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

part 'sync_provider.g.dart';

/// SyncService cho native (Drift DB). Null trên web.
@Riverpod(keepAlive: true)
SyncService? syncService(Ref ref) {
  if (kIsWeb) return null;
  final db = ref.watch(appDatabaseProvider);
  return SyncService(db);
}

/// SyncWebService cho web. Null trên native.
@Riverpod(keepAlive: true)
SyncWebService? syncWebService(Ref ref) {
  if (!kIsWeb) return null;
  return SyncWebService();
}

@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivityStream(Ref ref) =>
    Connectivity().onConnectivityChanged;

/// Reacts to auth events (pull on login) and connectivity (push on reconnect).
/// Hoạt động trên cả native và web.
@Riverpod(keepAlive: true)
class SyncNotifier extends _$SyncNotifier {
  @override
  void build() {
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

  /// Push pending changes (vocab + grammar) lên Supabase.
  Future<void> push() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    try {
      if (kIsWeb) {
        // Web: không có pending queue — mỗi change được push ngay lập tức
        // trong update() của web datasource. Method này chỉ là no-op trên web.
        return;
      }

      final service = ref.read(syncServiceProvider);
      if (service == null) return;
      await service.pushPendingChanges(userId);
    } catch (e) {
      debugPrint('[Sync] Push failed: $e');
      // Silent fail — will retry on next push trigger
    }
  }

  Future<void> _onLogin(String userId) async {
    try {
      if (kIsWeb) {
        // Web: pull chỉ xảy ra khi init datasource (xem platform_web.dart)
        return;
      }

      final service = ref.read(syncServiceProvider);
      if (service == null) return;
      await service.pullUserProgress(userId);
      await service.pushPendingChanges(userId);
    } catch (e) {
      debugPrint('[Sync] Login sync failed: $e');
    }
  }
}
