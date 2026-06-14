import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_profile_provider.dart';
import '../data/study_session_store.dart';
import '../domain/fsrs.dart';
import 'study_session_controller.dart';

/// Ghi câu trả lời Quiz/Shorts thành thẻ SRS rồi persist.
///
/// [StudySessionStore.save] replace toàn bộ snapshot, nên mỗi lần ghi phải
/// load snapshot mới nhất trước (để không xóa thẻ tab Ôn tập vừa tạo) và
/// tuần tự hóa các lần ghi qua [_lock] (user có thể bấm nhanh).
class StudySessionRecorder {
  StudySessionRecorder({
    StudySessionStore store = const StudySessionStore(),
    FsrsScheduler scheduler = const FsrsScheduler(),
  }) : _store = store,
       _scheduler = scheduler;

  final StudySessionStore _store;
  final FsrsScheduler _scheduler;
  Future<void> _lock = Future<void>.value();

  Future<void> record({
    required String targetType,
    required String targetId,
    String cardType = 'recognition',
    required SrsRating rating,
  }) {
    final next = _lock.then((_) async {
      final snapshot = await _store.load();
      final controller = StudySessionController(scheduler: _scheduler)
        ..hydrate(snapshot);
      controller.recordAnswer(
        targetType: targetType,
        targetId: targetId,
        cardType: cardType,
        rating: rating,
      );
      // save() tự gọi LearningSyncTrigger.request() → sync khi đã đăng nhập.
      await _store.save(controller.snapshot());
    });
    // Giữ chuỗi tiếp tục dù một lần ghi lỗi.
    _lock = next.catchError((_) {});
    return next;
  }
}

final studySessionRecorderProvider = Provider<StudySessionRecorder>((ref) {
  final retention = ref.watch(
    userProfileProvider.select((profile) => profile.targetRetention),
  );
  return StudySessionRecorder(
    scheduler: FsrsScheduler(requestRetention: retention),
  );
});
