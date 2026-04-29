import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_connection.dart';
import 'data/drift/drift_learning_progress_store.dart';
import 'learning_progress.dart';

class LearningProgressStore {
  const LearningProgressStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _unitsKey = 'hanzify.learning_path.units.v1';
  static final DriftLearningProgressStore _driftStore =
      DriftLearningProgressStore(openAppDatabase());

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ?? SharedPreferences.getInstance();

  Future<LearningProgressSnapshot> load() async {
    if (_preferences != null) return _loadSharedPreferences();
    try {
      return await _driftStore.load();
    } catch (_) {
      return _loadSharedPreferences();
    }
  }

  Future<void> save(LearningProgressSnapshot snapshot) async {
    if (_preferences != null) return _saveSharedPreferences(snapshot);
    try {
      await _driftStore.save(snapshot);
    } catch (_) {
      await _saveSharedPreferences(snapshot);
    }
  }

  Future<void> upsert(LearningUnitProgress progress) async {
    if (_preferences != null) return _upsertSharedPreferences(progress);
    try {
      await _driftStore.upsert(progress);
    } catch (_) {
      await _upsertSharedPreferences(progress);
    }
  }

  Future<void> clear() async {
    if (_preferences != null) return _clearSharedPreferences();
    try {
      await _driftStore.clear();
    } catch (_) {
      await _clearSharedPreferences();
    }
  }

  Future<LearningProgressSnapshot> _loadSharedPreferences() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_unitsKey);
    final units = <String, LearningUnitProgress>{};
    if (raw != null && raw.isNotEmpty) {
      final decoded = (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final json in decoded) {
        final progress = LearningUnitProgress.fromJson(json);
        units[progress.unitId] = progress;
      }
    }
    return LearningProgressSnapshot(units: units);
  }

  Future<void> _saveSharedPreferences(LearningProgressSnapshot snapshot) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(
      snapshot.units.values.map((unit) => unit.toJson()).toList(),
    );
    await prefs.setString(_unitsKey, encoded);
  }

  Future<void> _upsertSharedPreferences(LearningUnitProgress progress) async {
    final snapshot = await _loadSharedPreferences();
    final next = Map<String, LearningUnitProgress>.from(snapshot.units);
    next[progress.unitId] = progress;
    await _saveSharedPreferences(LearningProgressSnapshot(units: next));
  }

  Future<void> _clearSharedPreferences() async {
    final prefs = await _prefs;
    await prefs.remove(_unitsKey);
  }
}
