import '../../domain/entities/vocab.dart';
import '../../domain/repositories/vocab_repository.dart';
import '../../../../core/error/failures.dart';
import '../datasources/vocab_local_datasource.dart';

class VocabRepositoryImpl implements VocabRepository {
  final VocabLocalDataSource localDataSource;
  VocabRepositoryImpl(this.localDataSource);

  @override
  Future<List<Vocab>> getAll() async {
    try {
      return await localDataSource.getAll();
    } catch (e) {
      throw DatabaseFailure('Failed to load vocab list: $e');
    }
  }

  @override
  Future<List<Vocab>> getDue() async {
    try {
      return await localDataSource.getDue();
    } catch (e) {
      throw DatabaseFailure('Failed to load due vocab: $e');
    }
  }

  @override
  Future<List<Vocab>> getNew() async {
    try {
      return await localDataSource.getNew();
    } catch (e) {
      throw DatabaseFailure('Failed to load new vocab: $e');
    }
  }

  @override
  Future<List<Vocab>> getByLevel(int level) async {
    try {
      return await localDataSource.getByLevel(level);
    } catch (e) {
      throw DatabaseFailure('Failed to load vocab by level: $e');
    }
  }

  @override
  Future<void> update(Vocab vocab) async {
    try {
      await localDataSource.update(vocab);
    } catch (e) {
      throw DatabaseFailure('Failed to update vocab: $e');
    }
  }

  @override
  Future<void> save(Vocab vocab) async {
    try {
      await localDataSource.insert(vocab);
    } catch (e) {
      throw DatabaseFailure('Failed to save vocab: $e');
    }
  }

  @override
  Future<List<Vocab>> search(
    String query, {
    int? hskLevel,
    String? wordType,
  }) async {
    try {
      return await localDataSource.search(
        query,
        hskLevel: hskLevel,
        wordType: wordType,
      );
    } catch (e) {
      throw DatabaseFailure('Failed to search vocab: $e');
    }
  }

  @override
  Future<List<Vocab>> getByIds(List<String> ids) async {
    try {
      final all = await localDataSource.getAll();
      final idSet = ids.toSet();
      return all.where((v) => idSet.contains(v.id)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to load vocab by ids: $e');
    }
  }

  @override
  Future<void> reseed() async {
    try {
      await localDataSource.reseed();
    } catch (e) {
      throw DatabaseFailure('Failed to reseed vocab: $e');
    }
  }
}
