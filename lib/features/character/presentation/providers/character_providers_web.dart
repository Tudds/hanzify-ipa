// Stub file for conditional import — used on web where native drift is unavailable.
// ignore_for_file: unused_element

import '../../data/datasources/character_local_datasource.dart';

/// Stub: This should never actually be called on web.
/// The provider is overridden in platform_web.dart with CharacterWebDataSourceImpl.
CharacterLocalDataSource createNativeDataSource(dynamic ref) {
  throw UnsupportedError(
    'Native datasource is not available on the web platform. '
    'Make sure characterLocalDataSourceProvider is overridden.',
  );
}
