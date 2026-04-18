// Main app entry — native (mobile/desktop) platform.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database_stub.dart'
    if (dart.library.io) '../database/app_database.dart';
import '../providers/database_provider.dart';
import '../config/supabase_config.dart';

Future<Widget> createProviderScope(Widget child) async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final db = AppDatabase();
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: child,
  );
}
