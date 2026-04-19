// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bật khi user chọn "Dùng thử không đăng nhập".
/// Cho phép auth gate ở main.dart cho qua mà không cần Supabase session.

@ProviderFor(GuestMode)
final guestModeProvider = GuestModeProvider._();

/// Bật khi user chọn "Dùng thử không đăng nhập".
/// Cho phép auth gate ở main.dart cho qua mà không cần Supabase session.
final class GuestModeProvider extends $NotifierProvider<GuestMode, bool> {
  /// Bật khi user chọn "Dùng thử không đăng nhập".
  /// Cho phép auth gate ở main.dart cho qua mà không cần Supabase session.
  GuestModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guestModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guestModeHash();

  @$internal
  @override
  GuestMode create() => GuestMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$guestModeHash() => r'c1650bed424c1e4f8047c3c8f9c2c3337ef9b6a8';

/// Bật khi user chọn "Dùng thử không đăng nhập".
/// Cho phép auth gate ở main.dart cho qua mà không cần Supabase session.

abstract class _$GuestMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
