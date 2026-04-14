import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/vocab/data/datasources/vocab_web_datasource_impl.dart';
import '../../features/vocab/presentation/providers/vocab_providers.dart';

Future<Widget> createProviderScope(Widget child) async {
  final webDs = await VocabWebDataSourceImpl.init();
  return ProviderScope(
    overrides: [
      vocabLocalDataSourceProvider.overrideWithValue(webDs),
    ],
    child: child,
  );
}
