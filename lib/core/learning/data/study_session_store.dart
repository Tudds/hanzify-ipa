import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../database/database_connection.dart';
import '../application/study_session_controller.dart';
import '../domain/fsrs.dart';
import 'drift/drift_study_session_store.dart';
import 'srs_serialization.dart';

class StudySessionStore {
  const StudySessionStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _cardsKey = 'hanzify.study.cards.v1';
  static const _logsKey = 'hanzify.study.logs.v1';
  static final DriftStudySessionStore _driftStore = DriftStudySessionStore(
    openAppDatabase(),
  );

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ?? SharedPreferences.getInstance();

  Future<StudySessionSnapshot> load() async {
    if (_preferences != null) return _loadSharedPreferences();
    try {
      return await _driftStore.load();
    } catch (_) {
      return _loadSharedPreferences();
    }
  }

  Future<void> save(StudySessionSnapshot snapshot) async {
    if (_preferences != null) return _saveSharedPreferences(snapshot);
    try {
      await _driftStore.save(snapshot);
    } catch (_) {
      await _saveSharedPreferences(snapshot);
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

  Future<StudySessionSnapshot> _loadSharedPreferences() async {
    final prefs = await _prefs;
    final cardsRaw = prefs.getString(_cardsKey);
    final logsRaw = prefs.getString(_logsKey);
    final cards = <String, SrsCard>{};
    final logs = <SrsReviewLog>[];

    if (cardsRaw != null && cardsRaw.isNotEmpty) {
      final decoded = (jsonDecode(cardsRaw) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final json in decoded) {
        final card = SrsCardJson.fromJson(json);
        cards[card.id] = card;
      }
    }

    if (logsRaw != null && logsRaw.isNotEmpty) {
      final decoded = (jsonDecode(logsRaw) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      logs.addAll(decoded.map(SrsReviewLogJson.fromJson));
    }

    return StudySessionSnapshot(
      cards: cards,
      logs: logs,
      reviewedCount: logs.length,
    );
  }

  Future<void> _saveSharedPreferences(StudySessionSnapshot snapshot) async {
    final prefs = await _prefs;
    final cardsJson = snapshot.cards.values
        .map((card) => card.toJson())
        .toList();
    final logsJson = snapshot.logs.map((log) => log.toJson()).toList();
    await prefs.setString(_cardsKey, jsonEncode(cardsJson));
    await prefs.setString(_logsKey, jsonEncode(logsJson));
  }

  Future<void> _clearSharedPreferences() async {
    final prefs = await _prefs;
    await prefs.remove(_cardsKey);
    await prefs.remove(_logsKey);
  }
}
