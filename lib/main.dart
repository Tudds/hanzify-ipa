import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/hanzify_app.dart';
import 'core/config/supabase_config.dart';
import 'core/sync/learning_sync_service.dart';
import 'core/sync/learning_sync_trigger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
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

  runApp(const ProviderScope(child: HanzifyApp()));
}
