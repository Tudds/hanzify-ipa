import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/vocab.dart';
import '../../domain/review_algorithm.dart';
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
    // Không cần set loading trước — AsyncValue.guard() tự quản lý transitions
    state = await AsyncValue.guard(() async {
      final repository = ref.read(vocabRepositoryProvider);
      final updatedVocab = reviewVocab(vocab, quality);
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
      final repository = ref.read(vocabRepositoryProvider); // đọc 1 lần duy nhất
      final updated = vocab.copyWith(isBookmarked: !vocab.isBookmarked);
      await repository.update(updated);
      return repository.getAll();
    });
  }

  /// Mark mastered toggle
  Future<void> toggleMastered(Vocab vocab) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(vocabRepositoryProvider); // đọc 1 lần duy nhất
      final updated = vocab.copyWith(isMastered: !vocab.isMastered);
      await repository.update(updated);
      return repository.getAll();
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
    // Không cần set loading trước — AsyncValue.guard() tự quản lý transitions
    state = await AsyncValue.guard(() async {
      final repository = ref.read(vocabRepositoryProvider);
      List<Vocab> cards;

      // Ưu tiên lọc ở DB level:
      // 1) onlyDue + hskLevel → search với hskLevel filter trên due items
      // 2) onlyDue → getDue()
      // 3) hskLevel → getByLevel()
      // 4) tất cả → getAll()
      if (onlyDue) {
        // getDue() không hỗ trợ hskLevel filter → load due rồi filter
        cards = await repository.getDue();
        if (cards.isEmpty) {
          // Auto-seed if empty
          await repository.reseed();
          cards = await repository.getDue();
        }
        if (hskLevel != null && hskLevel > 0) {
          cards = cards.where((v) => v.level == hskLevel).toList();
        }
      } else if (hskLevel != null && hskLevel > 0) {
        // Dùng DB query trực tiếp — không load all
        cards = await repository.getByLevel(hskLevel);
      } else {
        cards = await repository.getAll();
        if (cards.isEmpty) {
          await repository.reseed();
          cards = await repository.getAll();
        }
      }

      // Bookmark filter vẫn phải ở client-side vì DB không có method riêng
      if (onlyBookmarked) {
        cards = cards.where((v) => v.isBookmarked).toList();
      }

      // Xáo trộn ngẫu nhiên
      cards.shuffle();

      // Giới hạn số lượng
      if (limit > 0) {
        return cards.take(limit).toList();
      }
      return cards;
    });
  }
}
