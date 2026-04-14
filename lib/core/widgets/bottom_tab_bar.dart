import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppTab {
  final String key;
  final String label;
  final String icon;
  const AppTab({required this.key, required this.label, required this.icon});
}

const _tabs = [
  AppTab(key: 'home', label: 'Home', icon: '🏠'),
  AppTab(key: 'vocabList', label: 'Dictionary', icon: '📖'),
  AppTab(key: 'grammar', label: 'Grammar', icon: '📚'),
  AppTab(key: 'progress', label: 'Progress', icon: '📊'),
];

class BottomTabBarWidget extends StatelessWidget {
  final String currentScreen;
  final ValueChanged<String> onNavigate;
  final AppThemeColors colors;

  const BottomTabBarWidget({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
    required this.colors,
  });

  void _showQuickActions(BuildContext context, AppThemeColors c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.disabled.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('HÀNH ĐỘNG NHANH',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: c.placeholder)),
            const SizedBox(height: 24),

            _QuickActionTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Bài Hội Thoại',
              subtitle: 'Luyện đọc theo ngữ cảnh (Sắp ra mắt)',
              color: c.secondary,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng Bài Hội Thoại đang được phát triển! 🧘')),
                );
              },
            ),
            _QuickActionTile(
              icon: Icons.psychology_outlined,
              title: 'Quiz Ngẫu Nhiên',
              subtitle: 'Kiểm tra kiến thức nhanh 10 câu',
              color: c.primary,
              onTap: () {
                Navigator.pop(context);
                onNavigate('quiz');
              },
            ),
            _QuickActionTile(
              icon: Icons.star_border_rounded,
              title: 'Dấu Trang',
              subtitle: 'Xem lại các từ đã lưu',
              color: c.warning,
              onTap: () {
                Navigator.pop(context);
                onNavigate('vocabList');
              },
            ),
            _QuickActionTile(
              icon: Icons.bar_chart_rounded,
              title: 'Thống Kê Chi Tiết',
              subtitle: 'Theo dõi quá trình rèn luyện',
              color: c.accent,
              onTap: () {
                Navigator.pop(context);
                onNavigate('progress');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leftTabs = _tabs.sublist(0, 2);
    final rightTabs = _tabs.sublist(2, 4);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceLowest,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // Left tabs
                  ...leftTabs.map((tab) => _buildTabItem(tab)),

                  // Spacer for FAB
                  const SizedBox(width: 80),

                  // Right tabs
                  ...rightTabs.map((tab) => _buildTabItem(tab)),
                ],
              ),
            ),

            // Center Floating Action Button
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _showQuickActions(context, colors),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(AppTab tab) {
    final isActive = currentScreen == tab.key;
    return Expanded(
      child: GestureDetector(
        onTap: () => onNavigate(tab.key),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? colors.secondaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(tab.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? colors.primary : colors.placeholder,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.12), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.4), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
