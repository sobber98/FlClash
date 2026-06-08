import 'package:v2box/common/common.dart';
import 'package:v2box/models/models.dart';

class Migration {
  static Migration? _instance;
  late int _oldVersion;

  Migration._internal();

  final currentVersion = 3;

  factory Migration() {
    _instance ??= Migration._internal();
    return _instance!;
  }

  Future<Config> migrationIfNeeded(
    Map<String, Object?>? configMap, {
    required Future<Config> Function(MigrationData data) sync,
  }) async {
    _oldVersion = await preferences.getVersion();
    if (_oldVersion == currentVersion) {
      try {
        return Config.realFromJson(configMap);
      } catch (_) {
        final isV0 = configMap?['proxiesStyle'] != null;
        if (isV0) {
          _oldVersion = 0;
        } else {
          throw 'Local data is damaged. A reset is required to fix this issue.';
        }
      }
    }
    MigrationData data = MigrationData(configMap: configMap);
    if (_oldVersion == 0 && configMap != null) {
      final clashConfigMap = await preferences.getClashConfigMap();
      if (clashConfigMap != null) {
        configMap['patchClashConfig'] = clashConfigMap;
        await preferences.clearClashConfig();
      }
      data = await _oldToNow(configMap);
    }
    if (_oldVersion < 2 && data.configMap != null) {
      _migrateThemeToLight(data.configMap!);
    }
    if (_oldVersion < 3 && data.configMap != null) {
      enableAutoCheckUpdateByDefault(data.configMap!);
    }
    final res = await sync(data);
    await preferences.setVersion(currentVersion);
    return res;
  }

  /// 将 themeMode 从 system 强制迁移为 light，与 Android 客户端默认行为对齐。
  void _migrateThemeToLight(Map<String, Object?> configMap) {
    final themeProps = configMap['themeProps'];
    if (themeProps is Map) {
      if (themeProps['themeMode'] == 'system') {
        themeProps['themeMode'] = 'light';
      }
    }
  }

  static void enableAutoCheckUpdateByDefault(Map<String, Object?> configMap) {
    final appSettingProps = configMap['appSettingProps'];
    if (appSettingProps is Map) {
      appSettingProps['autoCheckUpdate'] = true;
    } else {
      configMap['appSettingProps'] = <String, Object?>{'autoCheckUpdate': true};
    }
  }

  Future<MigrationData> _oldToNow(Map<String, Object?> configMap) async {
    return await oldToNowTask(configMap);
  }
}

final migration = Migration();
