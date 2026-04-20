import '../entities/vocab.dart';

abstract class VocabRepository {
  Future<List<Vocab>> getAll();
  Future<List<Vocab>> getDue();
  Future<List<Vocab>> getNew();
  Future<List<Vocab>> getByLevel(int level);
  Future<void> update(Vocab vocab);
  Future<void> save(Vocab vocab);
  Future<List<Vocab>> search(
    String query, {
    int? hskLevel,
    String? wordType,
  });
  Future<List<Vocab>> getByIds(List<String> ids);
  Future<void> reseed();
}
