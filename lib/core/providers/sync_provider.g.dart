// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SyncService cho native (Drift DB). Null trên web.

@ProviderFor(syncService)
final syncServiceProvider = SyncServiceProvider._();

/// SyncService cho native (Drift DB). Null trên web.

final class SyncServiceProvider
    extends $FunctionalProvider<SyncService?, SyncService?, SyncService?>
    with $Provider<SyncService?> {
  /// SyncService cho native (Drift DB). Null trên web.
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

/// SyncWebService cho web. Null trên native.

@ProviderFor(syncWebService)
final syncWebServiceProvider = SyncWebServiceProvider._();

/// SyncWebService cho web. Null trên native.

final class SyncWebServiceProvider
    extends
        $FunctionalProvider<SyncWebService?, SyncWebService?, SyncWebService?>
    with $Provider<SyncWebService?> {
  /// SyncWebService cho web. Null trên native.
  SyncWebServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncWebServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncWebServiceHash();

  @$internal
  @override
  $ProviderElement<SyncWebService?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncWebService? create(Ref ref) {
    return syncWebService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncWebService? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncWebService?>(value),
    );
  }
}

String _$syncWebServiceHash() => r'814f7de0a093634489f1466978d14611127232cf';

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
/// Hoạt động trên cả native và web.

@ProviderFor(SyncNotifier)
final syncProvider = SyncNotifierProvider._();

/// Reacts to auth events (pull on login) and connectivity (push on reconnect).
/// Hoạt động trên cả native và web.
final class SyncNotifierProvider extends $NotifierProvider<SyncNotifier, void> {
  /// Reacts to auth events (pull on login) and connectivity (push on reconnect).
  /// Hoạt động trên cả native và web.
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

String _$syncNotifierHash() => r'8d630700e0ca98f59536bdf6d6b329209de38598';

/// Reacts to auth events (pull on login) and connectivity (push on reconnect).
/// Hoạt động trên cả native và web.

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
