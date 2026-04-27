// ignore_for_file: unused_element

import '../../data/datasources/conversation_local_datasource.dart';

ConversationLocalDataSource createNativeDataSource(dynamic ref) {
  throw UnsupportedError(
    'Native datasource is not available on the web platform. '
    'Make sure conversationLocalDataSourceProvider is overridden.',
  );
}
