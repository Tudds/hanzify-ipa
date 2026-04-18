import '../../../vocab/domain/entities/vocab.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../../../../core/error/failures.dart';
import '../datasources/character_local_datasource.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterLocalDataSource localDataSource;
  CharacterRepositoryImpl(this.localDataSource);

  @override
  Future<Character?> getByChar(String char) async {
    try {
      return await localDataSource.getByChar(char);
    } catch (e) {
      throw DatabaseFailure('Failed to load character: $e');
    }
  }

  @override
  Future<List<Vocab>> getVocabContainingChar(String char) async {
    try {
      return await localDataSource.getVocabContainingChar(char);
    } catch (e) {
      throw DatabaseFailure('Failed to load vocab containing character: $e');
    }
  }
}
