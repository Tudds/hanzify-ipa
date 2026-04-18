// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_visibility_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NavVisibility)
final navVisibilityProvider = NavVisibilityProvider._();

final class NavVisibilityProvider
    extends $NotifierProvider<NavVisibility, bool> {
  NavVisibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navVisibilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navVisibilityHash();

  @$internal
  @override
  NavVisibility create() => NavVisibility();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$navVisibilityHash() => r'd8f35cef4c03867958e8a30db8255fc213c6f556';

abstract class _$NavVisibility extends $Notifier<bool> {
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
