import 'package:flutter/material.dart';
import 'package:hanzify/core/navigation/app_routes.dart';

class AppNavigationDestination {
  const AppNavigationDestination({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const appPrimaryDestinations = [
  AppNavigationDestination(
    route: AppRoutes.home,
    label: 'Học tập',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  AppNavigationDestination(
    route: AppRoutes.vocabList,
    label: 'Từ điển',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
  ),
  AppNavigationDestination(
    route: AppRoutes.progress,
    label: 'Ôn tập',
    icon: Icons.bolt_outlined,
    selectedIcon: Icons.bolt_rounded,
  ),
  AppNavigationDestination(
    route: AppRoutes.profile,
    label: 'Cá nhân',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  ),
];

const appQuickActionDestinations = [
  AppNavigationDestination(
    route: AppRoutes.flashcard,
    label: 'Ôn tập',
    icon: Icons.bolt_rounded,
    selectedIcon: Icons.bolt_rounded,
  ),
  AppNavigationDestination(
    route: AppRoutes.grammar,
    label: 'Ngữ pháp',
    icon: Icons.menu_book_rounded,
    selectedIcon: Icons.menu_book_rounded,
  ),
  AppNavigationDestination(
    route: AppRoutes.quiz,
    label: 'Kiểm tra',
    icon: Icons.quiz_rounded,
    selectedIcon: Icons.quiz_rounded,
  ),
  AppNavigationDestination(
    route: AppRoutes.vocabList,
    label: 'Tra từ',
    icon: Icons.search_rounded,
    selectedIcon: Icons.search_rounded,
  ),
];
