import '../../domain/entities/conversation_context.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../../../core/error/failures.dart';
import '../datasources/conversation_local_datasource.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationLocalDataSource localDataSource;
  ConversationRepositoryImpl(this.localDataSource);

  @override
  Future<List<ConversationContext>> getAll() async {
    try {
      return await localDataSource.getAll();
    } catch (e) {
      throw DatabaseFailure('Failed to load conversation list: $e');
    }
  }

  @override
  Future<ConversationContext?> getById(String id) async {
    try {
      return await localDataSource.getById(id);
    } catch (e) {
      throw DatabaseFailure('Failed to load conversation by id: $e');
    }
  }

  @override
  Future<List<ConversationContext>> getByLevel(int level) async {
    try {
      return await localDataSource.getByLevel(level);
    } catch (e) {
      throw DatabaseFailure('Failed to load conversation by level: $e');
    }
  }

  @override
  Future<List<ConversationContext>> getByCategory(String category) async {
    try {
      return await localDataSource.getByCategory(category);
    } catch (e) {
      throw DatabaseFailure('Failed to load conversation by category: $e');
    }
  }

  @override
  Future<List<ConversationContext>> search(String query) async {
    try {
      return await localDataSource.search(query);
    } catch (e) {
      throw DatabaseFailure('Failed to search conversation: $e');
    }
  }

  @override
  Future<void> update(ConversationContext conversation) async {
    try {
      await localDataSource.update(conversation);
    } catch (e) {
      throw DatabaseFailure('Failed to update conversation: $e');
    }
  }
}
