import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/vocab.dart';
import '../../domain/usecases/review_vocab.dart';
import 'vocab_providers.dart';

part 'vocab_state.g.dart';

// ============================================================================
// DueVocabNotifier — danh sách từ cần ôn hôm nay
// ============================================================================
@Riverpod(keepAlive: true)
class DueVocabNotifier extends _$DueVocabNotifier {
  @override
  Future<List<Vocab>> build() async {
    final repository = ref.watch(vocabRepositoryProvider);
    return repository.getDue();
  }

  Future<void> review(Vocab vocab, int quality) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(vocabRepositoryProvider);
      final updatedVocab = ReviewVocab()(vocab, quality);
      await repository.update(updatedVocab);
      ref.invalidate(allVocabProvider);
      return repository.getDue();
    });
  }
}

// ============================================================================
// AllVocabNotifier — toàn bộ vocab, hỗ trợ search + invalidate
// ============================================================================
@Riverpod(keepAlive: true)
class AllVocabNotifier extends _$AllVocabNotifier {
  @override
  Future<List<Vocab>> build() async {
    final repository = ref.watch(vocabRepositoryProvider);
    return repository.getAll();
  }


  /// Bookmark toggle
  Future<void> toggleBookmark(Vocab vocab) async {
    state = await AsyncValue.guard(() async {
      final updated = vocab.copyWith(isBookmarked: !vocab.isBookmarked);
      await ref.read(vocabRepositoryProvider).update(updated);
      return ref.read(vocabRepositoryProvider).getAll();
    });
  }

  /// Mark mastered toggle
  Future<void> toggleMastered(Vocab vocab) async {
    state = await AsyncValue.guard(() async {
      final updated = vocab.copyWith(isMastered: !vocab.isMastered);
      await ref.read(vocabRepositoryProvider).update(updated);
      return ref.read(vocabRepositoryProvider).getAll();
    });
  }
}
// ============================================================================
// FlashcardSession — Logic lọc từ vựng để ôn tập
// ============================================================================
@Riverpod(keepAlive: true)
class FlashcardSession extends _$FlashcardSession {
  @override
  Future<List<Vocab>?> build() async {
    // Mặc định trả về null, sẽ được trigger bằng startSession
    return null;
  }

  Future<void> startSession({
    int? hskLevel,
    bool onlyBookmarked = false,
    bool onlyDue = true,
    int limit = 20,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(vocabRepositoryProvider);
      List<Vocab> all;
      
      if (onlyDue) {
        all = await repository.getDue();
      } else {
        all = await repository.getAll();
      }

      // ── Auto-seed if empty ────────────────────────────────────────────────
      // Nếu không tìm thấy từ nào (có thể do DB mới tạo chưa nạp JSON),
      // tiến hành ép nạp (force seed) và thử lấy lại một lần nữa.
      if (all.isEmpty) {
        await repository.reseed();
        if (onlyDue) {
          all = await repository.getDue();
        } else {
          all = await repository.getAll();
        }
      }

      // Lọc theo HSK
      if (hskLevel != null && hskLevel > 0) {
        all = all.where((v) => v.level == hskLevel).toList();
      }

      // Lọc theo Bookmark
      if (onlyBookmarked) {
        all = all.where((v) => v.isBookmarked).toList();
      }

      // Xáo trộn ngẫu nhiên
      all.shuffle();

      // Giới hạn số lượng
      if (limit > 0) {
        return all.take(limit).toList();
      }
      return all;
    });
  }
}
