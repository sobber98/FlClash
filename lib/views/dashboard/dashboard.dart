import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/views/proxies/tab.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    ref.read(v2boardUserProvider.notifier).fetch();
    ref.read(v2boardSubscriptionProvider.notifier).fetch();
    ref.read(v2boardPlansProvider.notifier).fetch();
    ref.read(v2boardNoticesProvider.notifier).fetch();
  }

  String _noticeText(List<V2BoardNotice> notices) {
    if (notices.isEmpty) return '';
    final notice = notices.first;
    final plain = notice.content.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
    return notice.title.trim().isNotEmpty ? notice.title.trim() : plain;
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var index = 0;
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    return '${value.toStringAsFixed(1)} ${units[index]}';
  }

  String _remainingDays(int? expiredAt) {
    if (expiredAt == null || expiredAt == 0) {
      return appLocalizations.infiniteTime;
    }
    final expire = DateTime.fromMillisecondsSinceEpoch(expiredAt * 1000);
    final days = expire.difference(DateTime.now()).inDays;
    return days <= 0 ? '今日到期' : '有效期还剩 $days 天';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ref.watch(isMobileViewProvider);
    final noticesState = ref.watch(v2boardNoticesProvider);
    final userState = ref.watch(v2boardUserProvider);
    final subState = ref.watch(v2boardSubscriptionProvider);
    final currentGroupName = ref.watch(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    final selectedProxyName = currentGroupName == null
        ? null
        : ref.watch(getSelectedProxyNameProvider(currentGroupName));
    final notices = noticesState is AsyncData<List<V2BoardNotice>>
        ? noticesState.value
        : const <V2BoardNotice>[];
    final user = userState is AsyncData<V2BoardUser?> ? userState.value : null;
    final subscription = subState is AsyncData<V2BoardSubscription?>
        ? subState.value
        : null;
    final remainingTraffic =
        (user?.transferEnable ?? subscription?.transferEnable ?? 0) -
        ((user?.upload ?? subscription?.upload ?? 0) +
            (user?.download ?? subscription?.download ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 16 : 24,
              isMobile ? 16 : 24,
              isMobile ? 16 : 24,
              isMobile ? 24 : 32,
            ),
            children: [
              if (_noticeText(notices).isNotEmpty) ...[
                _AnnouncementBar(text: _noticeText(notices)),
                const SizedBox(height: 26),
              ],
              _HeroStatusSection(nodeName: selectedProxyName),
              const SizedBox(height: 24),
              if (!isMobile) ...[
                Row(
                  children: const [
                    Expanded(child: _TunModeCard()),
                    SizedBox(width: 18),
                    Expanded(child: _OutboundModeCard()),
                  ],
                ),
                const SizedBox(height: 18),
              ] else ...[
                const _OutboundModeCard(),
                const SizedBox(height: 18),
              ],
              const _NodeCard(),
              const SizedBox(height: 18),
              _InlineSummary(
                expireText: _remainingDays(
                  subscription?.expiredAt ?? user?.expiredAt,
                ),
                trafficText:
                    '剩余流量: ${_formatBytes(remainingTraffic < 0 ? 0 : remainingTraffic)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementBar extends StatelessWidget {
  final String text;

  const _AnnouncementBar({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.campaign_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatusSection extends ConsumerWidget {
  final String? nodeName;

  const _HeroStatusSection({this.nodeName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(coreStatusProvider);
    final title = switch (status) {
      CoreStatus.connected => '已连接',
      CoreStatus.connecting => '连接中',
      CoreStatus.disconnected => '未连接',
    };
    final subtitle = switch (status) {
      CoreStatus.connected => '安全连接已建立，当前可直接开始使用',
      CoreStatus.connecting => '核心正在建立连接，请稍候',
      CoreStatus.disconnected => '点击按钮开启安全连接',
    };
    return Column(
      children: [
        const ConnectButton(size: 160, showDetails: false),
        const SizedBox(height: 18),
        Text(
          title,
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFFA0A6B1),
          ),
        ),
        if (nodeName?.isNotEmpty == true) ...[
          const SizedBox(height: 10),
          Text(
            '当前节点: $nodeName',
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _TunModeCard extends ConsumerWidget {
  const _TunModeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAndroid = system.isAndroid;
    final enabled = isAndroid
        ? ref.watch(vpnSettingProvider.select((state) => state.enable))
        : ref.watch(
            patchClashConfigProvider.select((state) => state.tun.enable),
          );
    return _DashboardCard(
      child: Row(
        children: [
          const _FeatureIcon(icon: Icons.desktop_windows_outlined),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TUN 模式',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '接管全系统流量',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFA0A6B1),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (value) {
              if (isAndroid) {
                ref.read(vpnSettingProvider.notifier).update(
                      (state) => state.copyWith(enable: value),
                    );
              } else {
                ref.read(patchClashConfigProvider.notifier).update(
                      (state) => state.copyWith.tun(enable: value),
                    );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OutboundModeCard extends ConsumerWidget {
  const _OutboundModeCard();

  String _label(Mode mode) {
    return switch (mode) {
      Mode.rule => '规则',
      Mode.global => '全局',
      Mode.direct => '直连',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _FeatureIcon(icon: Icons.alt_route_rounded),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '出站规则',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '分流策略',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFA0A6B1),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                for (final item in Mode.values)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => appController.changeMode(item),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: mode == item ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: mode == item
                              ? const [
                                  BoxShadow(
                                    color: Color(0x12000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          _label(item),
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: mode == item
                                ? Colors.black
                                : const Color(0xFF8D94A1),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeCard extends ConsumerWidget {
  const _NodeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGroupName = ref.watch(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    final selectedProxyName = currentGroupName == null
        ? null
        : ref.watch(getSelectedProxyNameProvider(currentGroupName));
    return _DashboardCard(
      onTap: () {
        showSheet(
          context: context,
          props: SheetProps(isScrollControlled: true),
          builder: (_, type) {
            return AdaptiveSheetScaffold(
              type: type,
              title: appLocalizations.proxies,
              body: const ProxiesTabView(),
            );
          },
        );
      },
      child: Row(
        children: [
          const _FeatureIcon(icon: Icons.public_rounded),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前加速节点',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFA0A6B1),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedProxyName?.isNotEmpty == true ? selectedProxyName! : '自动选择',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '切换',
            style: context.textTheme.titleSmall?.copyWith(
              color: const Color(0xFFB1B7C2),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB1B7C2)),
        ],
      ),
    );
  }
}

class _InlineSummary extends StatelessWidget {
  final String expireText;
  final String trafficText;

  const _InlineSummary({
    required this.expireText,
    required this.trafficText,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 18,
      runSpacing: 8,
      children: [
        _SummaryText(icon: Icons.access_time_rounded, text: expireText),
        _SummaryText(icon: Icons.bolt_rounded, text: trafficText),
      ],
    );
  }
}

class _SummaryText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFA0A6B1)),
        const SizedBox(width: 6),
        Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFFA0A6B1),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _DashboardCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      type: CommonCardType.filled,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;

  const _FeatureIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: Colors.black, size: 26),
    );
  }
}
