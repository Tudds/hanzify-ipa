import 'package:flutter/material.dart';

import 'app_router.dart';
import '../core/theme/app_theme.dart';

class HanzifyApp extends StatelessWidget {
  const HanzifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hanzify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
