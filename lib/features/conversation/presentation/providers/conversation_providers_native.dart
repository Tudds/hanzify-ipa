import '../../../../core/database/app_database.dart';
import '../../data/datasources/conversation_local_datasource.dart';
import '../../data/datasources/conversation_local_datasource_impl.dart';

ConversationLocalDataSource createNativeDataSource(AppDatabase db) {
  return ConversationLocalDataSourceImpl(db);
}
