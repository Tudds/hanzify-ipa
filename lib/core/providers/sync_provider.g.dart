// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncService)
final syncServiceProvider = SyncServiceProvider._();

final class SyncServiceProvider
    extends $FunctionalProvider<SyncService?, SyncService?, SyncService?>
    with $Provider<SyncService?> {
  SyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncServiceHash();

  @$internal
  @override
  $ProviderElement<SyncService?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncService? create(Ref ref) {
    return syncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncService? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncService?>(value),
    );
  }
}

String _$syncServiceHash() => r'895346a4dbe1d3ea868fc85f0521ca26ce571a32';

@ProviderFor(connectivityStream)
final connectivityStreamProvider = ConnectivityStreamProvider._();

final class ConnectivityStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConnectivityResult>>,
          List<ConnectivityResult>,
          Stream<List<ConnectivityResult>>
        >
    with
        $FutureModifier<List<ConnectivityResult>>,
        $StreamProvider<List<ConnectivityResult>> {
  ConnectivityStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<ConnectivityResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConnectivityResult>> create(Ref ref) {
    return connectivityStream(ref);
  }
}

String _$connectivityStreamHash() =>
    r'fd6c265ea6cb2c714cc320227dd8621579b6f3f2';

/// Reacts to auth events (pull on login) and connectivity (push on reconnect).

@ProviderFor(SyncNotifier)
final syncProvider = SyncNotifierProvider._();

/// Reacts to auth events (pull on login) and connectivity (push on reconnect).
final class SyncNotifierProvider extends $NotifierProvider<SyncNotifier, void> {
  /// Reacts to auth events (pull on login) and connectivity (push on reconnect).
  SyncNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncNotifierHash();

  @$internal
  @override
  SyncNotifier create() => SyncNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$syncNotifierHash() => r'358a20e06e01a3d53713f89f9a92cdaf8d250753';

/// Reacts to auth events (pull on login) and connectivity (push on reconnect).

abstract class _$SyncNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
