import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/services/v2board/v2board.dart';
import 'package:v2box/views/subscription/plan_detail_view.dart';

const _plan = V2BoardPlan(
  id: 1,
  name: 'LV1-月付',
  content: '每月 100G 流量\n工单客服支持\n支持 SS、V2Ray 节点\n解锁 Netflix、YouTube 等流媒体',
  transferEnable: 100 * 1024 * 1024 * 1024,
  monthPrice: 1500,
  resetPrice: 800,
  quarterPrice: 4200,
);

Future<void> _pumpPlanDetail(
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
      ],
      child: const MaterialApp(home: PlanDetailView(plan: _plan)),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('desktop package detail uses a two-column checkout layout', (
    tester,
  ) async {
    await _pumpPlanDetail(tester, size: const Size(1200, 800), isMobile: false);

    expect(
      find.byKey(const ValueKey('plan-detail-desktop-grid')),
      findsOneWidget,
    );
    expect(find.text('订单摘要'), findsOneWidget);
    expect(find.text('立即支付'), findsOneWidget);
  });

  testWidgets('mobile package detail exposes a sticky payment bar', (
    tester,
  ) async {
    await _pumpPlanDetail(tester, size: const Size(390, 844), isMobile: true);

    expect(
      find.byKey(const ValueKey('plan-detail-mobile-sticky-pay')),
      findsOneWidget,
    );
    expect(find.text('¥15.00'), findsWidgets);
    expect(find.text('立即支付'), findsOneWidget);
  });
}
