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
    final sectionGap = isMobile ? 16.0 : 18.0;
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
              if (v2boardNoticePreview(notices).isNotEmpty) ...[
                _AnnouncementBar(notices: notices),
                const SizedBox(height: 26),
              ],
              _HeroStatusSection(
                nodeName: selectedProxyName,
                compact: isMobile,
              ),
              SizedBox(height: isMobile ? 20 : 24),
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
                const _OutboundModeCard(compact: true),
                SizedBox(height: sectionGap),
              ],
              _NodeCard(compact: isMobile),
              SizedBox(height: sectionGap),
              _InlineSummary(
                compact: isMobile,
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
  final List<V2BoardNotice> notices;

  const _AnnouncementBar({required this.notices});

  String _formatTime(int? timestamp) {
    if (timestamp == null || timestamp <= 0) {
      return '';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }

  Future<void> _showNoticeDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '公告详情',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击公告栏即可查看完整公告内容',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.separated(
                      itemCount: notices.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final notice = notices[index];
                        final title = v2boardNoticeHeadline(notice);
                        final content = v2boardPlainText(notice.content);
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FB),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.isNotEmpty ? title : '公告 ${index + 1}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (_formatTime(notice.updatedAt ?? notice.createdAt).isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _formatTime(notice.updatedAt ?? notice.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                              if (content.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                SelectableText(
                                  content,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.55,
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = v2boardNoticePreview(notices);
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: notices.isEmpty ? null : () => _showNoticeDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '最新公告',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _MarqueeText(
                        text: preview,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _HeroStatusSection extends ConsumerWidget {
  final String? nodeName;
  final bool compact;

  const _HeroStatusSection({this.nodeName, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionVisualStateProvider);
    final buttonSize = compact ? 128.0 : 160.0;
    final title = switch (connectionState) {
      ConnectionVisualState.connected => '已连接',
      ConnectionVisualState.connecting => '连接中',
      ConnectionVisualState.disconnecting => '断开中',
      ConnectionVisualState.disconnected => '未连接',
    };
    final subtitle = switch (connectionState) {
      ConnectionVisualState.connected => '安全连接已建立，当前可直接开始使用',
      ConnectionVisualState.connecting => '正在建立安全连接，请稍候',
      ConnectionVisualState.disconnecting => '正在断开当前连接，请稍候',
      ConnectionVisualState.disconnected => '点击按钮开启安全连接',
    };
    return Column(
      children: [
        ConnectButton(size: buttonSize, showDetails: false),
        SizedBox(height: compact ? 14 : 18),
        Text(
          title,
          style: (compact
                  ? context.textTheme.headlineMedium
                  : context.textTheme.displaySmall)
              ?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 0),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: (compact
                    ? context.textTheme.bodySmall
                    : context.textTheme.bodyMedium)
                ?.copyWith(
              color: const Color(0xFFA0A6B1),
            ),
          ),
        ),
        if (nodeName?.isNotEmpty == true) ...[
          SizedBox(height: compact ? 8 : 10),
          Text(
            '当前节点: $nodeName',
            textAlign: TextAlign.center,
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: (compact
                    ? context.textTheme.bodySmall
                    : context.textTheme.bodyMedium)
                ?.copyWith(
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
        : ref.watch(patchClashConfigProvider.select((state) => state.tun.enable));
    final title = isAndroid ? 'VPN 模式' : 'TUN 模式';
    final subtitle = isAndroid ? '系统级代理开关' : '透明代理开关';

    return _DashboardCard(
      compact: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _FeatureIcon(icon: Icons.shield_outlined, compact: false),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
                    ref
                        .read(vpnSettingProvider.notifier)
                        .update((state) => state.copyWith(enable: value));
                    return;
                  }
                  ref
                      .read(patchClashConfigProvider.notifier)
                      .update((state) => state.copyWith.tun(enable: value));
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            enabled ? '当前已启用' : '当前未启用',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: enabled ? const Color(0xFF047857) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            enabled ? '所有流量将按当前代理策略接管。' : '启用后可通过系统网络层统一接管流量。',
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const _MarqueeText({required this.text, this.style});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  static const _gap = 36.0;
  late final AnimationController _controller;
  double _textWidth = 0;
  double _viewportWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final shouldAnimate = _textWidth > _viewportWidth + 8;
    if (!shouldAnimate) {
      _controller
        ..stop()
        ..value = 0;
      return;
    }
    final seconds = ((_textWidth + _gap) / 42).clamp(8.0, 24.0);
    final duration = Duration(milliseconds: (seconds * 1000).round());
    if (_controller.duration != duration) {
      _controller.duration = duration;
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    if (widget.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout();
        _textWidth = painter.width;
        _viewportWidth = constraints.maxWidth;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _syncAnimation();
          }
        });
        final shouldAnimate = _textWidth > _viewportWidth + 8;
        if (!shouldAnimate) {
          return Text(
            widget.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
        }
        return ClipRect(
          child: SizedBox(
            height: painter.height,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final distance = _textWidth + _gap;
                final dx = -distance * _controller.value;
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: Row(
                    children: [
                      Text(widget.text, maxLines: 1, softWrap: false, style: style),
                      const SizedBox(width: _gap),
                      Text(widget.text, maxLines: 1, softWrap: false, style: style),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _OutboundModeCard extends ConsumerWidget {
  final bool compact;

  const _OutboundModeCard({this.compact = false});

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
      compact: compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _FeatureIcon(icon: Icons.alt_route_rounded, compact: compact),
              SizedBox(width: compact ? 12 : 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '出站规则',
                    style: (compact
                            ? context.textTheme.titleMedium
                            : context.textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '分流策略',
                    style: (compact
                            ? context.textTheme.bodySmall
                            : context.textTheme.bodyMedium)
                        ?.copyWith(
                      color: const Color(0xFFA0A6B1),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 18),
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
                        padding: EdgeInsets.symmetric(
                          vertical: compact ? 10 : 12,
                        ),
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
                          style: (compact
                                  ? context.textTheme.labelLarge
                                  : context.textTheme.titleSmall)
                              ?.copyWith(
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
  final bool compact;

  const _NodeCard({this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGroupName = ref.watch(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    final selectedProxyName = currentGroupName == null
        ? null
        : ref.watch(getSelectedProxyNameProvider(currentGroupName));
    return _DashboardCard(
      compact: compact,
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
          _FeatureIcon(icon: Icons.public_rounded, compact: compact),
          SizedBox(width: compact ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前加速节点',
                  style: (compact
                          ? context.textTheme.bodySmall
                          : context.textTheme.bodyMedium)
                      ?.copyWith(
                    color: const Color(0xFFA0A6B1),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedProxyName?.isNotEmpty == true ? selectedProxyName! : '自动选择',
                  maxLines: compact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: (compact
                          ? context.textTheme.titleLarge
                          : context.textTheme.headlineSmall)
                      ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (!compact)
            Text(
              '切换',
              style: context.textTheme.titleSmall?.copyWith(
                color: const Color(0xFFB1B7C2),
                fontWeight: FontWeight.w700,
              ),
            ),
          SizedBox(width: compact ? 4 : 8),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB1B7C2)),
        ],
      ),
    );
  }
}

class _InlineSummary extends StatelessWidget {
  final String expireText;
  final String trafficText;
  final bool compact;

  const _InlineSummary({
    required this.expireText,
    required this.trafficText,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: compact ? 12 : 18,
      runSpacing: 8,
      children: [
        _SummaryText(
          icon: Icons.access_time_rounded,
          text: expireText,
          compact: compact,
        ),
        _SummaryText(
          icon: Icons.bolt_rounded,
          text: trafficText,
          compact: compact,
        ),
      ],
    );
  }
}

class _SummaryText extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool compact;

  const _SummaryText({
    required this.icon,
    required this.text,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 14 : 16, color: const Color(0xFFA0A6B1)),
        const SizedBox(width: 6),
        Text(
          text,
          style: (compact
                  ? context.textTheme.bodySmall
                  : context.textTheme.bodyMedium)
              ?.copyWith(
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
  final bool compact;

  const _DashboardCard({
    required this.child,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      type: CommonCardType.filled,
      onPressed: onTap,
      child: Padding(
        padding: EdgeInsets.all(compact ? 18 : 24),
        child: child,
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final bool compact;

  const _FeatureIcon({required this.icon, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 46 : 54,
      height: compact ? 46 : 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
      ),
      child: Icon(icon, color: Colors.black, size: compact ? 22 : 26),
    );
  }
}
