import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/services/v2board/v2board.dart';
import 'package:v2box/views/subscription/order_list_view.dart';

const _orders = [
  V2BoardOrder(
    tradeNo: '2026051613051134979979690',
    type: 3,
    status: 2,
    totalAmount: 1497,
    planId: 1,
    createdAt: 1778917211,
  ),
  V2BoardOrder(
    tradeNo: '83892f912a19bbdf777b973595936084',
    type: 1,
    status: 3,
    totalAmount: 100,
    planId: 2,
    createdAt: 1745218140,
  ),
];

const _plans = [
  V2BoardPlan(id: 1, name: 'LV1-月付'),
  V2BoardPlan(id: 2, name: '订阅服务订单'),
];

class _OrdersNotifier extends SubscriptionOrdersNotifier {
  @override
  Future<List<V2BoardOrder>> build() async => _orders;

  @override
  Future<void> refresh() async {
    state = const AsyncData(_orders);
  }
}

Future<void> _pumpOrderList(
  WidgetTester tester, {
  required Size size,
  required bool isMobile,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        isMobileViewProvider.overrideWithValue(isMobile),
        v2boardApiClientProvider.overrideWithValue(null),
        subscriptionPlansProvider.overrideWithValue(
          const AsyncData<List<V2BoardPlan>>(_plans),
        ),
        subscriptionOrdersProvider.overrideWith(_OrdersNotifier.new),
      ],
      child: const MaterialApp(home: OrderListView()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('desktop order history sections align to one content grid', (
    tester,
  ) async {
    await _pumpOrderList(tester, size: const Size(1200, 800), isMobile: false);

    final statsLeft = tester
        .getRect(find.byKey(const ValueKey('orders-stats-card')))
        .left;
    final firstOrderLeft = tester
        .getRect(find.byKey(const ValueKey('order-card-0')))
        .left;

    expect(statsLeft, closeTo(firstOrderLeft, 1));
    expect(find.text('待支付'), findsOneWidget);
    expect(find.text('累计支付'), findsOneWidget);
  });

  testWidgets('mobile order history keeps stats and order cards visible', (
    tester,
  ) async {
    await _pumpOrderList(tester, size: const Size(390, 844), isMobile: true);

    expect(find.text('订单记录'), findsOneWidget);
    expect(find.text('订单中心'), findsOneWidget);
    expect(find.text('LV1-月付'), findsOneWidget);
    expect(find.text('复制订单号'), findsWidgets);
  });
}
