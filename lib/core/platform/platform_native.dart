// Main app entry — native (mobile/desktop) platform.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database_stub.dart'
    if (dart.library.io) '../database/app_database.dart';
import '../providers/database_provider.dart';

Future<Widget> createProviderScope(Widget child) async {
  final db = AppDatabase();
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: child,
  );
}
