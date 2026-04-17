import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/app_config.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/application_setting.dart';
import 'package:fl_clash/views/subscription/order_list_view.dart';
import 'package:fl_clash/views/v2board/login_view.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

const _profileBackground = Color(0xFFF5F6F8);

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  void _showLoginSheet(BuildContext context) {
    showSheet(
      context: context,
      props: SheetProps(isScrollControlled: true),
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          title: '登录',
          body: const V2BoardLoginView(),
        );
      },
    );
  }

  void _showRegisterPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const V2BoardRegisterPage()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final props = ref.watch(v2boardSettingProvider);
    final isLoggedIn = props?.isLoggedIn ?? false;
    final appName = ref.watch(appDisplayNameProvider);
    final enableRegistration = ref.watch(appEnableRegistrationProvider);
    final userState = ref.watch(v2boardUserProvider);
    final subState = ref.watch(v2boardSubscriptionProvider);
    final currentPlan = ref.watch(currentPlanProvider);
    final appConfig = ref.watch(appConfigProvider).maybeWhen(
          data: (config) => config,
          orElse: AppConfig.defaults,
        );
    final user = userState is AsyncData<V2BoardUser?> ? userState.value : null;
    final subscription = subState is AsyncData<V2BoardSubscription?>
        ? subState.value
        : null;

    if (!isLoggedIn) {
      return CommonScaffold(
        title: '我的',
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CommonCard(
              type: CommonCardType.filled,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: context.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person_outline,
                        size: 36,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(appName, style: context.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      '登录后查看订阅状态、同步订阅与公告。',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => _showLoginSheet(context),
                      child: const Text('登录'),
                    ),
                    if (enableRegistration) ...[
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => _showRegisterPage(context),
                        child: const Text('注册'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isMobile = ref.watch(isMobileViewProvider);
    return Scaffold(
      backgroundColor: _profileBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 24,
            14,
            isMobile ? 16 : 24,
            32,
          ),
          children: [
            Text(
              '用户中心',
              style: context.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '管理您的账户与服务',
              style: context.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 18),
            _ProfileHeaderCard(
              user: user,
              subscription: subscription,
              planName: currentPlan?.name ?? '未分配套餐',
            ),
            const SizedBox(height: 16),
            _UsageCard(user: user, subscription: subscription),
            const SizedBox(height: 16),
            _SupportSection(appConfig: appConfig, user: user),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final V2BoardUser? user;
  final V2BoardSubscription? subscription;
  final String planName;

  const _ProfileHeaderCard({
    required this.user,
    required this.subscription,
    required this.planName,
  });

  String _expireText() {
    final timestamp = subscription?.expiredAt ?? user?.expiredAt;
    if (timestamp == null || timestamp == 0) {
      return '长期有效';
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        .toString()
        .split(' ')
        .first;
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? '-';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: email));
                        globalState.showNotifier('已复制邮箱地址');
                      },
                      icon: const Icon(Icons.content_copy_rounded, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  planName,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '到期时间',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2024),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _expireText(),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  final V2BoardUser? user;
  final V2BoardSubscription? subscription;

  const _UsageCard({required this.user, required this.subscription});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var index = 0;
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    return '${value.toStringAsFixed(2)} ${units[index]}';
  }

  String _resetText() {
    final resetDay = subscription?.resetDay;
    if (resetDay == null || resetDay <= 0) {
      return '当前套餐未设置流量重置日';
    }
    final now = DateTime.now();
    DateTime nextReset = DateTime(now.year, now.month, resetDay);
    if (!nextReset.isAfter(now)) {
      nextReset = DateTime(now.year, now.month + 1, resetDay);
    }
    final days = nextReset.difference(now).inDays;
    return '已用流量将在$days日后重置';
  }

  @override
  Widget build(BuildContext context) {
    final used = (user?.upload ?? subscription?.upload ?? 0) +
        (user?.download ?? subscription?.download ?? 0);
    final total = user?.transferEnable ?? subscription?.transferEnable ?? 0;
    final progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            children: [
              const Icon(Icons.donut_large_rounded, color: Color(0xFF6B7280)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '已用流量',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${_formatBytes(used)} / ${_formatBytes(total)}',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F4F8),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _resetText(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => appController.toPage(PageLabel.subscription),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1F2024),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.autorenew_rounded),
              label: const Text('续费套餐'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportSection extends ConsumerWidget {
  final AppConfig appConfig;
  final V2BoardUser? user;

  const _SupportSection({required this.appConfig, required this.user});

  Future<void> _openLink(String url, String fallbackTip) async {
    if (url.isEmpty) {
      globalState.showNotifier(fallbackTip);
      return;
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  String _websiteUrl(String serverUrl) {
    final extras = appConfig.extras;
    final candidates = [
      extras['websiteUrl'],
      extras['website'],
      extras['officialWebsite'],
      extras['appUrl'],
    ];
    for (final item in candidates) {
      final text = item?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    if (serverUrl.isEmpty) {
      return '';
    }
    return serverUrl.replaceFirst(RegExp(r'/api(?:/v\d+)?/?$'), '');
  }

  String _telegramUrl() {
    final value = appConfig.telegramGroup.trim();
    if (value.isEmpty) {
      return '';
    }
    if (value.startsWith('http')) {
      return value;
    }
    return 'https://t.me/${value.replaceFirst('@', '')}';
  }

  String _mailUrl() {
    final value = appConfig.supportEmail.trim();
    if (value.isEmpty) {
      return '';
    }
    return 'mailto:$value';
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
    return '${value.toStringAsFixed(2)} ${units[index]}';
  }

  void _showTrafficDetails(WidgetRef ref) {
    final subState = ref.read(v2boardSubscriptionProvider);
    final subscription = subState is AsyncData<V2BoardSubscription?>
        ? subState.value
        : null;
    final upload = user?.upload ?? subscription?.upload ?? 0;
    final download = user?.download ?? subscription?.download ?? 0;
    final total = user?.transferEnable ?? subscription?.transferEnable ?? 0;
    globalState.showMessage(
      title: '流量明细',
      message: TextSpan(
        text: '上传: ${_formatBytes(upload)}\n下载: ${_formatBytes(download)}\n总量: ${_formatBytes(total)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(appServerUrlProvider);
    final websiteUrl = _websiteUrl(serverUrl);
    final telegramUrl = _telegramUrl();
    final mailUrl = _mailUrl();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            children: [
              const Icon(Icons.headset_mic_outlined, color: Color(0xFF6B7280)),
              const SizedBox(width: 10),
              Text(
                '帮助与支持',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.receipt_long_rounded,
                  title: '订单记录',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OrderListView()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionTile(
                  icon: Icons.donut_large_rounded,
                  title: '流量明细',
                  onTap: () => _showTrafficDetails(ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SupportListTile(
            icon: Icons.support_agent_rounded,
            title: '我的工单',
            onTap: () => _openLink(mailUrl, '暂未配置工单联系邮箱'),
          ),
          _SupportListTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: '在线客服',
            onTap: () => _openLink(
              telegramUrl.isNotEmpty ? telegramUrl : mailUrl,
              '暂未配置在线客服信息',
            ),
          ),
          _SupportListTile(
            icon: Icons.language_rounded,
            title: '官方网站',
            onTap: () => _openLink(websiteUrl, '暂未配置官网地址'),
          ),
          _SupportListTile(
            icon: Icons.send_rounded,
            title: '加入群组',
            onTap: () => _openLink(telegramUrl, '暂未配置群组地址'),
          ),
          _SupportListTile(
            icon: Icons.account_balance_wallet_outlined,
            title: '我的钱包',
            onTap: () {
              globalState.showMessage(
                title: '我的钱包',
                message: TextSpan(
                  text: '账户余额: ¥${((user?.balance ?? 0) / 100).toStringAsFixed(2)}\n佣金余额: ¥${((user?.commissionBalance ?? 0) / 100).toStringAsFixed(2)}',
                ),
              );
            },
          ),
          _SupportListTile(
            icon: Icons.settings_outlined,
            title: '应用设置',
            onTap: () {
              Navigator.of(
                context,
              ).push(
                MaterialPageRoute(
                  builder: (_) => const ApplicationSettingView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4B5563)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _SupportListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SupportListTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: const Color(0xFF4B5563)),
      title: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }
}
