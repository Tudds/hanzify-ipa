import '../../../vocab/domain/entities/vocab.dart';
import '../entities/character.dart';

/// Repository interface cho Character feature.
abstract class CharacterRepository {
  /// Lấy thông tin chi tiết của một chữ Hán.
  Future<Character?> getByChar(String char);

  /// Lấy danh sách vocab chứa ký tự cho trước.
  Future<List<Vocab>> getVocabContainingChar(String char);
}
