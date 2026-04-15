import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/dashboard/widgets/intranet_ip.dart';
import 'package:fl_clash/views/dashboard/widgets/network_detection.dart'
    as dashboard_widgets;
import 'package:fl_clash/views/dashboard/widgets/network_speed.dart';
import 'package:fl_clash/views/dashboard/widgets/traffic_usage.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentWidth = ref.watch(contentWidthProvider);
    final currentGroupName = ref.watch(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    final selectedProxyName = currentGroupName == null
        ? null
        : ref.watch(getSelectedProxyNameProvider(currentGroupName));
    final isAndroid = system.isAndroid;
    final isTunEnabled = isAndroid
        ? ref.watch(vpnSettingProvider.select((state) => state.enable))
        : ref.watch(
            patchClashConfigProvider.select((state) => state.tun.enable),
          );
    final gridColumns = contentWidth > 920 ? 2 : 1;

    return CommonScaffold(
      title: appLocalizations.dashboard,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConnectionHeroCard(currentNodeName: selectedProxyName),
            const SizedBox(height: 16),
            Grid.baseGap(
              crossAxisCount: gridColumns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _ToggleCard(
                  title: isAndroid ? 'VPN / TUN' : appLocalizations.tun,
                  subtitle: isTunEnabled
                      ? appLocalizations.connected
                      : appLocalizations.disconnected,
                  icon: Icons.stacked_line_chart,
                  value: isTunEnabled,
                  onChanged: (value) {
                    if (isAndroid) {
                      ref
                          .read(vpnSettingProvider.notifier)
                          .update((state) => state.copyWith(enable: value));
                    } else {
                      ref
                          .read(patchClashConfigProvider.notifier)
                          .update((state) => state.copyWith.tun(enable: value));
                    }
                  },
                ),
                const ModeSelector(),
                const NodeSelector(),
                SubscriptionCard(
                  onPressed: () =>
                      ref.read(currentPageLabelProvider.notifier).value =
                          PageLabel.subscription,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Grid.baseGap(
              crossAxisCount: gridColumns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: const [
                NetworkSpeed(),
                TrafficUsage(),
                dashboard_widgets.NetworkDetection(),
                IntranetIP(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionHeroCard extends ConsumerWidget {
  final String? currentNodeName;

  const _ConnectionHeroCard({required this.currentNodeName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(coreStatusProvider);
    final runTime = ref.watch(runTimeProvider);
    final currentMode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    return CommonCard(
      type: CommonCardType.filled,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 640;
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('连接控制', style: context.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  switch (status) {
                    CoreStatus.connected => '代理核心已连接，可以直接切换节点与模式',
                    CoreStatus.connecting => '正在连接核心与同步配置',
                    CoreStatus.disconnected => '当前未连接，点击按钮开始连接',
                  },
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetaChip(
                      icon: Icons.timer_outlined,
                      label: '连接时长 ${utils.getTimeText(runTime)}',
                    ),
                    _MetaChip(
                      icon: Icons.share_arrival_time_outlined,
                      label: '出站模式 ${currentMode.name.toUpperCase()}',
                    ),
                    _MetaChip(
                      icon: Icons.hub_outlined,
                      label: currentNodeName?.isNotEmpty == true
                          ? '当前节点 $currentNodeName'
                          : '尚未选择节点',
                    ),
                  ],
                ),
              ],
            );
            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: ConnectButton(size: 104),
                  ),
                  const SizedBox(height: 20),
                  details,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ConnectButton(),
                const SizedBox(width: 24),
                Expanded(child: details),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      type: CommonCardType.filled,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: context.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTheme.titleMedium?.toSoftBold),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}
