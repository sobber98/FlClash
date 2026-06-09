import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:v2box/common/migration.dart';
import 'package:v2box/models/app_config.dart';
import 'package:v2box/models/build_config.dart';
import 'package:v2box/providers/app_config.dart';
import 'package:v2box/services/config_service.dart';

import '../setup.dart' as setup;

void main() {
  test('cached reachable config is used without fetching OSS config', () async {
    var ossFetchCount = 0;
    final service = ConfigService(
      buildConfigLoader: () async =>
          const BuildConfig(ossUrl: 'https://oss.example.com/config.json'),
      localConfigLoader: () async => AppConfig.defaults(),
      cachedConfigLoader: () async => const AppConfig(
        serverUrl: 'https://cached.example.com/api/v1',
        blockedNodeKeywords: ['官网'],
        updateManifestUrl: 'https://oss.example.com/latest.json',
      ),
      ossConfigLoader: (_) async {
        ossFetchCount++;
        return const AppConfig(serverUrl: 'https://remote.example.com/api/v1');
      },
      serverReachabilityChecker: (_) async => true,
    );

    final config = await service.load();

    expect(config.serverUrl, 'https://cached.example.com/api/v1');
    expect(ossFetchCount, 0);
  });

  test(
    'cached reachable config without update manifest refreshes OSS config',
    () async {
      final writes = <AppConfig>[];
      final service = ConfigService(
        buildConfigLoader: () async =>
            const BuildConfig(ossUrl: 'https://oss.example.com/config.json'),
        localConfigLoader: () async => AppConfig.defaults(),
        cachedConfigLoader: () async => const AppConfig(
          serverUrl: 'https://cached.example.com/api/v1',
          blockedNodeKeywords: ['官网'],
        ),
        ossConfigLoader: (_) async => const AppConfig(
          serverUrl: 'https://cached.example.com/api/v1',
          blockedNodeKeywords: ['官网'],
          updateManifestUrl: 'https://oss.example.com/latest.json',
        ),
        cacheWriter: (config) async => writes.add(config),
        serverReachabilityChecker: (_) async => true,
      );

      final config = await service.load();

      expect(config.updateManifestUrl, 'https://oss.example.com/latest.json');
      expect(writes, hasLength(1));
      expect(
        writes.single.updateManifestUrl,
        'https://oss.example.com/latest.json',
      );
    },
  );

  test(
    'cached reachable config without blocked keywords refreshes OSS config',
    () async {
      final service = ConfigService(
        buildConfigLoader: () async =>
            const BuildConfig(ossUrl: 'https://oss.example.com/config.json'),
        localConfigLoader: () async => AppConfig.defaults(),
        cachedConfigLoader: () async =>
            const AppConfig(serverUrl: 'https://cached.example.com/api/v1'),
        ossConfigLoader: (_) async => const AppConfig(
          serverUrl: 'https://cached.example.com/api/v1',
          blockedNodeKeywords: ['官网'],
        ),
        serverReachabilityChecker: (_) async => true,
      );

      final config = await service.load();

      expect(config.blockedNodeKeywords, ['官网']);
    },
  );

  test(
    'unreachable cached server refreshes config from OSS and caches it',
    () async {
      final writes = <AppConfig>[];
      final service = ConfigService(
        buildConfigLoader: () async =>
            const BuildConfig(ossUrl: 'https://oss.example.com/config.json'),
        localConfigLoader: () async => AppConfig.defaults(),
        cachedConfigLoader: () async =>
            const AppConfig(serverUrl: 'https://old.example.com/api/v1'),
        ossConfigLoader: (_) async =>
            const AppConfig(serverUrl: 'https://new.example.com/api/v1'),
        cacheWriter: (config) async => writes.add(config),
        serverReachabilityChecker: (_) async => false,
      );

      final config = await service.load();

      expect(config.serverUrl, 'https://new.example.com/api/v1');
      expect(writes, hasLength(1));
      expect(writes.single.serverUrl, 'https://new.example.com/api/v1');
    },
  );

  test('cached config without server URL refreshes config from OSS', () async {
    final service = ConfigService(
      buildConfigLoader: () async =>
          const BuildConfig(ossUrl: 'https://oss.example.com/config.json'),
      localConfigLoader: () async => AppConfig.defaults(),
      cachedConfigLoader: () async => const AppConfig(supportEmail: 'old'),
      ossConfigLoader: (_) async =>
          const AppConfig(serverUrl: 'https://remote.example.com/api/v1'),
    );

    final config = await service.load();

    expect(config.serverUrl, 'https://remote.example.com/api/v1');
  });

  test('missing cache fetches config from OSS and caches it', () async {
    final writes = <AppConfig>[];
    final service = ConfigService(
      buildConfigLoader: () async =>
          const BuildConfig(ossUrl: 'https://oss.example.com/config.json'),
      localConfigLoader: () async => AppConfig.defaults(),
      cachedConfigLoader: () async => null,
      ossConfigLoader: (_) async =>
          const AppConfig(serverUrl: 'https://remote.example.com/api/v1'),
      cacheWriter: (config) async => writes.add(config),
    );

    final config = await service.load();

    expect(config.serverUrl, 'https://remote.example.com/api/v1');
    expect(writes, hasLength(1));
  });

  test('OSS failure falls back to cached config', () async {
    final service = ConfigService(
      buildConfigLoader: () async =>
          const BuildConfig(ossUrl: 'https://oss.example.com/config.json'),
      localConfigLoader: () async => AppConfig.defaults(),
      cachedConfigLoader: () async =>
          const AppConfig(serverUrl: 'https://cached.example.com/api/v1'),
      ossConfigLoader: (_) async => throw const FormatException('bad config'),
      serverReachabilityChecker: (_) async => false,
    );

    final config = await service.load();

    expect(config.serverUrl, 'https://cached.example.com/api/v1');
  });

  test('force remote bypasses reachable cache and updates it', () async {
    final writes = <AppConfig>[];
    final service = ConfigService(
      buildConfigLoader: () async =>
          const BuildConfig(ossUrl: 'https://oss.example.com/config.json'),
      localConfigLoader: () async => AppConfig.defaults(),
      cachedConfigLoader: () async =>
          const AppConfig(serverUrl: 'https://cached.example.com/api/v1'),
      ossConfigLoader: (_) async =>
          const AppConfig(serverUrl: 'https://remote.example.com/api/v1'),
      cacheWriter: (config) async => writes.add(config),
      serverReachabilityChecker: (_) async => true,
    );

    final config = await service.load(forceRemote: true);

    expect(config.serverUrl, 'https://remote.example.com/api/v1');
    expect(writes, hasLength(1));
  });

  test('runtime config does not own build-time fields', () {
    final config = AppConfig.fromJson({
      'appName': 'RemoteName',
      'logoUrl': 'https://example.com/logo.png',
      'ossUrl': 'https://example.com/config.json',
      'version': '1.2.3+4',
      'serverUrl': 'https://example.com/api/v1',
    });

    expect(config.toJson(), isNot(contains('appName')));
    expect(config.toJson(), isNot(contains('logoUrl')));
    expect(config.toJson(), isNot(contains('ossUrl')));
    expect(config.toJson(), isNot(contains('version')));
  });

  test('pubspec owns application build version', () {
    final previousCurrent = Directory.current;
    final tempDir = Directory.systemTemp.createTempSync(
      'flclash_pubspec_version_',
    );
    addTearDown(() {
      Directory.current = previousCurrent;
      tempDir.deleteSync(recursive: true);
    });
    Directory.current = tempDir;
    File('pubspec.yaml').writeAsStringSync('''
name: v2box
version: 2.3.4+5
''');
    File(
      'build.config.json',
    ).writeAsStringSync('{"appName":"v2box","version":"9.9.9+9"}');

    expect(setup.Build.version, '2.3.4+5');
  });

  test('migration enables auto update for existing app settings', () {
    final configMap = <String, Object?>{
      'appSettingProps': <String, Object?>{'autoCheckUpdate': false},
    };

    Migration.enableAutoCheckUpdateByDefault(configMap);

    expect(
      configMap,
      containsPair('appSettingProps', containsPair('autoCheckUpdate', true)),
    );
  });

  test('build version is converted to flutter build arguments', () {
    expect(
      setup.Build.flutterBuildArgsForVersion(
        'verbose,dart-define-from-file=env.json',
        '1.2.3+4',
      ),
      'verbose,dart-define-from-file=env.json,build-name=1.2.3,build-number=4',
    );
  });

  test('build env is forwarded to distributor process', () {
    expect(
      setup.Build.distributorEnvironment('stable'),
      containsPair('FLCLASH_BUILD_ENV', 'stable'),
    );
  });

  test(
    'manual update check reloads remote config when manifest URL is empty',
    () async {
      var didReload = false;
      final manifestUrl = await resolveUpdateManifestUrl(
        userUrl: '',
        configUrl: '',
        reloadConfig: () async {
          didReload = true;
        },
        readConfigUrl: () => 'https://oss.example.com/latest.json',
      );

      expect(didReload, isTrue);
      expect(manifestUrl, 'https://oss.example.com/latest.json');
    },
  );

  test(
    'manual update check keeps empty URL when remote reload has no manifest',
    () async {
      var didReload = false;
      final manifestUrl = await resolveUpdateManifestUrl(
        userUrl: '',
        configUrl: '',
        reloadConfig: () async {
          didReload = true;
        },
        readConfigUrl: () => '',
      );

      expect(didReload, isTrue);
      expect(manifestUrl, isEmpty);
    },
  );

  test(
    'manual update check prefers user manifest URL without reload',
    () async {
      var didReload = false;
      final manifestUrl = await resolveUpdateManifestUrl(
        userUrl: ' https://user.example.com/latest.json ',
        configUrl: '',
        reloadConfig: () async {
          didReload = true;
        },
        readConfigUrl: () => 'https://oss.example.com/latest.json',
      );

      expect(didReload, isFalse);
      expect(manifestUrl, 'https://user.example.com/latest.json');
    },
  );

  test('release Android workflow forwards signing env to build step', () {
    final workflow = File('.github/workflows/build.yaml').readAsStringSync();
    final buildStep = workflow.substring(
      workflow.indexOf('      - name: Build Android APK'),
      workflow.indexOf('      - name: Upload Android artifacts'),
    );

    expect(buildStep, contains('ANDROID_STORE_PASSWORD'));
    expect(buildStep, contains('ANDROID_KEY_ALIAS'));
    expect(buildStep, contains('ANDROID_KEY_PASSWORD'));
  });
}
