import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:v2box/l10n/l10n.dart';
import 'package:v2box/pages/home.dart';
import 'package:v2box/providers/providers.dart';

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
}
