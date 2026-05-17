import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
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

class _ApiReadyNoticesNotifier extends V2boardNotices {
  @override
  AsyncValue<List<V2BoardNotice>> build() {
    return const AsyncData([]);
  }

  @override
  Future<void> fetch() async {
    if (ref.read(v2boardApiClientProvider) == null) {
      return;
    }
    state = const AsyncData(_notices);
  }
}

class _NoopUserNotifier extends V2boardUser {
  @override
  AsyncValue<V2BoardUser?> build() {
    return const AsyncData(null);
  }

  @override
  Future<void> fetch() async {}
}

class _NoopSubscriptionNotifier extends V2boardSubscription {
  @override
  AsyncValue<V2BoardSubscription?> build() {
    return const AsyncData(null);
  }

  @override
  Future<void> fetch() async {}
}

class _NoopPlansNotifier extends V2boardPlans {
  @override
  AsyncValue<List<V2BoardPlan>> build() {
    return const AsyncData([]);
  }

  @override
  Future<void> fetch() async {}
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required Size size,
  required bool isMobile,
  ProviderContainer? container,
  List<Override> extraOverrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final overrides = [
    isMobileViewProvider.overrideWithValue(isMobile),
    v2boardApiClientProvider.overrideWithValue(null),
    v2boardNoticesProvider.overrideWith(_RefreshingNoticesNotifier.new),
    v2boardUserProvider.overrideWith(_NoopUserNotifier.new),
    v2boardSubscriptionProvider.overrideWith(_NoopSubscriptionNotifier.new),
    v2boardPlansProvider.overrideWith(_NoopPlansNotifier.new),
    currentProfileProvider.overrideWithValue(null),
    ...extraOverrides,
  ];
  final app = MaterialApp(
    locale: const Locale('zh', 'CN'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.delegate.supportedLocales,
    home: const DashboardView(),
  );

  await tester.pumpWidget(
    container == null
        ? ProviderScope(overrides: overrides, child: app)
        : UncontrolledProviderScope(container: container, child: app),
  );
  await tester.pump();
}

ProviderContainer _dashboardContainer({
  required bool isMobile,
  required List<Override> extraOverrides,
}) {
  final container = ProviderContainer(
    overrides: [
      isMobileViewProvider.overrideWithValue(isMobile),
      currentProfileProvider.overrideWithValue(null),
      v2boardUserProvider.overrideWith(_NoopUserNotifier.new),
      v2boardSubscriptionProvider.overrideWith(_NoopSubscriptionNotifier.new),
      v2boardPlansProvider.overrideWith(_NoopPlansNotifier.new),
      ...extraOverrides,
    ],
  );
  return container;
}

Future<void> _pumpDashboardWithContainer(
  WidgetTester tester, {
  required Size size,
  required ProviderContainer container,
}) async {
  await _pumpDashboard(
    tester,
    size: size,
    isMobile: false,
    container: container,
  );
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

  testWidgets('dashboard fetches notices when api client becomes ready', (
    tester,
  ) async {
    final container = _dashboardContainer(
      isMobile: false,
      extraOverrides: [
        v2boardNoticesProvider.overrideWith(_ApiReadyNoticesNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await _pumpDashboardWithContainer(
      tester,
      size: const Size(1080, 600),
      container: container,
    );

    expect(find.text('最新公告'), findsNothing);

    container
        .read(v2boardApiClientProvider.notifier)
        .init('https://example.com', authData: 'Bearer token');
    await tester.pump();
    await tester.pump();

    expect(find.text('最新公告'), findsOneWidget);
    expect(find.textContaining('维护通知'), findsOneWidget);
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
