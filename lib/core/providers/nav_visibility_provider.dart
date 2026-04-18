import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_visibility_provider.g.dart';

@riverpod
class NavVisibility extends _$NavVisibility {
  @override
  bool build() => true;

  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}
