import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_urls.dart';
import '../../../core/learning/data/learning_asset_repository.dart';
import '../../dictionary/data/library_repository.dart';
import '../../dictionary/domain/vocab_item.dart';
import '../domain/dictation.dart';

/// Chọn câu luyện nghe-viết / dịch từ data offline.
///
/// Nguồn chính: collocation pool theo level — các câu nguồn `conversation_line`
/// đã được [LearningAssetRepository] gắn sẵn audio URL thật trên CDN. Khi pool
/// không có câu phù hợp (mode listen cần audio), fallback sang câu ví dụ của
/// vocab (audio theo convention `vocab/{id}_E0.mp3`).
class DictationExerciseService {
  const DictationExerciseService({
    this.assetRepository = const LearningAssetRepository(),
    required this.libraryRepository,
  });

  final LearningAssetRepository assetRepository;
  final LibraryRepository libraryRepository;

  /// Câu quá dài gõ rất mệt trên mobile — giới hạn để bài luyện ngắn gọn.
  static const maxHanziLength = 16;

  /// Dưới ngưỡng này thì bổ sung câu ví dụ vocab để user không xoay vòng
  /// vài câu (HSK4 chỉ có 3 câu hội thoại đủ ngắn cho mode nghe).
  static const minVariety = 10;

  Future<DictationExercise?> nextExercise({
    required DictationMode mode,
    required int level,
    Random? rng,
  }) async {
    final candidates = await _collocationCandidates(mode, level);
    if (candidates.length < minVariety) {
      candidates.addAll(await _vocabExampleCandidates(mode, level));
    }
    if (candidates.isEmpty) return null;
    return candidates[(rng ?? Random()).nextInt(candidates.length)];
  }

  Future<List<DictationExercise>> _collocationCandidates(
    DictationMode mode,
    int level,
  ) async {
    final pool = await assetRepository.loadStaticCollocationPoolForLevel(level);
    return [
      for (final item in pool)
        if (item.textCn.isNotEmpty &&
            item.textCn.runes.length <= maxHanziLength &&
            (mode != DictationMode.listen || item.audioUrl != null) &&
            (mode != DictationMode.readVi || item.textVi.isNotEmpty))
          DictationExercise(
            id: item.id,
            mode: mode,
            textCn: item.textCn,
            pinyin: item.pinyin,
            textVi: item.textVi,
            level: item.level,
            audioUrl: item.audioUrl,
          ),
    ];
  }

  Future<List<DictationExercise>> _vocabExampleCandidates(
    DictationMode mode,
    int level,
  ) async {
    final List<VocabItem> vocab;
    try {
      vocab = await libraryRepository.loadVocabLevel(level);
    } catch (_) {
      // Bundle không có file vocab level này (test fixture) → bỏ fallback.
      return const [];
    }
    return [
      for (final item in vocab)
        if (item.examples.isNotEmpty &&
            item.examples.first.cn.isNotEmpty &&
            item.examples.first.cn.runes.length <= maxHanziLength &&
            (mode != DictationMode.readVi ||
                item.examples.first.vi.isNotEmpty))
          DictationExercise(
            id: '${item.id}_E0',
            mode: mode,
            textCn: item.examples.first.cn,
            pinyin: item.examples.first.pinyin,
            textVi: item.examples.first.vi,
            level: item.level,
            // Audio ví dụ tồn tại theo convention của pipeline TTS.
            audioUrl: AudioUrls.forVocabExample(item.id, 0),
          ),
    ];
  }
}

final dictationExerciseServiceProvider = Provider<DictationExerciseService>((
  ref,
) {
  return DictationExerciseService(
    libraryRepository: ref.watch(libraryRepositoryProvider),
  );
});
