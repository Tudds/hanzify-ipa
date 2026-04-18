// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global pinyin visibility toggle — persisted across sessions.

@ProviderFor(ShowPinyin)
final showPinyinProvider = ShowPinyinProvider._();

/// Global pinyin visibility toggle — persisted across sessions.
final class ShowPinyinProvider extends $NotifierProvider<ShowPinyin, bool> {
  /// Global pinyin visibility toggle — persisted across sessions.
  ShowPinyinProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showPinyinProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showPinyinHash();

  @$internal
  @override
  ShowPinyin create() => ShowPinyin();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showPinyinHash() => r'c03e352778ba39294d277c16f175e24ab940d7b5';

/// Global pinyin visibility toggle — persisted across sessions.

abstract class _$ShowPinyin extends $Notifier<bool> {
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
