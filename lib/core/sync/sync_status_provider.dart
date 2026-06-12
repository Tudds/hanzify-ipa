import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncStatus { idle, syncing, ok, error }

class SyncStatusState {
  const SyncStatusState({
    this.status = SyncStatus.idle,
    this.lastSyncedAt,
    this.lastError,
  });

  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final String? lastError;
}

/// Trạng thái đồng bộ hiển thị trong account sheet. Được cập nhật từ
/// observer của [LearningSyncService] (wire trong `main.dart`).
class SyncStatusNotifier extends Notifier<SyncStatusState> {
  @override
  SyncStatusState build() => const SyncStatusState();

  void markSyncing() {
    state = SyncStatusState(
      status: SyncStatus.syncing,
      lastSyncedAt: state.lastSyncedAt,
    );
  }

  void markOk() {
    state = SyncStatusState(status: SyncStatus.ok, lastSyncedAt: DateTime.now());
  }

  void markError(String error) {
    state = SyncStatusState(
      status: SyncStatus.error,
      lastSyncedAt: state.lastSyncedAt,
      lastError: error,
    );
  }
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncStatusState>(
  SyncStatusNotifier.new,
);
