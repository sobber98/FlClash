import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2box/l10n/l10n.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/services/v2board/v2board.dart';
import 'package:v2box/views/dashboard/dashboard.dart';

const _notices = [
  V2BoardNotice(
    id: 1,
    title: '维护通知',
    content: '<p>今晚 23:00 进行线路维护，请提前切换节点。</p>',
    createdAt: 1779000000,
  ),
];

class _RefreshingNoticesNotifier extends V2boardNotices {
  @override
  AsyncValue<List<V2BoardNotice>> build() {
    // ignore: invalid_use_of_internal_member
    return const AsyncLoading<List<V2BoardNotice>>().copyWithPrevious(
      const AsyncData(_notices),
    );
  }

  @override
  Future<void> fetch() async {}
}

Future<void> _pumpDashboard(
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
        v2boardNoticesProvider.overrideWith(_RefreshingNoticesNotifier.new),
        currentProfileProvider.overrideWithValue(null),
      ],
      child: MaterialApp(
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        home: const DashboardView(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('dashboard keeps notice content visible while refreshing', (
    tester,
  ) async {
    await _pumpDashboard(tester, size: const Size(1080, 600), isMobile: false);

    expect(find.text('最新公告'), findsOneWidget);
    expect(find.textContaining('维护通知'), findsOneWidget);
    expect(find.textContaining('今晚 23:00'), findsOneWidget);
  });

  testWidgets('desktop dashboard action cards align to the same row height', (
    tester,
  ) async {
    await _pumpDashboard(tester, size: const Size(1080, 600), isMobile: false);

    final tunCard = tester.getRect(
      find.byKey(const ValueKey('dashboard-tun-card')),
    );
    final outboundCard = tester.getRect(
      find.byKey(const ValueKey('dashboard-outbound-card')),
    );

    expect(tunCard.top, closeTo(outboundCard.top, 1));
    expect(tunCard.bottom, closeTo(outboundCard.bottom, 1));
  });
}
