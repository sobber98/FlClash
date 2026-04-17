import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/config.dart';
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
      backgroundColor: Colors.white,
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '切换应用显示语言',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9CA3AF),
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
                                  ? Colors.black
                                  : const Color(0xFFF6F7FB),
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
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final localeText = getLocaleString(utils.getLocaleForString(locale));
    return BaseScaffold(
      title: appLocalizations.application,
      body: SingleChildScrollView(
        padding: baseInfoEdgeInsets,
        child: generateSectionV2(
          title: appLocalizations.options,
          items: [
            ListItem(
              leading: const Icon(Icons.language_rounded),
              title: Text(appLocalizations.language),
              subtitle: Text(localeText),
              trailing: const Icon(Icons.chevron_right_rounded),
              minVerticalPadding: 12,
              onTap: () => _showLocalePicker(context, ref),
            ),
            ListItem(
              leading: const Icon(Icons.palette_outlined),
              title: Text(appLocalizations.theme),
              subtitle: Text(appLocalizations.themeDesc),
              trailing: const Icon(Icons.chevron_right_rounded),
              minVerticalPadding: 12,
              onTap: () => _pushThemePage(context),
            ),
          ],
        ),
      ),
    );
  }
}
