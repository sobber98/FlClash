import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import 'constant.dart';
import 'system.dart';

class AutoLaunch {
  static AutoLaunch? _instance;

  AutoLaunch._internal() {
    launchAtStartup.setup(
      appName: appName,
      appPath: Platform.resolvedExecutable,
    );
  }

  factory AutoLaunch() {
    _instance ??= AutoLaunch._internal();
    return _instance!;
  }

  Future<bool> get isEnable async {
    return await launchAtStartup.isEnabled();
  }

  Future<bool> enable() async {
    final result = await launchAtStartup.enable();
    _syncLinuxDesktopIcon();
    return result;
  }

  Future<bool> disable() async {
    return await launchAtStartup.disable();
  }

  Future<void> updateStatus(bool isAutoLaunch) async {
    if (kDebugMode) {
      return;
    }
    if (await isEnable == isAutoLaunch) {
      if (isAutoLaunch) {
        _syncLinuxDesktopIcon();
      }
      return;
    }
    if (isAutoLaunch == true) {
      await enable();
    } else {
      await disable();
    }
  }

  void _syncLinuxDesktopIcon() {
    if (!system.isLinux) {
      return;
    }
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      return;
    }
    final desktopFile = File('$home/.config/autostart/$appName.desktop');
    if (!desktopFile.existsSync()) {
      return;
    }
    final iconPath =
        '${File(Platform.resolvedExecutable).parent.path}/data/flutter_assets/assets/images/icon.png';
    final lines = desktopFile.readAsLinesSync();
    final iconLine = 'Icon=$iconPath';
    final iconIndex = lines.indexWhere((line) => line.startsWith('Icon='));
    if (iconIndex >= 0) {
      lines[iconIndex] = iconLine;
    } else {
      lines.add(iconLine);
    }
    desktopFile.writeAsStringSync('${lines.join('\n')}\n');
  }
}

final autoLaunch = system.isDesktop ? AutoLaunch() : null;
