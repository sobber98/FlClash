// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../v2board.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(V2boardApiClient)
const v2boardApiClientProvider = V2boardApiClientProvider._();

final class V2boardApiClientProvider
    extends $NotifierProvider<V2boardApiClient, V2BoardApi?> {
  const V2boardApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'v2boardApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$v2boardApiClientHash();

  @$internal
  @override
  V2boardApiClient create() => V2boardApiClient();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(V2BoardApi? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<V2BoardApi?>(value),
    );
  }
}

String _$v2boardApiClientHash() => r'c0be01c5179af3edfb0e11d4e3b509f6fb9a7b3c';

abstract class _$V2boardApiClient extends $Notifier<V2BoardApi?> {
  V2BoardApi? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<V2BoardApi?, V2BoardApi?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<V2BoardApi?, V2BoardApi?>,
              V2BoardApi?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(V2boardUser)
const v2boardUserProvider = V2boardUserProvider._();

final class V2boardUserProvider
    extends $NotifierProvider<V2boardUser, AsyncValue<V2BoardUser?>> {
  const V2boardUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'v2boardUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$v2boardUserHash();

  @$internal
  @override
  V2boardUser create() => V2boardUser();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<V2BoardUser?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<V2BoardUser?>>(value),
    );
  }
}

String _$v2boardUserHash() => r'4e628d744b5798537da9dc3f8129b2d8fa4ffde4';

abstract class _$V2boardUser extends $Notifier<AsyncValue<V2BoardUser?>> {
  AsyncValue<V2BoardUser?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<V2BoardUser?>, AsyncValue<V2BoardUser?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<V2BoardUser?>, AsyncValue<V2BoardUser?>>,
              AsyncValue<V2BoardUser?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(V2boardSubscription)
const v2boardSubscriptionProvider = V2boardSubscriptionProvider._();

final class V2boardSubscriptionProvider
    extends
        $NotifierProvider<
          V2boardSubscription,
          AsyncValue<V2BoardSubscription?>
        > {
  const V2boardSubscriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'v2boardSubscriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$v2boardSubscriptionHash();

  @$internal
  @override
  V2boardSubscription create() => V2boardSubscription();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<V2BoardSubscription?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<V2BoardSubscription?>>(
        value,
      ),
    );
  }
}

String _$v2boardSubscriptionHash() =>
    r'f28f41e3d085849dfc94ee5b46b3863e2bfe45a4';

abstract class _$V2boardSubscription
    extends $Notifier<AsyncValue<V2BoardSubscription?>> {
  AsyncValue<V2BoardSubscription?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<V2BoardSubscription?>,
              AsyncValue<V2BoardSubscription?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<V2BoardSubscription?>,
                AsyncValue<V2BoardSubscription?>
              >,
              AsyncValue<V2BoardSubscription?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(V2boardPlans)
const v2boardPlansProvider = V2boardPlansProvider._();

final class V2boardPlansProvider
    extends $NotifierProvider<V2boardPlans, AsyncValue<List<V2BoardPlan>>> {
  const V2boardPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'v2boardPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$v2boardPlansHash();

  @$internal
  @override
  V2boardPlans create() => V2boardPlans();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<V2BoardPlan>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<V2BoardPlan>>>(
        value,
      ),
    );
  }
}

String _$v2boardPlansHash() => r'3c2360e85b8f0771db6e51b5183e8a9d2c9bd8db';

abstract class _$V2boardPlans extends $Notifier<AsyncValue<List<V2BoardPlan>>> {
  AsyncValue<List<V2BoardPlan>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<V2BoardPlan>>,
              AsyncValue<List<V2BoardPlan>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<V2BoardPlan>>,
                AsyncValue<List<V2BoardPlan>>
              >,
              AsyncValue<List<V2BoardPlan>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(V2boardNotices)
const v2boardNoticesProvider = V2boardNoticesProvider._();

final class V2boardNoticesProvider
    extends $NotifierProvider<V2boardNotices, AsyncValue<List<V2BoardNotice>>> {
  const V2boardNoticesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'v2boardNoticesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$v2boardNoticesHash();

  @$internal
  @override
  V2boardNotices create() => V2boardNotices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<V2BoardNotice>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<V2BoardNotice>>>(
        value,
      ),
    );
  }
}

String _$v2boardNoticesHash() => r'3ffa3a4b13175a849bdd286c6b6c2615c426ab1d';

abstract class _$V2boardNotices
    extends $Notifier<AsyncValue<List<V2BoardNotice>>> {
  AsyncValue<List<V2BoardNotice>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<V2BoardNotice>>,
              AsyncValue<List<V2BoardNotice>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<V2BoardNotice>>,
                AsyncValue<List<V2BoardNotice>>
              >,
              AsyncValue<List<V2BoardNotice>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
