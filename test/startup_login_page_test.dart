import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2box/enum/enum.dart';
import 'package:v2box/l10n/l10n.dart';
import 'package:v2box/models/models.dart';
import 'package:v2box/pages/home.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/services/v2board/v2board.dart';

class _LoadingAppConfigNotifier extends AppConfigNotifier {
  @override
  Future<AppConfig> build() => Completer<AppConfig>().future;
}

const _loggedInProps = V2BoardProps(
  serverUrl: 'https://example.com',
  authData: 'Bearer token',
  subscribeToken: 'subscribe-token',
  email: 'test@rnmtq.eu',
);

const _desktopNavigationItems = [
  NavigationItem(
    keep: false,
    icon: Icon(Icons.home_filled),
    label: PageLabel.dashboard,
    builder: _emptyPage,
  ),
  NavigationItem(
    keep: false,
    icon: Icon(Icons.person_rounded),
    label: PageLabel.profile,
    builder: _emptyPage,
  ),
];

Widget _emptyPage(BuildContext context) => const SizedBox();

void main() {
  testWidgets('startup login page fills the desktop client window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v2boardSettingProvider.overrideWithValue(null),
          appDisplayNameProvider.overrideWithValue('v2box'),
          appServerUrlProvider.overrideWithValue('https://example.com'),
          appEnableRegistrationProvider.overrideWithValue(true),
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
          home: const HomePage(),
        ),
      ),
    );

    final scaffoldRect = tester.getRect(find.byType(Scaffold));
    final loginShellRect = tester.getRect(
      find.byKey(const ValueKey('startup-login-shell')),
    );

    expect(loginShellRect.topLeft, scaffoldRect.topLeft);
    expect(loginShellRect.size, scaffoldRect.size);
  });

  testWidgets('register tab switches inline instead of opening register page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v2boardSettingProvider.overrideWithValue(null),
          appDisplayNameProvider.overrideWithValue('v2box'),
          appServerUrlProvider.overrideWithValue(''),
          appEnableRegistrationProvider.overrideWithValue(true),
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
          home: const HomePage(),
        ),
      ),
    );

    await tester.tap(find.text('注册'));
    await tester.pumpAndSettle();

    expect(find.text('创建账户并开始'), findsOneWidget);
    expect(find.text('邮箱验证码'), findsOneWidget);
    expect(find.byKey(const ValueKey('startup-login-shell')), findsOneWidget);
    expect(find.byKey(const ValueKey('register-page-shell')), findsNothing);
  });

  testWidgets(
    'startup login waits for remote config before showing no service',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            v2boardSettingProvider.overrideWithValue(null),
            appConfigProvider.overrideWith(_LoadingAppConfigNotifier.new),
            appDisplayNameProvider.overrideWithValue('v2box'),
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
            home: const HomePage(),
          ),
        ),
      );

      expect(find.text('登录服务暂未配置，请联系管理员。'), findsNothing);
    },
  );

  testWidgets('desktop register form fits in the first viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v2boardSettingProvider.overrideWithValue(null),
          appDisplayNameProvider.overrideWithValue('v2box'),
          appServerUrlProvider.overrideWithValue('https://example.com'),
          appEnableRegistrationProvider.overrideWithValue(true),
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
          home: const HomePage(),
        ),
      ),
    );

    await tester.tap(find.text('注册'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
      findsNothing,
    );

    final scaffoldRect = tester.getRect(find.byType(Scaffold));
    for (final text in const ['邮箱', '密码', '确认密码', '邀请码', '邮箱验证码', '创建账户并开始']) {
      final rect = tester.getRect(find.text(text).first);
      expect(
        scaffoldRect.contains(rect.topLeft) &&
            scaffoldRect.contains(rect.bottomRight),
        isTrue,
        reason: '$text should be visible without vertical scrolling',
      );
    }
  });

  testWidgets('compact desktop register form fits without vertical scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(960, 650);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v2boardSettingProvider.overrideWithValue(null),
          appDisplayNameProvider.overrideWithValue('v2box'),
          appServerUrlProvider.overrideWithValue('https://example.com'),
          appEnableRegistrationProvider.overrideWithValue(true),
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
          home: const HomePage(),
        ),
      ),
    );

    await tester.tap(find.text('注册'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
      findsNothing,
    );
  });

  testWidgets('desktop sidebar shows connection summary instead of user card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(960, 650);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v2boardSettingProvider.overrideWithValue(_loggedInProps),
          appDisplayNameProvider.overrideWithValue('v2box'),
          viewSizeProvider.overrideWithValue(const Size(960, 650)),
          currentNavigationItemsStateProvider.overrideWithValue(
            const NavigationItemsState(value: _desktopNavigationItems),
          ),
          currentProfileProvider.overrideWithValue(
            const Profile(
              id: 1,
              currentGroupName: 'HK',
              autoUpdateDuration: Duration.zero,
              selectedMap: {'HK': '香港B'},
            ),
          ),
          groupsProvider.overrideWithValue([
            const Group(
              type: GroupType.Selector,
              name: 'HK',
              all: [Proxy(name: '香港B', type: 'ss')],
            ),
          ]),
          coreStatusProvider.overrideWithValue(CoreStatus.connected),
          runTimeProvider.overrideWithValue(1),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('desktop-connection-summary')),
      findsOneWidget,
    );
    expect(find.text('已连接'), findsOneWidget);
    expect(find.text('香港B'), findsOneWidget);
    expect(find.text('test@rnmtq.eu'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomePage)),
    );
    expect(container.read(currentPageLabelProvider), PageLabel.dashboard);

    await tester.tap(find.byKey(const ValueKey('desktop-connection-summary')));
    await tester.pump();

    expect(container.read(currentPageLabelProvider), PageLabel.dashboard);
  });
}
