// lib/core/providers/navigation_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@Riverpod(keepAlive: true)
class NavigationNotifier extends _$NavigationNotifier {
  @override
  String build() => 'home';

  void navigate(String screen) => state = screen;
}
