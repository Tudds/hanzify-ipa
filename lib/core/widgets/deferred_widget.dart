import 'package:flutter/material.dart';

/// Loads a `deferred as` library, then builds its widget.
///
/// On Flutter Web (JS + WASM) a `deferred` import is emitted as a separate
/// code chunk that is only downloaded when [libraryLoader] (the generated
/// `loadLibrary`) is first called — shrinking the initial bundle. On the VM /
/// native AOT the call resolves immediately, so this is a no-op there.
///
/// While the chunk is in flight a [placeholder] is shown; if the download
/// fails (e.g. offline) a retry affordance is offered instead of hanging on a
/// spinner forever.
typedef LibraryLoader = Future<void> Function();
typedef DeferredWidgetBuilder = Widget Function();

class DeferredWidget extends StatefulWidget {
  const DeferredWidget(
    this.libraryLoader,
    this.createWidget, {
    super.key,
    this.placeholder,
  });

  final LibraryLoader libraryLoader;
  final DeferredWidgetBuilder createWidget;
  final Widget? placeholder;

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  Widget? _child;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    widget.libraryLoader().then((_) {
      if (!mounted) return;
      setState(() {
        _child = widget.createWidget();
        _error = null;
      });
    }).catchError((Object error) {
      if (!mounted) return;
      setState(() => _error = error);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_child != null) return _child!;
    if (_error != null) {
      return _DeferredError(
        onRetry: () {
          setState(() => _error = null);
          _load();
        },
      );
    }
    return widget.placeholder ??
        const Center(child: CircularProgressIndicator());
  }
}

class _DeferredError extends StatelessWidget {
  const _DeferredError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Không tải được nội dung. Kiểm tra kết nối.'),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
