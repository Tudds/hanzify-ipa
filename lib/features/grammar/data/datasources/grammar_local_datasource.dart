import '../../domain/entities/grammar_point.dart';

/// Abstract data source cho Grammar feature.
abstract class GrammarLocalDataSource {
  /// Lấy toàn bộ grammar points, sắp xếp theo level rồi id.
  Future<List<GrammarPoint>> getAll({int limit = 0, int offset = 0});

  /// Lấy grammar point theo id.
  Future<GrammarPoint?> getById(String id);

  /// Lấy grammar points theo HSK level.
  Future<List<GrammarPoint>> getByLevel(int level, {int limit = 0, int offset = 0});

  /// Lấy grammar points theo category.
  Future<List<GrammarPoint>> getByCategory(String category, {int limit = 0, int offset = 0});

  /// Tìm kiếm grammar theo title hoặc structure.
  Future<List<GrammarPoint>> search(String query, {int limit = 0, int offset = 0});

  /// Đếm tổng số grammar points.
  Future<int> count();

  /// Cập nhật grammar point (bookmark, mastered).
  Future<void> update(GrammarPoint grammar);
}
