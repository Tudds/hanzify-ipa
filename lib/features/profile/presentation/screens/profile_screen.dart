import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
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
    final c = themeColorsOf(context);
    final themeMode = ref.watch(themeProvider);
    final allVocab = ref.watch(allVocabProvider);
    final stats = ref.watch(profileStatsProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          HanzifyScreenHeader(
            title: 'Cá Nhân',
            showAvatar: false,
            trailing: Icon(Icons.settings_outlined, color: c.text),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
            const SizedBox(height: AppSpacing.lg),

            // ── User Card ──────────────────────────────────────────────
            _buildUserCard(c, ref),

            const SizedBox(height: AppSpacing.xl),

            // ── Statistics Section ──────────────────────────────────────
            HanzifySectionHeader(
              title: 'Thống kê học tập',
              icon: Icons.bar_chart_rounded,
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            ),

            HanzifyStatCard.horizontal(
              colors: c,
              icon: Icons.menu_book_rounded,
              value: allVocab.when(
                data: (list) => '${list.length}',
                loading: () => '...',
                error: (_, _) => '0',
              ),
              label: 'TỔNG SỐ TỪ',
              iconColor: c.primary,
            ),

            HanzifyStatCard.horizontal(
              colors: c,
              icon: Icons.local_fire_department_rounded,
              value: stats.streakDays > 0 ? '${stats.streakDays}' : '0',
              label: 'NGÀY LIÊN TIẾP',
              iconColor: Colors.white,
              gradient: c.successGradient,
              textColor: Colors.white,
            ),

            HanzifyStatCard.horizontal(
              colors: c,
              icon: Icons.workspace_premium_rounded,
              value: stats.dominantHskLevel > 0 ? 'HSK ${stats.dominantHskLevel}' : '—',
              label: 'CẤP ĐỘ HSK',
              iconColor: c.primary,
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Settings List ──────────────────────────────────────────
            HanzifySectionHeader(
              title: 'Cài đặt',
              icon: Icons.tune_rounded,
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            ),

            HanzifyCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsTile(
                    c: c,
                    icon: Icons.shield_outlined,
                    title: 'Cài đặt tài khoản',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: c.outlineVariant.withValues(alpha: 0.3)),
                  _buildSettingsTile(
                    c: c,
                    icon: Icons.notifications_outlined,
                    title: 'Thông báo',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: c.outlineVariant.withValues(alpha: 0.3)),
                  _buildThemeTile(c, themeMode, ref),
                  Divider(height: 1, color: c.outlineVariant.withValues(alpha: 0.3)),
                  _buildPerformanceTile(c, ref),
                  Divider(height: 1, color: c.outlineVariant.withValues(alpha: 0.3)),
                  _buildSettingsTile(
                    c: c,
                    icon: Icons.help_outline_rounded,
                    title: 'Hỗ trợ & Góp ý',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: c.outlineVariant.withValues(alpha: 0.3)),
                  Consumer(
                    builder: (context, ref, _) {
                      final isGuest = ref.watch(guestModeProvider);
                      final user = ref.watch(currentUserProvider);
                      if (user == null && isGuest) {
                        return _buildSettingsTile(
                          c: c,
                          icon: Icons.login_rounded,
                          title: 'Đăng nhập / Đăng ký',
                          titleColor: c.primary,
                          iconColor: c.primary,
                          onTap: () async {
                            await ref.read(guestModeProvider.notifier).disable();
                          },
                        );
                      }
                      return _buildSettingsTile(
                        c: c,
                        icon: Icons.logout_rounded,
                        title: 'Đăng xuất',
                        titleColor: c.error,
                        iconColor: c.error,
                        showChevron: false,
                        onTap: () async {
                          await Supabase.instance.client.auth.signOut();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Achievements Section ───────────────────────────────────
            HanzifySectionHeader(
              title: 'Thành tựu',
              icon: Icons.emoji_events_rounded,
              trailing: GestureDetector(
                onTap: () {},
                child: Text(
                  'Xem tất cả',
                  style: AppTypography.label(
                    fontSize: AppFontSizes.labelMd,
                    color: c.primary,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            ),

            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAchievementBadge(c, Icons.lock_rounded, 'Mở khoá'),
                  _buildAchievementBadge(c, Icons.emoji_events_rounded, 'Vô địch'),
                  _buildAchievementBadge(c, Icons.star_rounded, 'Ngôi sao'),
                  _buildAchievementBadge(c, Icons.lock_rounded, 'Bí ẩn'),
                  _buildAchievementBadge(c, Icons.lock_rounded, 'Bí ẩn'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.scrollBottom),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── User Card ──────────────────────────────────────────────────────────────

  Widget _buildUserCard(AppThemeColors c, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isGuest = ref.watch(guestModeProvider);
    final isGuestOnly = user == null && isGuest;

    final displayName = isGuestOnly
        ? 'Khách'
        : (user?.userMetadata?['name'] as String? ??
            user?.email?.split('@').first ??
            'Người dùng');
    final email = user?.email ?? '';
    final createdAt = user?.createdAt != null
        ? DateTime.parse(user!.createdAt)
        : null;
    final joinLabel = isGuestOnly
        ? 'Tiến trình chỉ lưu trên máy'
        : (createdAt != null
            ? 'Tham gia từ T${createdAt.month}/${createdAt.year}'
            : '');

    return HanzifyCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: c.primaryContainer,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: AppTypography.headline(
                fontSize: AppFontSizes.headlineLg,
                color: c.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            displayName,
            style: AppTypography.headline(
              fontSize: AppFontSizes.headlineMd,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              email,
              style: AppTypography.body(fontSize: AppFontSizes.bodySm, color: c.placeholder),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            joinLabel,
            style: AppTypography.body(
              fontSize: AppFontSizes.bodySm,
              color: c.placeholder,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: () async {
              if (isGuestOnly) {
                await ref.read(guestModeProvider.notifier).disable();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGuestOnly ? Icons.login_rounded : Icons.edit_rounded,
                    size: 16,
                    color: c.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    isGuestOnly ? 'Đăng nhập để đồng bộ' : 'Chỉnh sửa hồ sơ',
                    style: AppTypography.label(
                      fontSize: AppFontSizes.labelMd,
                      fontWeight: FontWeight.w600,
                      color: c.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Settings Tile ──────────────────────────────────────────────────────────

  Widget _buildSettingsTile({
    required AppThemeColors c,
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? iconColor,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? c.onSurfaceVariant),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                title,
                style: AppTypography.body(
                  fontSize: AppFontSizes.bodyMd,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? c.text,
                ),
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: c.placeholder,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTile(AppThemeColors c, WidgetRef ref) {
    final isReduced = ref.watch(performanceProvider);

    return InkWell(
      onTap: () => ref.read(performanceProvider.notifier).toggle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Icon(Icons.speed_rounded, size: 22, color: c.onSurfaceVariant),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tối ưu hiệu năng',
                    style: AppTypography.body(
                      fontSize: AppFontSizes.bodyMd,
                      fontWeight: FontWeight.w500,
                      color: c.text,
                    ),
                  ),
                  Text(
                    isReduced ? 'Đã tắt bớt hiệu ứng' : 'Đang bật đầy đủ hiệu ứng',
                    style: AppTypography.body(
                      fontSize: AppFontSizes.bodySm,
                      color: c.placeholder,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isReduced,
              activeTrackColor: c.primary,
              onChanged: (_) => ref.read(performanceProvider.notifier).toggle(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Theme Toggle Tile ──────────────────────────────────────────────────────

  Widget _buildThemeTile(
    AppThemeColors c,
    AppThemeMode themeMode,
    WidgetRef ref,
  ) {
    final themeLabel = switch (themeMode) {
      AppThemeMode.dark => 'Tối',
      AppThemeMode.light => 'Sáng',
      AppThemeMode.sepia => 'Sepia',
    };

    return InkWell(
      onTap: () => ref.read(themeProvider.notifier).cycleTheme(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Icon(Icons.palette_outlined, size: 22, color: c.onSurfaceVariant),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                'Giao diện ($themeLabel)',
                style: AppTypography.body(
                  fontSize: AppFontSizes.bodyMd,
                  fontWeight: FontWeight.w500,
                  color: c.text,
                ),
              ),
            ),
            Switch(
              value: themeMode == AppThemeMode.dark,
              activeTrackColor: c.primary,
              onChanged: (_) =>
                  ref.read(themeProvider.notifier).cycleTheme(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Achievement Badge ──────────────────────────────────────────────────────

  Widget _buildAchievementBadge(
    AppThemeColors c,
    IconData icon,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: c.surfaceLow,
            child: Icon(icon, size: 26, color: c.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.label(
              fontSize: AppFontSizes.labelSm,
              color: c.placeholder,
            ),
          ),
        ],
      ),
    );
  }
}
