import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/application_setting.dart';
import 'package:fl_clash/views/backup_and_restore.dart';
import 'package:fl_clash/views/config/config.dart';
import 'package:fl_clash/views/connection/connections.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:fl_clash/views/logs.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:fl_clash/views/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show dirname, join;

import 'config/advanced.dart';
import 'developer.dart';
import 'theme.dart';

const _toolsBackground = Color(0xFFF5F6F8);

typedef _ToolActionCallback = Future<void> Function(
  BuildContext context,
  WidgetRef ref,
);

class _ToolActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final _ToolActionCallback onTap;

  const _ToolActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _ToolSectionData {
  final String title;
  final String subtitle;
  final List<_ToolActionData> actions;

  const _ToolSectionData({
    required this.title,
    required this.subtitle,
    required this.actions,
  });
}

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends ConsumerState<ToolsView> {
  String _localeLabel(String? locale) {
    if (locale == null || locale.isEmpty) {
      return appLocalizations.defaultText;
    }
    return Intl.message(locale);
  }

  Future<void> _pushPage(Widget page) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _showLocalePicker() async {
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
                                  (state) =>
                                      state.copyWith(locale: locale?.toString()),
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
                                    style: context.textTheme.titleMedium?.copyWith(
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

  List<_ToolSectionData> _buildSections(bool enableDeveloperMode, String? locale) {
    return [
      _ToolSectionData(
        title: '基础设置',
        subtitle: '语言、主题与应用配置入口',
        actions: [
          _ToolActionData(
            icon: Icons.language_rounded,
            title: context.appLocalizations.language,
            subtitle: _localeLabel(locale),
            onTap: (_, _) => _showLocalePicker(),
          ),
          _ToolActionData(
            icon: Icons.palette_outlined,
            title: context.appLocalizations.theme,
            subtitle: context.appLocalizations.themeDesc,
            onTap: (_, _) => _pushPage(const ThemeView()),
          ),
          _ToolActionData(
            icon: Icons.tune_rounded,
            title: context.appLocalizations.basicConfig,
            subtitle: context.appLocalizations.basicConfigDesc,
            onTap: (_, _) => _pushPage(const ConfigView()),
          ),
          _ToolActionData(
            icon: Icons.auto_fix_high_outlined,
            title: context.appLocalizations.advancedConfig,
            subtitle: context.appLocalizations.advancedConfigDesc,
            onTap: (_, _) => _pushPage(const AdvancedConfigView()),
          ),
          _ToolActionData(
            icon: Icons.settings_outlined,
            title: context.appLocalizations.application,
            subtitle: context.appLocalizations.applicationDesc,
            onTap: (_, _) => _pushPage(const ApplicationSettingView()),
          ),
        ],
      ),
      _ToolSectionData(
        title: '网络工具',
        subtitle: '连接调试、请求追踪与日志诊断',
        actions: [
          _ToolActionData(
            icon: Icons.swap_horiz_rounded,
            title: context.appLocalizations.connections,
            subtitle: context.appLocalizations.connectionsDesc,
            onTap: (_, _) => _pushPage(const ConnectionsView()),
          ),
          _ToolActionData(
            icon: Icons.timeline_rounded,
            title: context.appLocalizations.requests,
            subtitle: context.appLocalizations.requestsDesc,
            onTap: (_, _) => _pushPage(const RequestsView()),
          ),
          _ToolActionData(
            icon: Icons.receipt_long_outlined,
            title: context.appLocalizations.logs,
            subtitle: context.appLocalizations.logsDesc,
            onTap: (_, _) => _pushPage(const LogsView()),
          ),
        ],
      ),
      _ToolSectionData(
        title: '数据管理',
        subtitle: '配置文件、资源和备份恢复',
        actions: [
          _ToolActionData(
            icon: Icons.folder_copy_outlined,
            title: context.appLocalizations.profile,
            subtitle: context.appLocalizations.addProfile,
            onTap: (_, _) => _pushPage(const ProfilesView()),
          ),
          _ToolActionData(
            icon: Icons.storage_outlined,
            title: context.appLocalizations.resources,
            subtitle: context.appLocalizations.resourcesDesc,
            onTap: (_, _) => _pushPage(const ResourcesView()),
          ),
          _ToolActionData(
            icon: Icons.cloud_sync_outlined,
            title: context.appLocalizations.backupAndRestore,
            subtitle: context.appLocalizations.backupAndRestoreDesc,
            onTap: (_, _) => _pushPage(const BackupAndRestore()),
          ),
        ],
      ),
      _ToolSectionData(
        title: '平台能力',
        subtitle: '按当前设备开放的高级功能',
        actions: [
          if (system.isDesktop)
            _ToolActionData(
              icon: Icons.keyboard_command_key_rounded,
              title: context.appLocalizations.hotkeyManagement,
              subtitle: context.appLocalizations.hotkeyManagementDesc,
              onTap: (_, _) => _pushPage(const HotKeyView()),
            ),
          if (system.isWindows)
            _ToolActionData(
              icon: Icons.lock_outline_rounded,
              title: context.appLocalizations.loopback,
              subtitle: context.appLocalizations.loopbackDesc,
              onTap: (_, _) async {
                windows?.runas(
                  '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
                  '',
                );
              },
            ),
          if (system.isAndroid)
            _ToolActionData(
              icon: Icons.security_outlined,
              title: context.appLocalizations.accessControl,
              subtitle: context.appLocalizations.accessControlDesc,
              onTap: (_, _) => _pushPage(const AccessView()),
            ),
        ],
      ),
      _ToolSectionData(
        title: context.appLocalizations.other,
        subtitle: '版本信息与扩展入口',
        actions: [
          if (enableDeveloperMode)
            _ToolActionData(
              icon: Icons.developer_board_outlined,
              title: context.appLocalizations.developerMode,
              subtitle: '查看开发调试能力',
              onTap: (_, _) => _pushPage(const DeveloperView()),
            ),
          _ToolActionData(
            icon: Icons.info_outline_rounded,
            title: context.appLocalizations.about,
            subtitle: '应用信息与版本说明',
            onTap: (_, _) => _pushPage(const AboutView()),
          ),
        ],
      ),
    ].where((section) => section.actions.isNotEmpty).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ref.watch(isMobileViewProvider);
    final vm2 = ref.watch(
      appSettingProvider.select(
        (state) => VM2(state.locale, state.developerMode),
      ),
    );
    final sections = _buildSections(vm2.b, vm2.a);
    return Scaffold(
      backgroundColor: _toolsBackground,
      body: SafeArea(
        child: ListView(
          key: toolsStoreKey,
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 24,
            12,
            isMobile ? 16 : 24,
            32,
          ),
          children: [
            _ToolsHeroCard(
              localeText: _localeLabel(vm2.a),
              enableDeveloperMode: vm2.b,
              onThemeTap: () => _pushPage(const ThemeView()),
              onConfigTap: () => _pushPage(const ConfigView()),
              onBackupTap: () => _pushPage(const BackupAndRestore()),
            ),
            const SizedBox(height: 18),
            for (final section in sections) ...[
              _ToolSectionCard(section: section),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolsHeroCard extends StatelessWidget {
  final String localeText;
  final bool enableDeveloperMode;
  final VoidCallback onThemeTap;
  final VoidCallback onConfigTap;
  final VoidCallback onBackupTap;

  const _ToolsHeroCard({
    required this.localeText,
    required this.enableDeveloperMode,
    required this.onThemeTap,
    required this.onConfigTap,
    required this.onBackupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
            '工具中心',
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '管理应用设置、网络诊断和数据能力',
            style: context.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ToolsMetric(label: '当前语言', value: localeText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToolsMetric(
                  label: '开发模式',
                  value: enableDeveloperMode ? '已开启' : '未开启',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ToolsQuickAction(
                  icon: Icons.palette_outlined,
                  label: '主题',
                  onTap: onThemeTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ToolsQuickAction(
                  icon: Icons.tune_rounded,
                  label: '配置',
                  onTap: onConfigTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ToolsQuickAction(
                  icon: Icons.cloud_sync_outlined,
                  label: '备份',
                  onTap: onBackupTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolsMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ToolsMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolsQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolsQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2024),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 8),
              Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolSectionCard extends ConsumerWidget {
  final _ToolSectionData section;

  const _ToolSectionCard({required this.section});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
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
            section.title,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 18),
          for (var index = 0; index < section.actions.length; index++) ...[
            _ToolTile(action: section.actions[index]),
            if (index != section.actions.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ToolTile extends ConsumerWidget {
  final _ToolActionData action;

  const _ToolTile({required this.action});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => action.onTap(context, ref),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(action.icon, color: const Color(0xFF1F2937)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8C95A3),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
