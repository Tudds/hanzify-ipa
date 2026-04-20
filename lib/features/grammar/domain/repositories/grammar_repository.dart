import '../entities/grammar_point.dart';

/// Repository interface cho Grammar feature.
abstract class GrammarRepository {
  Future<List<GrammarPoint>> getAll();
  Future<GrammarPoint?> getById(String id);
  Future<List<GrammarPoint>> getByLevel(int level);
  Future<List<GrammarPoint>> getByCategory(String category);
  Future<List<GrammarPoint>> search(String query);
  Future<List<GrammarPoint>> getByIds(List<String> ids);
  Future<void> update(GrammarPoint grammar);
}
