import '../entities/vocab.dart';
import '../repositories/vocab_repository.dart';

class GetVocab {
  final VocabRepository repository;

  GetVocab(this.repository);

  Future<List<Vocab>> call() async {
    return await repository.getAll();
  }
}
