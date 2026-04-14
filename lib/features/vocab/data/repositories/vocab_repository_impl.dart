import '../../domain/entities/vocab.dart';
import '../../domain/repositories/vocab_repository.dart';
import '../datasources/vocab_local_datasource.dart';


class VocabRepositoryImpl implements VocabRepository {
  final VocabLocalDataSource localDataSource;
  VocabRepositoryImpl(this.localDataSource);

  @override
  Future<List<Vocab>> getAll() async {
    return await localDataSource.getAll();
  }

  @override
  Future<List<Vocab>> getDue() async {
    return await localDataSource.getDue();
  }

  @override
  Future<List<Vocab>> getByLevel(int level) async {
    return await localDataSource.getByLevel(level);
  }

  @override
  Future<void> update(Vocab vocab) async {
    await localDataSource.update(vocab);
  }

  @override
  Future<void> save(Vocab vocab) async {
    await localDataSource.insert(vocab);
  }

  @override
  Future<List<Vocab>> search(
    String query, {
    int? hskLevel,
    String? wordType,
  }) async {
    return await localDataSource.search(
      query,
      hskLevel: hskLevel,
      wordType: wordType,
    );
  }

  @override
  Future<void> reseed() async {
    await localDataSource.reseed();
  }
}
