import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/vocab/data/datasources/vocab_web_datasource_impl.dart';
import '../../features/vocab/presentation/providers/vocab_providers.dart';
import '../../features/grammar/data/datasources/grammar_web_datasource_impl.dart';
import '../../features/grammar/presentation/providers/grammar_providers.dart';
import '../../features/conversation/data/datasources/conversation_web_datasource_impl.dart';
import '../../features/conversation/presentation/providers/conversation_providers.dart';
import '../../features/character/data/datasources/character_web_datasource_impl.dart';
import '../../features/character/presentation/providers/character_providers.dart';
import '../config/supabase_config.dart';

Future<Widget> createProviderScope(Widget child) async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final webDs = await VocabWebDataSourceImpl.init();
  final grammarWebDs = await GrammarWebDataSourceImpl.init();
  final convWebDs = await ConversationWebDataSourceImpl.init();
  final charWebDs = await CharacterWebDataSourceImpl.init(vocabWebDs: webDs);

  return ProviderScope(
    overrides: [
      vocabLocalDataSourceProvider.overrideWithValue(webDs),
      grammarLocalDataSourceProvider.overrideWithValue(grammarWebDs),
      conversationLocalDataSourceProvider.overrideWithValue(convWebDs),
      characterLocalDataSourceProvider.overrideWithValue(charWebDs),
    ],
    child: child,
  );
}
