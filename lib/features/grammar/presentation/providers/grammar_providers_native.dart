import '../../../../core/database/app_database.dart';
import '../../data/datasources/grammar_local_datasource.dart';
import '../../data/datasources/grammar_local_datasource_impl.dart';

GrammarLocalDataSource createNativeDataSource(AppDatabase db) {
  return GrammarLocalDataSourceImpl(db);
}
