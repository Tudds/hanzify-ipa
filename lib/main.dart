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
import 'core/sync/sync_status_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();

  // Container thủ công để bootstrap sync (chạy ngoài widget tree) vẫn cập
  // nhật được syncStatusProvider cho account sheet.
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    final syncService = LearningSyncService.supabase(
      observer: (phase, {error}) {
        final status = container.read(syncStatusProvider.notifier);
        switch (phase) {
          case LearningSyncPhase.started:
            status.markSyncing();
          case LearningSyncPhase.succeeded:
            status.markOk();
          case LearningSyncPhase.failed:
            status.markError(error ?? 'unknown');
        }
      },
    );
    // Service tự no-op khi chưa đăng nhập (hasUser guard).
    LearningSyncTrigger.configure(syncService.sync);
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      LearningSyncTrigger.request();
    });
    LearningSyncTrigger.request();
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const HanzifyApp()),
  );
}
