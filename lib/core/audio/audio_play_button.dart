import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_player_service.dart';

/// Nút phát audio inline cho vocab/grammar/conversation.
///
/// Trạng thái:
///   - idle:    icon volume_up
///   - loading: spinner nhỏ (đang buffer)
///   - playing: icon stop_circle
///
/// Tap = play. Tap khi đang play = stop.
class AudioPlayButton extends ConsumerStatefulWidget {
  const AudioPlayButton({
    super.key,
    required this.url,
    this.tooltip,
    this.size = 22,
    this.color,
  });

  /// Full URL của file MP3. Nếu null/rỗng → button bị ẩn.
  final String? url;
  final String? tooltip;
  final double size;
  final Color? color;

  @override
  ConsumerState<AudioPlayButton> createState() => _AudioPlayButtonState();
}

class _AudioPlayButtonState extends ConsumerState<AudioPlayButton> {
  bool _loading = false;
  bool _isThisPlaying = false;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    final player = ref.read(audioPlayerProvider);
    _sub = player.playingStream.listen((playing) {
      if (!mounted) return;
      // Nếu player phát URL khác → button này không "playing"
      setState(() {
        _isThisPlaying = playing && player.currentUrl == widget.url;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _onTap() async {
    final url = widget.url;
    if (url == null || url.isEmpty) return;
    final player = ref.read(audioPlayerProvider);

    if (_isThisPlaying) {
      await player.stop();
      return;
    }
    setState(() => _loading = true);
    try {
      await player.play(url);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null || widget.url!.isEmpty) {
      return const SizedBox.shrink();
    }
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    final Widget icon;
    if (_loading) {
      icon = SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    } else if (_isThisPlaying) {
      icon = Icon(Icons.stop_circle_rounded, size: widget.size, color: color);
    } else {
      icon = Icon(Icons.volume_up_rounded, size: widget.size, color: color);
    }

    return InkResponse(
      onTap: _onTap,
      radius: widget.size * 0.9,
      child: Tooltip(
        message: widget.tooltip ?? 'Phát âm',
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: icon,
        ),
      ),
    );
  }
}
