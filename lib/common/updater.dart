import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:path/path.dart';

import 'common.dart';

enum AppUpdateExceptionType { installPermissionRequired, installFailed }

class AppUpdateException implements Exception {
  final AppUpdateExceptionType type;
  final String message;

  const AppUpdateException({required this.type, required this.message});

  @override
  String toString() => message;
}

class AppUpdater {
  const AppUpdater._();

  static bool get isSupported => system.isAndroid || system.isWindows;

  static Future<String?> getCurrentPlatformKey() async {
    if (system.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      final abi = info.supportedAbis.firstWhere(
        (value) => value.isNotEmpty,
        orElse: () => '',
      );
      if (abi.contains('arm64')) {
        return 'android-arm64-v8a';
      }
      if (abi.contains('x86_64')) {
        return 'android-x86_64';
      }
      if (abi.contains('armeabi') || abi.contains('arm')) {
        return 'android-armeabi-v7a';
      }
      return null;
    }
    if (system.isWindows) {
      final arch = (Platform.environment['PROCESSOR_ARCHITEW6432'] ??
              Platform.environment['PROCESSOR_ARCHITECTURE'] ??
              '')
          .toLowerCase();
      if (arch.contains('arm64')) {
        return 'windows-arm64';
      }
      return 'windows-amd64';
    }
    return null;
  }

  static Future<UpdateAsset?> pickAsset(UpdateManifest manifest) async {
    final platformKey = await getCurrentPlatformKey();
    if (platformKey == null) {
      return null;
    }
    return manifest.assets[platformKey];
  }

  static Future<File> preparePackageFile(UpdateAsset asset) async {
    final cacheDir = await appPath.cacheDir.future;
    final updateDir = Directory(join(cacheDir.path, 'updates'));
    if (!await updateDir.exists()) {
      await updateDir.create(recursive: true);
    }
    final fileName = _fileNameFor(asset);
    final file = File(join(updateDir.path, fileName));
    await file.safeDelete();
    return file;
  }

  static Future<File> downloadPackage({
    required UpdateAsset asset,
    required void Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    final file = await preparePackageFile(asset);
    try {
      await request.downloadUpdate(
        asset: asset,
        savePath: file.path,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );
    } catch (_) {
      await file.safeDelete();
      rethrow;
    }
    return file;
  }

  static Future<bool> verifyPackage(File file, String expectedSha256) async {
    final digest = (await sha256.bind(file.openRead()).first).toString();
    return digest.toLowerCase() == expectedSha256.toLowerCase();
  }

  static Future<void> installPackage(File file) async {
    if (system.isAndroid) {
      final result = await app?.installApk(file.path);
      switch (result) {
        case ApkInstallResult.started:
          return;
        case ApkInstallResult.permissionRequired:
          throw AppUpdateException(
            type: AppUpdateExceptionType.installPermissionRequired,
            message: appLocalizations.installPermissionRequired,
          );
        case ApkInstallResult.failed:
        case null:
          throw AppUpdateException(
            type: AppUpdateExceptionType.installFailed,
            message: appLocalizations.installFailed,
          );
      }
    }
    if (system.isWindows) {
      await Process.start(
        file.path,
        const [],
        mode: ProcessStartMode.detached,
        runInShell: false,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      exit(0);
    }
  }

  static String _fileNameFor(UpdateAsset asset) {
    final uri = Uri.tryParse(asset.url);
    if (uri == null || uri.pathSegments.isEmpty) {
      return 'flclash-update.bin';
    }
    return uri.pathSegments.last;
  }
}