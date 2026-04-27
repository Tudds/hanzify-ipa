import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Service singleton để phát audio MP3 từ URL CDN.
///
/// - Web: just_audio dùng Web Audio API + HTML5, browser tự cache theo header CDN
/// - Native: just_audio buffer/stream, có thể tích hợp flutter_cache_manager nếu cần offline-first
class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;
  String? _currentUrl;

  /// Phát audio từ URL. Nếu đang phát URL khác sẽ stop và phát mới.
  /// Nếu đang phát cùng URL thì replay từ đầu.
  Future<void> play(String url) async {
    try {
      if (_currentUrl != url) {
        await _player.setUrl(url);
        _currentUrl = url;
      } else {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    } catch (e, st) {
      debugPrint('AudioPlayer error for $url: $e\n$st');
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  bool get isPlaying => _player.playing;

  Stream<bool> get playingStream => _player.playingStream;
}

/// Provider singleton — keepAlive vì player nặng.
final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});
