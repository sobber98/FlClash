import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/models/app_config.dart';
import 'package:flutter/services.dart';

class ConfigService {
  static const _configAssetPath = 'assets/config.json';
  static const _configCacheKey = 'app_config_cache';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
    ),
  );

  Future<AppConfig> load({bool forceRemote = false}) async {
    final localConfig = await loadLocalConfig();
    final cachedConfig = await loadCachedConfig();
    final remoteUrl = localConfig.resolvedOssUrl.isNotEmpty
        ? localConfig.resolvedOssUrl
        : cachedConfig?.resolvedOssUrl ?? '';

    if (remoteUrl.isEmpty) {
      return localConfig;
    }

    try {
      final remoteConfig = await loadOSSConfig(remoteUrl);
      final mergedConfig = localConfig.merge(remoteConfig);
      await cacheConfig(mergedConfig);
      return mergedConfig;
    } catch (_) {
      if (cachedConfig != null) {
        return localConfig.merge(cachedConfig);
      }
      if (forceRemote) {
        rethrow;
      }
      return localConfig;
    }
  }

  Future<AppConfig> loadLocalConfig() async {
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
    final prefs = await preferences.sharedPreferencesCompleter.future;
    await prefs?.setString(_configCacheKey, json.encode(config.toJson()));
  }
}
