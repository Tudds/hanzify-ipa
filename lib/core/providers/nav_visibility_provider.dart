import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void show() {
    if (!state) state = true;
  }

  void hide() {
    if (state) state = false;
  }

  void set(bool visible) => state = visible;
}

final navVisibilityProvider =
    NotifierProvider<NavVisibilityNotifier, bool>(NavVisibilityNotifier.new);
