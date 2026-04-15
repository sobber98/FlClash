import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/v2board.g.dart';

@Riverpod(keepAlive: true)
class V2boardApiClient extends _$V2boardApiClient {
  @override
  V2BoardApi? build() {
    return null;
  }

  void init(String baseUrl, {String? authData}) {
    final api = V2BoardApi(baseUrl: baseUrl);
    if (authData != null && authData.isNotEmpty) {
      api.setAuthData(authData);
    }
    state = api;
  }

  void clear() {
    state?.clearAuth();
    state = null;
  }
}

@riverpod
class V2boardUser extends _$V2boardUser {
  @override
  AsyncValue<V2BoardUser?> build() {
    return const AsyncData(null);
  }

  Future<void> fetch() async {
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) return;
    state = const AsyncLoading();
    try {
      final user = await api.getUserInfo();
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}

@riverpod
class V2boardSubscription extends _$V2boardSubscription {
  @override
  AsyncValue<V2BoardSubscription?> build() {
    return const AsyncData(null);
  }

  Future<void> fetch() async {
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) return;
    state = const AsyncLoading();
    try {
      final sub = await api.getSubscribe();
      state = AsyncData(sub);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}

@riverpod
class V2boardPlans extends _$V2boardPlans {
  @override
  AsyncValue<List<V2BoardPlan>> build() {
    return const AsyncData([]);
  }

  Future<void> fetch() async {
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) return;
    state = const AsyncLoading();
    try {
      final plans = await api.getPlans();
      state = AsyncData(plans);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

@riverpod
class V2boardNotices extends _$V2boardNotices {
  @override
  AsyncValue<List<V2BoardNotice>> build() {
    return const AsyncData([]);
  }

  Future<void> fetch() async {
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) return;
    state = const AsyncLoading();
    try {
      final notices = await api.getNotices();
      state = AsyncData(notices);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
