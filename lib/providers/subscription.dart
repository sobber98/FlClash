import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionPlansProvider = Provider<AsyncValue<List<V2BoardPlan>>>((
  ref,
) {
  return ref.watch(v2boardPlansProvider);
});

final subscriptionOrdersProvider =
    AsyncNotifierProvider<SubscriptionOrdersNotifier, List<V2BoardOrder>>(
      SubscriptionOrdersNotifier.new,
    );

class SubscriptionOrdersNotifier extends AsyncNotifier<List<V2BoardOrder>> {
  @override
  Future<List<V2BoardOrder>> build() async {
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<V2BoardOrder>> _fetch() async {
    final api = ref.read(v2boardApiClientProvider);
    final props = ref.read(v2boardSettingProvider);
    if (props == null || !(props.isLoggedIn)) {
      return const [];
    }
    if (api == null) {
      return const [];
    }
    return api.fetchOrders();
  }
}

final currentPlanProvider = Provider<V2BoardPlan?>((ref) {
  final plansState = ref.watch(subscriptionPlansProvider);
  final userState = ref.watch(v2boardUserProvider);
  final subState = ref.watch(v2boardSubscriptionProvider);
  final plans = _asyncDataOrNull(plansState) ?? const <V2BoardPlan>[];
  final user = _asyncDataOrNull(userState);
  final sub = _asyncDataOrNull(subState);
  final planId = user?.planId ?? int.tryParse(sub?.planId ?? '');
  if (planId == null) {
    return null;
  }
  for (final plan in plans) {
    if (plan.id == planId) {
      return plan;
    }
  }
  return null;
});

T? _asyncDataOrNull<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}
