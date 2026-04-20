import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/subscription/ticket_list_view.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class V2BoardAccountView extends ConsumerStatefulWidget {
  const V2BoardAccountView({super.key});

  @override
  ConsumerState<V2BoardAccountView> createState() => _V2BoardAccountViewState();
}

class _V2BoardAccountViewState extends ConsumerState<V2BoardAccountView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    ref.read(v2boardUserProvider.notifier).fetch();
    ref.read(v2boardSubscriptionProvider.notifier).fetch();
    ref.read(v2boardPlansProvider.notifier).fetch();
    ref.read(v2boardNoticesProvider.notifier).fetch();
    ref.read(v2boardTicketsProvider.notifier).refresh();
  }

  void _logout() {
    ref.read(v2boardSettingProvider.notifier).value = null;
    ref.read(v2boardApiClientProvider.notifier).clear();
    ref.read(v2boardUserProvider.notifier).clear();
    ref.read(v2boardSubscriptionProvider.notifier).clear();
    ref.read(v2boardTicketsProvider.notifier).clear();
  }

  Future<void> _syncSubscription() async {
    final errorMessage = await appController.syncV2BoardSubscription();
    if (!mounted) return;
    if (errorMessage == null) {
      globalState.showNotifier(appLocalizations.v2boardSyncSuccess);
      return;
    }
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: errorMessage),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${units[i]}';
  }

  String _formatExpireDate(int? timestamp) {
    if (timestamp == null || timestamp == 0) {
      return appLocalizations.v2boardNoExpire;
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getPlanName(
    V2BoardUser? user,
    V2BoardSubscription? sub,
    List<V2BoardPlan> plans,
  ) {
    final plan = v2boardResolvedPlan(
      user: user,
      subscription: sub,
      plans: plans,
    );
    final name = plan?.name.trim() ?? '';
    return name.isNotEmpty ? name : appLocalizations.v2boardNoPlan;
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(v2boardUserProvider);
    final subState = ref.watch(v2boardSubscriptionProvider);
    final plansState = ref.watch(v2boardPlansProvider);
    final noticesState = ref.watch(v2boardNoticesProvider);
    final props = ref.watch(v2boardSettingProvider);

    final user = userState is AsyncData<V2BoardUser?> ? userState.value : null;
    final sub = subState is AsyncData<V2BoardSubscription?>
        ? subState.value
        : null;
    final plans = plansState is AsyncData<List<V2BoardPlan>>
        ? plansState.value
        : <V2BoardPlan>[];
    final notices = noticesState is AsyncData<List<V2BoardNotice>>
        ? noticesState.value
        : <V2BoardNotice>[];

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          // User Info Card
          _buildUserCard(context, user, sub, plans, props),
          // Traffic Usage
          if (user != null || sub != null)
            _buildTrafficCard(context, user, sub),
          // Subscription
          if (sub != null) _buildSubscriptionSection(context, sub),
          // Actions
          ..._buildActionSection(context),
          // Notices
          if (notices.isNotEmpty) ..._buildNoticesSection(context, notices),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    V2BoardUser? user,
    V2BoardSubscription? sub,
    List<V2BoardPlan> plans,
    V2BoardProps? props,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 24, child: Icon(Icons.person, size: 28)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        props?.email ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPlanName(user, sub, plans),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  tooltip: appLocalizations.v2boardLogout,
                ),
              ],
            ),
            if (user != null || sub != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoItem(
                    context,
                    appLocalizations.v2boardExpire,
                    _formatExpireDate(v2boardResolvedExpiredAt(user, sub)),
                  ),
                  _infoItem(
                    context,
                    appLocalizations.v2boardBalance,
                    '¥${((user?.balance ?? 0) / 100).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _buildTrafficCard(
    BuildContext context,
    V2BoardUser? user,
    V2BoardSubscription? sub,
  ) {
    final upload = v2boardResolvedUpload(user, sub);
    final download = v2boardResolvedDownload(user, sub);
    final used = upload + download;
    final total = v2boardResolvedTotalTraffic(user, sub);
    final progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appLocalizations.trafficUsage,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${_formatBytes(used)} / ${_formatBytes(total)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${appLocalizations.upload}: ${_formatBytes(upload)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${appLocalizations.download}: ${_formatBytes(download)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(
    BuildContext context,
    V2BoardSubscription sub,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.sync),
        title: Text(appLocalizations.v2boardSubscription),
        subtitle: sub.resetDay != null
            ? Text('${appLocalizations.v2boardSubscription}: ${sub.resetDay}')
            : null,
        trailing: FilledButton.tonal(
          onPressed: _syncSubscription,
          child: Text(appLocalizations.v2boardSync),
        ),
      ),
    );
  }

  List<Widget> _buildActionSection(BuildContext context) {
    return generateSection(
      title: appLocalizations.v2boardActions,
      items: [
        ListItem(
          leading: const Icon(Icons.refresh),
          title: Text(appLocalizations.v2boardRefreshData),
          onTap: _refreshData,
        ),
        ListItem(
          leading: const Icon(Icons.sync_alt),
          title: Text(appLocalizations.v2boardSyncSubscription),
          subtitle: Text(appLocalizations.v2boardSyncSubscriptionDesc),
          onTap: _syncSubscription,
        ),
        ListItem(
          leading: const Icon(Icons.support_agent_rounded),
          title: const Text('我的工单'),
          subtitle: const Text('查看客服回复并继续跟进当前问题'),
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TicketListView()));
          },
        ),
      ],
    );
  }

  List<Widget> _buildNoticesSection(
    BuildContext context,
    List<V2BoardNotice> notices,
  ) {
    return generateSection(
      title: appLocalizations.v2boardNotices,
      items: notices
          .take(5)
          .map(
            (notice) => ListItem(
              title: Text(v2boardNoticeHeadline(notice)),
              subtitle: Text(() {
                final content = v2boardPlainText(
                  notice.content,
                  preserveLineBreaks: false,
                );
                return content.length > 50
                    ? '${content.substring(0, 50)}...'
                    : content;
              }()),
              onTap: () {
                globalState.showMessage(
                  title: v2boardNoticeHeadline(notice),
                  message: TextSpan(text: v2boardPlainText(notice.content)),
                );
              },
            ),
          ),
    );
  }
}
