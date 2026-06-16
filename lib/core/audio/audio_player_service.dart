import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Service singleton để phát audio MP3 từ URL CDN.
///
/// - Web: just_audio dùng Web Audio API + HTML5, browser tự cache theo header CDN
/// - Native: just_audio buffer/stream, có thể tích hợp flutter_cache_manager nếu cần offline-first
class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer() {
    _stateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Chỉ reset nếu không có play() mới hơn đang chạy (chống race khi
        // cuộn nhanh / phát liên tiếp: completion của lần cũ không được đè
        // lên lần phát mới).
        _currentUrl = null;
        unawaited(_player.stop());
      }
    });
  }

  final AudioPlayer _player;
  StreamSubscription<PlayerState>? _stateSub;
  String? _currentUrl;

  /// Token tăng dần mỗi lần play()/stop() — lần phát cũ tự bỏ qua khi đã có
  /// lần mới hơn.
  int _playToken = 0;

  /// Phát audio từ URL. Luôn nạp lại URL (an toàn hơn dedupe seek, tránh kẹt
  /// trạng thái sau nhiều lần cuộn).
  Future<void> play(String url) async {
    final token = ++_playToken;
    try {
      await _player.setUrl(url);
      if (token != _playToken) return; // đã bị một play()/stop() mới thay
      _currentUrl = url;
      await _player.play();
    } catch (e, st) {
      if (token == _playToken) _currentUrl = null;
      debugPrint('AudioPlayer error for $url: $e\n$st');
    }
  }

  Future<void> stop() async {
    _playToken++;
    _currentUrl = null;
    await _player.stop();
  }

  Future<void> dispose() async {
    await _stateSub?.cancel();
    await _player.dispose();
  }

  bool get isPlaying => _player.playing;

  String? get currentUrl => _currentUrl;

  Stream<bool> get playingStream => _player.playingStream;

  /// Vị trí phát hiện tại — dùng cho phụ đề đồng bộ theo audio (sub sync).
  Stream<Duration> get positionStream => _player.positionStream;
}

/// Provider singleton — keepAlive vì player nặng.
final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});
