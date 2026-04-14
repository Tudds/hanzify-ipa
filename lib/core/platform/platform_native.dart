// Main app entry — native (mobile/desktop) platform.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database_stub.dart'
    if (dart.library.io) '../../core/database/app_database.dart';
import '../../features/vocab/presentation/providers/vocab_providers.dart';

Future<Widget> createProviderScope(Widget child) async {
  final db = AppDatabase();
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: child,
  );
}
