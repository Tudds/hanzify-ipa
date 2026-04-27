// ignore_for_file: unused_element

import '../../data/datasources/grammar_local_datasource.dart';

GrammarLocalDataSource createNativeDataSource(dynamic ref) {
  throw UnsupportedError(
    'Native datasource is not available on the web platform. '
    'Make sure grammarLocalDataSourceProvider is overridden.',
  );
}
