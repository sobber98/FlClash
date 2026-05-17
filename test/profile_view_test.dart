import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2box/models/app_config.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/services/v2board/v2board.dart';
import 'package:v2box/views/profile/profile_view.dart';

class _TestAppConfigNotifier extends AppConfigNotifier {
  @override
  Future<AppConfig> build() async => AppConfig.defaults();
}

class _TestUserNotifier extends V2boardUser {
  @override
  AsyncValue<V2BoardUser?> build() {
    return const AsyncData(V2BoardUser(email: 'user@example.com'));
  }

  @override
  Future<void> fetch() async {}
}

class _TestSubscriptionNotifier extends V2boardSubscription {
  @override
  AsyncValue<V2BoardSubscription?> build() {
    return const AsyncData(V2BoardSubscription());
  }

  @override
  Future<void> fetch() async {}
}

class _TestPlansNotifier extends V2boardPlans {
  @override
  AsyncValue<List<V2BoardPlan>> build() {
    return const AsyncData([]);
  }

  @override
  Future<void> fetch() async {}
}

Future<void> _pumpProfile(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        isMobileViewProvider.overrideWithValue(false),
        v2boardSettingProvider.overrideWithValue(
          const V2BoardProps(
            serverUrl: 'https://example.com',
            authData: 'Bearer token',
          ),
        ),
        v2boardApiClientProvider.overrideWithValue(null),
        v2boardUserProvider.overrideWith(_TestUserNotifier.new),
        v2boardSubscriptionProvider.overrideWith(_TestSubscriptionNotifier.new),
        v2boardPlansProvider.overrideWith(_TestPlansNotifier.new),
        currentPlanProvider.overrideWithValue(null),
        appConfigProvider.overrideWith(_TestAppConfigNotifier.new),
      ],
      child: const MaterialApp(home: ProfileView()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('support actions share the plain list tile style', (
    tester,
  ) async {
    await _pumpProfile(tester);

    expect(find.text('订单记录'), findsOneWidget);
    expect(find.text('流量明细'), findsOneWidget);
    expect(
      find.ancestor(of: find.text('订单记录'), matching: find.byType(ListTile)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: find.text('流量明细'), matching: find.byType(ListTile)),
      findsOneWidget,
    );
  });
}
