import '../../../vocab/domain/entities/vocab.dart';
import '../../domain/entities/character.dart';

/// Abstract data source cho Character feature.
abstract class CharacterLocalDataSource {
  /// Lấy thông tin chi tiết của một chữ Hán.
  Future<Character?> getByChar(String char);

  /// Lấy danh sách vocab chứa ký tự cho trước.
  Future<List<Vocab>> getVocabContainingChar(String char);
}
