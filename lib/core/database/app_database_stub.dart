// Stub AppDatabase for web platform.
// Provides only the type so code-gen / providers can reference it.
// On web, appDatabaseProvider is never actually used — it's overridden
// in main.dart with VocabWebDataSourceImpl instead.

class AppDatabase {
  AppDatabase() {
    throw UnsupportedError(
      'AppDatabase (native drift) is not available on the web platform.',
    );
  }
}
