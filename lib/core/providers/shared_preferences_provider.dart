import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instance được load một lần trong `main()` trước `runApp` và override tại
/// `ProviderScope`, để các provider đọc prefs đồng bộ (GoRouter redirect cần
/// giá trị ngay khi khởi động, không chờ Future).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'Override sharedPreferencesProvider trong main() hoặc test.',
  ),
);
