import 'package:v2box/enum/enum.dart';
import 'package:v2box/models/app_config.dart';
import 'package:v2box/services/config_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appConfigProvider = AsyncNotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
);

class AppConfigNotifier extends AsyncNotifier<AppConfig> {
  late final ConfigService _service;

  @override
  Future<AppConfig> build() async {
    _service = ConfigService();
    return _service.load();
  }

  Future<void> reload({bool forceRemote = true}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _service.load(forceRemote: forceRemote),
    );
  }
}

final appServerUrlProvider = Provider<String>((ref) {
  return ref
      .watch(appConfigProvider)
      .maybeWhen(data: (config) => config.resolvedServerUrl, orElse: () => '');
});

final appDisplayNameProvider = Provider<String>((ref) {
  return ref
      .watch(appConfigProvider)
      .maybeWhen(
        data: (config) => config.resolvedAppName,
        orElse: () => 'FlClash',
      );
});

final appEnableRegistrationProvider = Provider<bool>((ref) {
  return ref
      .watch(appConfigProvider)
      .maybeWhen(
        data: (config) => config.resolvedEnableRegistration,
        orElse: () => true,
      );
});

final appDefaultModeProvider = Provider<Mode?>((ref) {
  return ref
      .watch(appConfigProvider)
      .maybeWhen(data: (config) => config.defaultMode, orElse: () => null);
});

final blockedNodeKeywordsProvider = Provider<List<String>>((ref) {
  return ref
      .watch(appConfigProvider)
      .maybeWhen(
        data: (config) => config.blockedNodeKeywords,
        orElse: () => const [],
      );
});

final appUpdateManifestUrlProvider = Provider<String>((ref) {
  return ref
      .watch(appConfigProvider)
      .maybeWhen(
        data: (config) => config.updateManifestUrl,
        orElse: () => '',
      );
});
