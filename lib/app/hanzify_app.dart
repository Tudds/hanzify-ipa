import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/presentation/home_dashboard_screen.dart';

class HanzifyApp extends StatelessWidget {
  const HanzifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hanzify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeDashboardScreen(),
    );
  }
}
