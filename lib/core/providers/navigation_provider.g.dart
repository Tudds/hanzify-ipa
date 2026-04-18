// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NavigationNotifier)
final navigationProvider = NavigationNotifierProvider._();

final class NavigationNotifierProvider
    extends $NotifierProvider<NavigationNotifier, NavState> {
  NavigationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationNotifierHash();

  @$internal
  @override
  NavigationNotifier create() => NavigationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavState>(value),
    );
  }
}

String _$navigationNotifierHash() =>
    r'85b9828b08c7adfa18a8376034d1036ee742498e';

abstract class _$NavigationNotifier extends $Notifier<NavState> {
  NavState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NavState, NavState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NavState, NavState>,
              NavState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
