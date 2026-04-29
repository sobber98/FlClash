import 'package:v2box/controller.dart';
import 'package:v2box/enum/enum.dart';
import 'package:v2box/models/models.dart';
import 'package:flutter/material.dart';

class CommonPrint {
  static CommonPrint? _instance;

  CommonPrint._internal();

  factory CommonPrint() {
    _instance ??= CommonPrint._internal();
    return _instance!;
  }

  void log(String? text, {LogLevel logLevel = LogLevel.info}) {
    final payload = '[APP] $text';
    debugPrint(payload);
    if (!appController.isAttach) {
      return;
    }
    appController.addLog(Log.app(payload).copyWith(logLevel: logLevel));
  }
}

final commonPrint = CommonPrint();
