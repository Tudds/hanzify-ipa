import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/vocab/data/datasources/vocab_web_datasource_impl.dart';
import '../../features/vocab/presentation/providers/vocab_providers.dart';
import '../config/supabase_config.dart';

Future<Widget> createProviderScope(Widget child) async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final webDs = await VocabWebDataSourceImpl.init();
  return ProviderScope(
    overrides: [
      vocabLocalDataSourceProvider.overrideWithValue(webDs),
    ],
    child: child,
  );
}
