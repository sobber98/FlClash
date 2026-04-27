import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/theme.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CloseConnectionsItem extends ConsumerWidget {
  const CloseConnectionsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final closeConnections = ref.watch(
      appSettingProvider.select((state) => state.closeConnections),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.autoCloseConnections),
      subtitle: Text(appLocalizations.autoCloseConnectionsDesc),
      delegate: SwitchDelegate(
        value: closeConnections,
        onChanged: (value) async {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(closeConnections: value));
        },
      ),
    );
  }
}

class UsageItem extends ConsumerWidget {
  const UsageItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final onlyStatisticsProxy = ref.watch(
      appSettingProvider.select((state) => state.onlyStatisticsProxy),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.onlyStatisticsProxy),
      subtitle: Text(appLocalizations.onlyStatisticsProxyDesc),
      delegate: SwitchDelegate(
        value: onlyStatisticsProxy,
        onChanged: (bool value) async {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(onlyStatisticsProxy: value));
        },
      ),
    );
  }
}

class MinimizeItem extends ConsumerWidget {
  const MinimizeItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minimizeOnExit = ref.watch(
      appSettingProvider.select((state) => state.minimizeOnExit),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.minimizeOnExit),
      subtitle: Text(appLocalizations.minimizeOnExitDesc),
      delegate: SwitchDelegate(
        value: minimizeOnExit,
        onChanged: (bool value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(minimizeOnExit: value));
        },
      ),
    );
  }
}

class AutoLaunchItem extends ConsumerWidget {
  const AutoLaunchItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLaunch = ref.watch(
      appSettingProvider.select((state) => state.autoLaunch),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.autoLaunch),
      subtitle: Text(appLocalizations.autoLaunchDesc),
      delegate: SwitchDelegate(
        value: autoLaunch,
        onChanged: (bool value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(autoLaunch: value));
        },
      ),
    );
  }
}

class SilentLaunchItem extends ConsumerWidget {
  const SilentLaunchItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final silentLaunch = ref.watch(
      appSettingProvider.select((state) => state.silentLaunch),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.silentLaunch),
      subtitle: Text(appLocalizations.silentLaunchDesc),
      delegate: SwitchDelegate(
        value: silentLaunch,
        onChanged: (bool value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(silentLaunch: value));
        },
      ),
    );
  }
}

class AutoRunItem extends ConsumerWidget {
  const AutoRunItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoRun = ref.watch(
      appSettingProvider.select((state) => state.autoRun),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.autoRun),
      subtitle: Text(appLocalizations.autoRunDesc),
      delegate: SwitchDelegate(
        value: autoRun,
        onChanged: (bool value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(autoRun: value));
        },
      ),
    );
  }
}

class HiddenItem extends ConsumerWidget {
  const HiddenItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(
      appSettingProvider.select((state) => state.hidden),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.exclude),
      subtitle: Text(appLocalizations.excludeDesc),
      delegate: SwitchDelegate(
        value: hidden,
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(hidden: value));
        },
      ),
    );
  }
}

class AnimateTabItem extends ConsumerWidget {
  const AnimateTabItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnimateToPage = ref.watch(
      appSettingProvider.select((state) => state.isAnimateToPage),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.tabAnimation),
      subtitle: Text(appLocalizations.tabAnimationDesc),
      delegate: SwitchDelegate(
        value: isAnimateToPage,
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(isAnimateToPage: value));
        },
      ),
    );
  }
}

class OpenLogsItem extends ConsumerWidget {
  const OpenLogsItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openLogs = ref.watch(
      appSettingProvider.select((state) => state.openLogs),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.logcat),
      subtitle: Text(appLocalizations.logcatDesc),
      delegate: SwitchDelegate(
        value: openLogs,
        onChanged: (bool value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(openLogs: value));
        },
      ),
    );
  }
}

class CrashlyticsItem extends ConsumerWidget {
  const CrashlyticsItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crashlytics = ref.watch(
      appSettingProvider.select((state) => state.crashlytics),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.crashlytics),
      subtitle: Text(appLocalizations.crashlyticsTip),
      delegate: SwitchDelegate(
        value: crashlytics,
        onChanged: (bool value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(crashlytics: value));
        },
      ),
    );
  }
}

class AutoCheckUpdateItem extends ConsumerWidget {
  const AutoCheckUpdateItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoCheckUpdate = ref.watch(
      appSettingProvider.select((state) => state.autoCheckUpdate),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.autoCheckUpdate),
      subtitle: Text(appLocalizations.autoCheckUpdateDesc),
      delegate: SwitchDelegate(
        value: autoCheckUpdate,
        onChanged: (bool value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(autoCheckUpdate: value));
        },
      ),
    );
  }
}

class ApplicationSettingView extends ConsumerWidget {
  const ApplicationSettingView({super.key});

  String getLocaleString(Locale? locale) {
    if (locale == null) return appLocalizations.defaultText;
    return Intl.message(locale.toString());
  }

  Future<void> _showLocalePicker(BuildContext context, WidgetRef ref) async {
    final currentLocale = utils.getLocaleForString(
      ref.read(appSettingProvider).locale,
    );
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final locales = <Locale?>[
          null,
          ...AppLocalizations.delegate.supportedLocales,
        ];
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择语言',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '切换应用显示语言',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: locales.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final locale = locales[index];
                      final selected = locale == currentLocale;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            ref.read(appSettingProvider.notifier).update(
                                  (state) => state.copyWith(
                                    locale: locale?.toString(),
                                  ),
                                );
                            Navigator.of(context).pop();
                          },
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? context.colorScheme.onSurface
                                  : context.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    locale == null
                                        ? appLocalizations.defaultText
                                        : Intl.message(locale.toString()),
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(
                                          color: selected
                                              ? context.colorScheme.surface
                                              : context.colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check_rounded,
                                    color: context.colorScheme.surface,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pushThemePage(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ThemeView()));
  }

  Future<void> _showUpdateManifestUrlDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final currentValue = ref.read(appSettingProvider).updateManifestUrl;
    final value = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.updateManifestUrl,
        value: currentValue,
        hintText: defaultUpdateManifestUrlHint,
        validator: (value) {
          final uri = Uri.tryParse(value ?? '');
          if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
            return appLocalizations.updateSourceUrlInvalid;
          }
          return null;
        },
      ),
    );
    if (value == null || value == currentValue) {
      return;
    }
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(updateManifestUrl: value));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final updateManifestUrl = ref.watch(
      appSettingProvider.select((state) => state.updateManifestUrl),
    );
    final developerMode = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    final localeText = getLocaleString(utils.getLocaleForString(locale));
    final themeText = switch (themeMode) {
      ThemeMode.system => appLocalizations.auto,
      ThemeMode.light => appLocalizations.light,
      ThemeMode.dark => appLocalizations.dark,
    };
    final actionsCount = developerMode ? 3 : 2;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        elevation: 0,
        centerTitle: false,
        title: Text(appLocalizations.application),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _ApplicationSettingsHeader(
            localeText: localeText,
            themeText: themeText,
            actionsCount: actionsCount,
          ),
          const SizedBox(height: 16),
          _ApplicationSettingsActionCard(
            icon: Icons.language_rounded,
            title: appLocalizations.language,
            subtitle: '切换应用显示语言',
            value: localeText,
            onTap: () => _showLocalePicker(context, ref),
          ),
          const SizedBox(height: 14),
          _ApplicationSettingsActionCard(
            icon: Icons.palette_outlined,
            title: appLocalizations.theme,
            subtitle: appLocalizations.themeDesc,
            value: themeText,
            onTap: () => _pushThemePage(context),
          ),
          if (developerMode) ...[
            const SizedBox(height: 14),
            _ApplicationSettingsActionCard(
              icon: Icons.cloud_sync_outlined,
              title: appLocalizations.updateManifestUrl,
              subtitle: appLocalizations.updateManifestUrlDesc,
              value: updateManifestUrl.isEmpty
                  ? appLocalizations.none
                  : updateManifestUrl,
              onTap: () => _showUpdateManifestUrlDialog(context, ref),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApplicationSettingsHeader extends StatelessWidget {
  final String localeText;
  final String themeText;
  final int actionsCount;

  const _ApplicationSettingsHeader({
    required this.localeText,
    required this.themeText,
    required this.actionsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '应用设置',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '统一管理语言和主题显示偏好',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ApplicationSettingsMetric(
                  label: '当前语言',
                  value: localeText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ApplicationSettingsMetric(
                  label: '主题模式',
                  value: themeText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ApplicationSettingsMetric(
                  label: '可用入口',
                  value: actionsCount.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicationSettingsMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ApplicationSettingsMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationSettingsActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;

  const _ApplicationSettingsActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: context.colorScheme.surface),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        value,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
