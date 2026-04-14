// Stub file for conditional import — used on web where native drift is unavailable.
// ignore_for_file: unused_element

import '../../data/datasources/vocab_local_datasource.dart';

/// Stub: This should never actually be called on web.
/// The provider is overridden in main.dart with VocabWebDataSourceImpl.
VocabLocalDataSource createNativeDataSource(dynamic ref) {
  throw UnsupportedError(
    'Native datasource is not available on the web platform. '
    'Make sure vocabLocalDataSourceProvider is overridden in main.dart.',
  );
}
