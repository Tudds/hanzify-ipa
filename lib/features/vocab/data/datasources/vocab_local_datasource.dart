import '../../domain/entities/vocab.dart';

abstract class VocabLocalDataSource {
  Future<List<Vocab>> getAll();
  Future<List<Vocab>> getDue();
  Future<void> update(Vocab model);
  Future<void> insert(Vocab model);

  /// Tìm kiếm theo hanzi, pinyin (có và không dấu), hoặc nghĩa tiếng Việt.
  Future<List<Vocab>> search(
    String query, {
    int? hskLevel,
    String? wordType,
  });

  /// Lấy danh sách vocab theo HSK level.
  Future<List<Vocab>> getByLevel(int level);

  /// Nạp lại dữ liệu từ JSON vào Database.
  Future<void> reseed();
}
