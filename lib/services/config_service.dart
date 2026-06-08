import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:v2box/common/preferences.dart';
import 'package:v2box/models/app_config.dart';
import 'package:v2box/models/build_config.dart';
import 'package:flutter/services.dart';

class ConfigService {
  static const _buildConfigAssetPath = 'build.config.json';
  static const _configAssetPath = 'assets/config.json';
  static const _configCacheKey = 'app_config_cache';

  final Dio _dio;
  final Future<BuildConfig> Function()? _buildConfigLoader;
  final Future<AppConfig> Function()? _localConfigLoader;
  final Future<AppConfig?> Function()? _cachedConfigLoader;
  final Future<AppConfig> Function(String ossUrl)? _ossConfigLoader;
  final Future<void> Function(AppConfig config)? _cacheWriter;
  final Future<bool> Function(String serverUrl)? _serverReachabilityChecker;

  ConfigService({
    Dio? dio,
    Future<BuildConfig> Function()? buildConfigLoader,
    Future<AppConfig> Function()? localConfigLoader,
    Future<AppConfig?> Function()? cachedConfigLoader,
    Future<AppConfig> Function(String ossUrl)? ossConfigLoader,
    Future<void> Function(AppConfig config)? cacheWriter,
    Future<bool> Function(String serverUrl)? serverReachabilityChecker,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 8),
               receiveTimeout: const Duration(seconds: 8),
               sendTimeout: const Duration(seconds: 8),
             ),
           ),
       _buildConfigLoader = buildConfigLoader,
       _localConfigLoader = localConfigLoader,
       _cachedConfigLoader = cachedConfigLoader,
       _ossConfigLoader = ossConfigLoader,
       _cacheWriter = cacheWriter,
       _serverReachabilityChecker = serverReachabilityChecker;

  Future<AppConfig> load({bool forceRemote = false}) async {
    final buildConfig = await loadBuildConfig();
    final localConfig = await loadLocalConfig();
    final cachedConfig = await loadCachedConfig();
    final remoteUrl = buildConfig.ossUrl;
    final cachedMergedConfig = cachedConfig == null
        ? null
        : localConfig.merge(cachedConfig);

    if (remoteUrl.isEmpty) {
      return cachedMergedConfig ?? localConfig;
    }

    if (!forceRemote &&
        cachedMergedConfig != null &&
        cachedMergedConfig.blockedNodeKeywords.isNotEmpty &&
        cachedMergedConfig.updateManifestUrl.isNotEmpty) {
      final cachedServerUrl = cachedMergedConfig.resolvedServerUrl;
      if (cachedServerUrl.isNotEmpty &&
          await isServerReachable(cachedServerUrl)) {
        return cachedMergedConfig;
      }
    }

    try {
      final remoteConfig = await loadOSSConfig(remoteUrl);
      final mergedConfig = localConfig.merge(remoteConfig);
      await cacheConfig(mergedConfig);
      return mergedConfig;
    } catch (_) {
      if (cachedMergedConfig != null) {
        return cachedMergedConfig;
      }
      if (forceRemote) {
        rethrow;
      }
      return localConfig;
    }
  }

  Future<BuildConfig> loadBuildConfig() async {
    final loader = _buildConfigLoader;
    if (loader != null) {
      return loader();
    }
    try {
      final raw = await rootBundle.loadString(_buildConfigAssetPath);
      final data = json.decode(raw);
      if (data is Map<String, dynamic>) {
        return BuildConfig.fromJson(data);
      }
      if (data is Map) {
        return BuildConfig.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {
      // Ignore invalid build configuration and keep immutable defaults.
    }
    return const BuildConfig();
  }

  Future<AppConfig> loadLocalConfig() async {
    final loader = _localConfigLoader;
    if (loader != null) {
      return loader();
    }
    try {
      final raw = await rootBundle.loadString(_configAssetPath);
      final data = json.decode(raw);
      if (data is Map<String, dynamic>) {
        return AppConfig.defaults().merge(AppConfig.fromJson(data));
      }
      if (data is Map) {
        return AppConfig.defaults().merge(
          AppConfig.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    } catch (_) {
      // Ignore invalid local configuration and keep defaults.
    }
    return AppConfig.defaults();
  }

  Future<AppConfig?> loadCachedConfig() async {
    final loader = _cachedConfigLoader;
    if (loader != null) {
      return loader();
    }
    try {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      final raw = prefs?.getString(_configCacheKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final data = json.decode(raw);
      if (data is Map<String, dynamic>) {
        return AppConfig.fromJson(data);
      }
      if (data is Map) {
        return AppConfig.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {
      // Ignore cache corruption and fallback to local config.
    }
    return null;
  }

  Future<AppConfig> loadOSSConfig(String ossUrl) async {
    final loader = _ossConfigLoader;
    if (loader != null) {
      return loader(ossUrl);
    }
    final response = await _dio.get<dynamic>(ossUrl);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return AppConfig.fromJson(data);
    }
    if (data is Map) {
      return AppConfig.fromJson(Map<String, dynamic>.from(data));
    }
    if (data is String) {
      final decoded = json.decode(data);
      if (decoded is Map<String, dynamic>) {
        return AppConfig.fromJson(decoded);
      }
      if (decoded is Map) {
        return AppConfig.fromJson(Map<String, dynamic>.from(decoded));
      }
    }
    throw const FormatException('Invalid OSS config format');
  }

  Future<void> cacheConfig(AppConfig config) async {
    final writer = _cacheWriter;
    if (writer != null) {
      return writer(config);
    }
    final prefs = await preferences.sharedPreferencesCompleter.future;
    await prefs?.setString(_configCacheKey, json.encode(config.toJson()));
  }

  Future<bool> isServerReachable(String serverUrl) async {
    final checker = _serverReachabilityChecker;
    if (checker != null) {
      return checker(serverUrl);
    }
    final normalizedServerUrl = serverUrl.trim().replaceFirst(
      RegExp(r'/+$'),
      '',
    );
    if (normalizedServerUrl.isEmpty) {
      return false;
    }
    try {
      final response = await _dio.get<dynamic>(
        '$normalizedServerUrl/guest/comm/config',
      );
      final statusCode = response.statusCode ?? 0;
      return statusCode >= 200 && statusCode < 400;
    } catch (_) {
      return false;
    }
  }
}
