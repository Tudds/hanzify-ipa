import '../../domain/entities/grammar_point.dart';
import '../../domain/repositories/grammar_repository.dart';
import '../../../../core/error/failures.dart';
import '../datasources/grammar_local_datasource.dart';

class GrammarRepositoryImpl implements GrammarRepository {
  final GrammarLocalDataSource localDataSource;
  GrammarRepositoryImpl(this.localDataSource);

  @override
  Future<List<GrammarPoint>> getAll() async {
    try {
      return await localDataSource.getAll();
    } catch (e) {
      throw DatabaseFailure('Failed to load grammar list: $e');
    }
  }

  @override
  Future<GrammarPoint?> getById(String id) async {
    try {
      return await localDataSource.getById(id);
    } catch (e) {
      throw DatabaseFailure('Failed to load grammar by id: $e');
    }
  }

  @override
  Future<List<GrammarPoint>> getByLevel(int level) async {
    try {
      return await localDataSource.getByLevel(level);
    } catch (e) {
      throw DatabaseFailure('Failed to load grammar by level: $e');
    }
  }

  @override
  Future<List<GrammarPoint>> getByCategory(String category) async {
    try {
      return await localDataSource.getByCategory(category);
    } catch (e) {
      throw DatabaseFailure('Failed to load grammar by category: $e');
    }
  }

  @override
  Future<List<GrammarPoint>> search(String query) async {
    try {
      return await localDataSource.search(query);
    } catch (e) {
      throw DatabaseFailure('Failed to search grammar: $e');
    }
  }

  @override
  Future<void> update(GrammarPoint grammar) async {
    try {
      await localDataSource.update(grammar);
    } catch (e) {
      throw DatabaseFailure('Failed to update grammar: $e');
    }
  }
}
