import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:fl_clash/pages/error.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application.dart';
import 'common/common.dart';

Future<void> main(List<String> args) async {
  try {
    if (runWebViewTitleBarWidget(args)) {
      return;
    }
    WidgetsFlutterBinding.ensureInitialized();
    final version = await system.version;
    final container = await globalState.init(version);
    HttpOverrides.global = FlClashHttpOverrides();
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const Application(),
      ),
    );
  } catch (e, s) {
    return runApp(
      MaterialApp(
        home: InitErrorScreen(error: e, stack: s),
      ),
    );
  }
}
