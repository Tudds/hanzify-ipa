// lib/core/providers/navigation_provider.dart
import 'package:collection/collection.dart' show ListEquality;
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

/// State điều hướng: screen name + optional argument + navigation history.
class NavState extends Equatable {
  final String screen;
  final String? arg;          // dùng cho charDetail (ký tự), v.v.
  final List<String> _history; // internal navigation history stack

  static const _listEq = ListEquality<String>();

  const NavState(this.screen, {this.arg, List<String>? history})
      : _history = history ?? const [];

  /// Current screen name before navigation (for single-level back compatibility).
  String? get previousScreen =>
      _history.isNotEmpty ? _history.last : null;

  /// Push a new screen onto the stack.
  NavState push(String screen, {String? arg}) {
    return NavState(
      screen,
      arg: arg,
      history: [..._history, this.screen],
    );
  }

  /// Pop back to previous screen in history.
  NavState pop({String? fallback}) {
    if (_history.isEmpty) {
      return NavState(fallback ?? 'home');
    }
    final prev = _history.last;
    final newHistory = _history.sublist(0, _history.length - 1);
    return NavState(prev, history: newHistory);
  }

  /// Navigate to a specific screen in the history stack.
  /// Removes all entries after the target screen.
  NavState popUntil(String screen) {
    final idx = _history.lastIndexOf(screen);
    if (idx < 0) return NavState(screen);
    final newHistory = _history.sublist(0, idx);
    return NavState(screen, history: newHistory);
  }

  /// Clear all history and go to a new screen.
  NavState replace(String screen, {String? arg}) {
    return NavState(screen, arg: arg);
  }

  @override
  List<Object?> get props => [screen, arg, _listEq.hash(_history)];
}

@Riverpod(keepAlive: true)
class NavigationNotifier extends _$NavigationNotifier {
  @override
  NavState build() => const NavState('home');

  /// Navigate đến screen mới (push onto history stack).
  void navigate(String screen, {String? arg}) {
    state = state.push(screen, arg: arg);
  }

  /// Quay lại màn hình trước trong history stack.
  void goBack() {
    state = state.pop();
  }

  /// Navigate đến screen cụ thể, xóa hết history phía sau.
  void navigateAndReplace(String screen, {String? arg}) {
    state = state.replace(screen, arg: arg);
  }

  /// Reset về màn hình home với history rỗng.
  void goHome() {
    state = const NavState('home');
  }
}
