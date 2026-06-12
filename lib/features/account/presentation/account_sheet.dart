import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/sync/learning_sync_trigger.dart';
import '../../../core/sync/sync_status_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hanzify_haptic.dart';

/// Bottom sheet tài khoản + trạng thái đồng bộ. Chỉ mở được khi Supabase
/// đã cấu hình (entry point tự ẩn khi không cấu hình).
Future<void> showAccountSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
    ),
    builder: (context) => const AccountSheet(),
  );
}

class AccountSheet extends ConsumerWidget {
  const AccountSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tài khoản', style: context.text.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          if (user == null)
            const _SignedOutView()
          else
            _SignedInView(email: user.email ?? 'Đã đăng nhập'),
        ],
      ),
    );
  }
}

class _SignedOutView extends ConsumerWidget {
  const _SignedOutView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Đăng nhập để đồng bộ tiến độ học và lịch ôn tập trên nhiều thiết bị.',
          style: context.text.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: () {
            HanzifyHaptic.light();
            ref.read(authServiceProvider).signInWithGoogle();
          },
          icon: const Icon(Icons.login_rounded),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.button),
            ),
          ),
          label: const Text('Đăng nhập với Google'),
        ),
      ],
    );
  }
}

class _SignedInView extends ConsumerWidget {
  const _SignedInView({required this.email});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final sync = ref.watch(syncStatusProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              child: Icon(Icons.person_rounded, color: colors.onPrimaryContainer),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                email,
                style: context.text.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Icon(_syncIcon(sync.status), size: 18, color: _syncColor(context, sync.status)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _syncLabel(sync),
                style: context.text.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.tonal(
          onPressed: sync.status == SyncStatus.syncing
              ? null
              : () {
                  HanzifyHaptic.selection();
                  LearningSyncTrigger.request();
                },
          child: const Text('Đồng bộ ngay'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () {
            HanzifyHaptic.selection();
            ref.read(authServiceProvider).signOut();
            Navigator.of(context).pop();
          },
          child: Text('Đăng xuất', style: TextStyle(color: colors.error)),
        ),
      ],
    );
  }

  IconData _syncIcon(SyncStatus status) => switch (status) {
    SyncStatus.syncing => Icons.sync_rounded,
    SyncStatus.ok => Icons.cloud_done_rounded,
    SyncStatus.error => Icons.cloud_off_rounded,
    SyncStatus.idle => Icons.cloud_outlined,
  };

  Color _syncColor(BuildContext context, SyncStatus status) => switch (status) {
    SyncStatus.ok => context.semantic.success,
    SyncStatus.error => context.semantic.danger,
    _ => context.colors.onSurfaceVariant,
  };

  String _syncLabel(SyncStatusState sync) {
    switch (sync.status) {
      case SyncStatus.syncing:
        return 'Đang đồng bộ...';
      case SyncStatus.ok:
        final at = sync.lastSyncedAt;
        if (at == null) return 'Đã đồng bộ.';
        final hh = at.hour.toString().padLeft(2, '0');
        final mm = at.minute.toString().padLeft(2, '0');
        return 'Đã đồng bộ lúc $hh:$mm';
      case SyncStatus.error:
        return 'Lỗi đồng bộ: ${sync.lastError ?? 'không rõ'}';
      case SyncStatus.idle:
        return 'Chưa đồng bộ trong phiên này.';
    }
  }
}
