import '../../domain/entities/vocab.dart';

abstract class VocabLocalDataSource {
  Future<List<Vocab>> getAll({int limit = 0, int offset = 0});
  Future<List<Vocab>> getDue({int limit = 0, int offset = 0});
  Future<List<Vocab>> getNew({int limit = 0, int offset = 0});
  Future<void> update(Vocab model);
  Future<void> insert(Vocab model);

  /// Tìm kiếm theo hanzi, pinyin (có và không dấu), hoặc nghĩa tiếng Việt.
  Future<List<Vocab>> search(
    String query, {
    int? hskLevel,
    String? wordType,
    int limit = 0,
    int offset = 0,
  });

  /// Lấy danh sách vocab theo HSK level.
  Future<List<Vocab>> getByLevel(int level, {int limit = 0, int offset = 0});

  /// Đếm tổng số vocab.
  Future<int> count();

  /// Nạp lại dữ liệu từ JSON vào Database.
  Future<void> reseed();
}
