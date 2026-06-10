import 'dart:async';

class LearningSyncTrigger {
  const LearningSyncTrigger._();

  static Future<void> Function()? _sync;
  static bool _running = false;
  static bool _queued = false;
  static int _suppressed = 0;

  static void configure(Future<void> Function() sync) {
    _sync = sync;
  }

  static void request() {
    final sync = _sync;
    if (sync == null) return;
    if (_suppressed > 0) return;
    if (_running) {
      _queued = true;
      return;
    }
    unawaited(_run(sync));
  }

  static Future<void> _run(Future<void> Function() sync) async {
    _running = true;
    try {
      do {
        _queued = false;
        await sync();
      } while (_queued);
    } finally {
      _running = false;
    }
  }

  static Future<T> suppress<T>(Future<T> Function() action) async {
    _suppressed += 1;
    try {
      return await action();
    } finally {
      _suppressed -= 1;
    }
  }
}
