// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileStats)
final profileStatsProvider = ProfileStatsProvider._();

final class ProfileStatsProvider
    extends $FunctionalProvider<ProfileStats, ProfileStats, ProfileStats>
    with $Provider<ProfileStats> {
  ProfileStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileStatsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileStatsHash();

  @$internal
  @override
  $ProviderElement<ProfileStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileStats create(Ref ref) {
    return profileStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileStats>(value),
    );
  }
}

String _$profileStatsHash() => r'3a7ba303f644ce37399cfc36dde44c1b8c6ac362';
