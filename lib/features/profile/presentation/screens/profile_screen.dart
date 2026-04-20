import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import 'package:hanzify/core/widgets/hanzify_stat_card.dart';
import 'package:hanzify/core/widgets/hanzify_screen_header.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/profile/presentation/providers/profile_stats_provider.dart';
import 'package:hanzify/core/providers/auth_provider.dart';
import 'package:hanzify/core/providers/guest_mode_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hanzify/core/providers/performance_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final themeMode = ref.watch(themeProvider);
    final allVocab = ref.watch(allVocabProvider);
    final stats = ref.watch(profileStatsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const HanzifyScreenHeader(
            title: 'Cá Nhân',
            showAvatar: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildUserCard(cs, theme, ref),
                  const SizedBox(height: 32),
                  const HanzifySectionHeader(title: 'Thống kê học tập', icon: Icons.bar_chart_rounded),
                  HanzifyStatCard.horizontal(
                    icon: Icons.menu_book_rounded,
                    value: allVocab.when(data: (list) => '${list.length}', loading: () => '...', error: (_, _) => '0'),
                    label: 'Tổng số từ',
                  ),
                  const SizedBox(height: 12),
                  HanzifyStatCard.horizontal(
                    icon: Icons.local_fire_department_rounded,
                    value: stats.streakDays > 0 ? '${stats.streakDays}' : '0',
                    label: 'Ngày liên tiếp',
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  HanzifyStatCard.horizontal(
                    icon: Icons.workspace_premium_rounded,
                    value: stats.dominantHskLevel > 0 ? 'HSK ${stats.dominantHskLevel}' : '—',
                    label: 'Cấp độ HSK',
                  ),
                  const SizedBox(height: 32),
                  const HanzifySectionHeader(title: 'Cài đặt', icon: Icons.tune_rounded),
                  Card.filled(
                    color: cs.surfaceContainerLow,
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildSettingsTile(cs, theme, icon: Icons.shield_outlined, title: 'Cài đặt tài khoản'),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsTile(cs, theme, icon: Icons.notifications_outlined, title: 'Thông báo'),
                        const Divider(height: 1, indent: 56),
                        _buildThemeTile(cs, theme, themeMode, ref),
                        const Divider(height: 1, indent: 56),
                        _buildPerformanceTile(cs, theme, ref),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsTile(cs, theme, icon: Icons.help_outline_rounded, title: 'Hỗ trợ & Góp ý'),
                        const Divider(height: 1, indent: 56),
                        _buildAuthTile(cs, theme, ref),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const HanzifySectionHeader(title: 'Thành tựu', icon: Icons.emoji_events_rounded),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildAchievementBadge(cs, theme, Icons.lock_rounded, 'Mở khoá'),
                        _buildAchievementBadge(cs, theme, Icons.emoji_events_rounded, 'Vô địch'),
                        _buildAchievementBadge(cs, theme, Icons.star_rounded, 'Ngôi sao'),
                        _buildAchievementBadge(cs, theme, Icons.lock_rounded, 'Bí ẩn'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(ColorScheme cs, ThemeData theme, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isGuest = ref.watch(guestModeProvider);
    final isGuestOnly = user == null && isGuest;

    final displayName = isGuestOnly ? 'Khách' : (user?.userMetadata?['name'] as String? ?? user?.email?.split('@').first ?? 'Người dùng');
    final email = user?.email ?? '';
    final createdAt = user?.createdAt != null ? DateTime.parse(user!.createdAt) : null;
    final joinLabel = isGuestOnly ? 'Tiến trình chỉ lưu trên máy' : (createdAt != null ? 'Tham gia từ T${createdAt.month}/${createdAt.year}' : '');

    return Card.filled(
      color: cs.primaryContainer.withValues(alpha: 0.2),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: cs.primary,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(displayName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            if (email.isNotEmpty) Text(email, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(joinLabel, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: () async {
                if (isGuestOnly) await ref.read(guestModeProvider.notifier).disable();
              },
              icon: Icon(isGuestOnly ? Icons.login_rounded : Icons.edit_rounded, size: 18),
              label: Text(isGuestOnly ? 'Đăng nhập để đồng bộ' : 'Chỉnh sửa hồ sơ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(ColorScheme cs, ThemeData theme, {required IconData icon, required String title, Color? titleColor, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: titleColor)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildAuthTile(ColorScheme cs, ThemeData theme, WidgetRef ref) {
    final isGuest = ref.watch(guestModeProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null && isGuest) {
      return _buildSettingsTile(cs, theme, icon: Icons.login_rounded, title: 'Đăng nhập / Đăng ký', titleColor: cs.primary, onTap: () async => await ref.read(guestModeProvider.notifier).disable());
    }

    return ListTile(
      leading: Icon(Icons.logout_rounded, color: cs.error),
      title: Text('Đăng xuất', style: theme.textTheme.bodyLarge?.copyWith(color: cs.error)),
      onTap: () async => await Supabase.instance.client.auth.signOut(),
    );
  }

  Widget _buildPerformanceTile(ColorScheme cs, ThemeData theme, WidgetRef ref) {
    final isReduced = ref.watch(performanceProvider);
    return SwitchListTile(
      secondary: Icon(Icons.speed_rounded, color: cs.primary),
      title: const Text('Tối ưu hiệu năng'),
      subtitle: Text(isReduced ? 'Đã tắt bớt hiệu ứng' : 'Đang bật đầy đủ hiệu ứng'),
      value: isReduced,
      onChanged: (_) => ref.read(performanceProvider.notifier).toggle(),
    );
  }

  Widget _buildThemeTile(ColorScheme cs, ThemeData theme, AppThemeMode themeMode, WidgetRef ref) {
    final themeLabel = switch (themeMode) {
      AppThemeMode.dark => 'Tối',
      AppThemeMode.light => 'Sáng',
      AppThemeMode.sepia => 'Sepia'
    };
    final icon = switch (themeMode) {
      AppThemeMode.light => Icons.wb_sunny_rounded,
      AppThemeMode.dark => Icons.nightlight_round,
      AppThemeMode.sepia => Icons.auto_stories_rounded,
    };
    final color = switch (themeMode) {
      AppThemeMode.light => const Color(0xFFF59E0B),
      AppThemeMode.dark => const Color(0xFF818CF8),
      AppThemeMode.sepia => const Color(0xFFB45309),
    };

    return ListTile(
      leading: Icon(Icons.palette_outlined, color: cs.primary),
      title: Text('Giao diện ($themeLabel)'),
      trailing: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween(begin: 0.75, end: 1.0).animate(anim),
            child: ScaleTransition(scale: anim, child: child),
          ),
          child: Icon(icon, key: ValueKey(themeMode), color: color, size: 20),
        ),
      ),
      onTap: () => ref.read(themeProvider.notifier).cycleTheme(),
    );
  }

  Widget _buildAchievementBadge(ColorScheme cs, ThemeData theme, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: cs.surfaceContainerHigh, shape: BoxShape.circle),
            child: Icon(icon, color: cs.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
