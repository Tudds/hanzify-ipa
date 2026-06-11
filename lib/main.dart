import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/hanzify_app.dart';
import 'core/config/supabase_config.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/sync/learning_sync_service.dart';
import 'core/sync/learning_sync_trigger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // supabase_flutter 2.14 đổi tên anonKey -> publishableKey; legacy anon
      // key (JWT) vẫn dùng được qua tham số này.
      publishableKey: SupabaseConfig.anonKey,
    );
    LearningSyncTrigger.configure(() async {
      if (Supabase.instance.client.auth.currentUser == null) return;
      await LearningSyncService.supabase().sync();
    });
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      LearningSyncTrigger.request();
    });
    LearningSyncTrigger.request();
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const HanzifyApp(),
    ),
  );
}
