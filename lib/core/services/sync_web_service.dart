import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/vocab/domain/entities/vocab.dart';

/// SyncWebService — Đồng bộ trực tiếp giữa in-memory store (Web) và Supabase.
/// Không cần Drift DB — dùng Supabase REST API trực tiếp.
class SyncWebService {
  SupabaseClient get _client => Supabase.instance.client;

  // ==========================================================================
  // VOCAB SYNC
  // ==========================================================================

  /// Push một vocab đã thay đổi lên Supabase.
  /// Gọi mỗi khi user review/bookmark/master trên web.
  Future<void> pushVocabUpdate(String userId, Vocab vocab) async {
    try {
      await _client.from('user_vocab_progress').upsert({
        'user_id': userId,
        'vocab_id': vocab.id,
        'repetitions': vocab.repetitions,
        'ease_factor': vocab.easeFactor,
        'interval': vocab.interval,
        'next_review': vocab.nextReview.toUtc().toIso8601String(),
        'is_bookmarked': vocab.isBookmarked,
        'is_mastered': vocab.isMastered,
        'updated_at': vocab.updatedAt.toUtc().toIso8601String(),
      }, onConflict: 'user_id,vocab_id');
    } catch (e) {
      debugPrint('[SyncWeb] Failed to push vocab ${vocab.id}: $e');
    }
  }

  /// Pull tất cả vocab progress từ Supabase.
  /// Trả về map vocabId → SRS data để merge vào in-memory store.
  Future<Map<String, VocabSyncData>> pullVocabProgress(String userId) async {
    try {
      final remote = await _client
          .from('user_vocab_progress')
          .select()
          .eq('user_id', userId);

      final result = <String, VocabSyncData>{};
      for (final row in remote as List<dynamic>) {
        final vocabId = row['vocab_id'] as String;
        result[vocabId] = VocabSyncData(
          repetitions: row['repetitions'] as int? ?? 0,
          easeFactor: (row['ease_factor'] as num?)?.toDouble() ?? 2.5,
          interval: row['interval'] as int? ?? 0,
          nextReview: row['next_review'] != null
              ? DateTime.parse(row['next_review'] as String)
              : DateTime.now(),
          isBookmarked: row['is_bookmarked'] as bool? ?? false,
          isMastered: row['is_mastered'] as bool? ?? false,
          updatedAt: row['updated_at'] != null
              ? DateTime.parse(row['updated_at'] as String)
              : DateTime.now(),
        );
      }

      debugPrint('[SyncWeb] Pulled ${result.length} vocab progress items');
      return result;
    } catch (e) {
      debugPrint('[SyncWeb] Failed to pull vocab progress: $e');
      return {};
    }
  }

  // ==========================================================================
  // GRAMMAR SYNC
  // ==========================================================================

  /// Push grammar bookmark/mastered lên Supabase.
  Future<void> pushGrammarUpdate(
    String userId,
    String grammarId, {
    required bool isBookmarked,
    required bool isMastered,
  }) async {
    try {
      await _client.from('user_grammar_progress').upsert({
        'user_id': userId,
        'grammar_id': grammarId,
        'is_bookmarked': isBookmarked,
        'is_mastered': isMastered,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,grammar_id');
    } catch (e) {
      debugPrint('[SyncWeb] Failed to push grammar $grammarId: $e');
    }
  }

  /// Pull tất cả grammar progress từ Supabase.
  Future<Map<String, GrammarSyncData>> pullGrammarProgress(
      String userId) async {
    try {
      final remote = await _client
          .from('user_grammar_progress')
          .select()
          .eq('user_id', userId);

      final result = <String, GrammarSyncData>{};
      for (final row in remote as List<dynamic>) {
        final grammarId = row['grammar_id'] as String;
        result[grammarId] = GrammarSyncData(
          isBookmarked: row['is_bookmarked'] as bool? ?? false,
          isMastered: row['is_mastered'] as bool? ?? false,
        );
      }

      debugPrint('[SyncWeb] Pulled ${result.length} grammar progress items');
      return result;
    } catch (e) {
      debugPrint('[SyncWeb] Failed to pull grammar progress: $e');
      return {};
    }
  }
}

/// Data class cho vocab SRS sync data (pull từ Supabase).
class VocabSyncData {
  final int repetitions;
  final double easeFactor;
  final int interval;
  final DateTime nextReview;
  final bool isBookmarked;
  final bool isMastered;
  final DateTime updatedAt;

  const VocabSyncData({
    required this.repetitions,
    required this.easeFactor,
    required this.interval,
    required this.nextReview,
    required this.isBookmarked,
    required this.isMastered,
    required this.updatedAt,
  });
}

/// Data class cho grammar sync data (pull từ Supabase).
class GrammarSyncData {
  final bool isBookmarked;
  final bool isMastered;

  const GrammarSyncData({
    required this.isBookmarked,
    required this.isMastered,
  });
}
