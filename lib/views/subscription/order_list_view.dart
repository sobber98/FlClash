import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _ordersBackground = Color(0xFFF5F6F8);

class OrderListView extends ConsumerStatefulWidget {
  const OrderListView({super.key});

  @override
  ConsumerState<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends ConsumerState<OrderListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    await ref.read(subscriptionOrdersProvider.notifier).refresh();
    ref.read(v2boardPlansProvider.notifier).fetch();
  }

  String _statusText(int status) {
    return switch (status) {
      0 => '待支付',
      1 => '已支付',
      2 => '已取消',
      _ => '未知',
    };
  }

  Color _statusColor(int status) {
    return switch (status) {
      0 => const Color(0xFFB45309),
      1 => const Color(0xFF047857),
      2 => const Color(0xFF6B7280),
      _ => const Color(0xFF4B5563),
    };
  }

  Color _statusBackground(int status) {
    return switch (status) {
      0 => const Color(0xFFFFF7ED),
      1 => const Color(0xFFECFDF5),
      2 => const Color(0xFFF3F4F6),
      _ => const Color(0xFFF3F4F6),
    };
  }

  String _formatPrice(int amount) => '¥${(amount / 100).toStringAsFixed(2)}';

  String _formatTime(int? timestamp) {
    if (timestamp == null || timestamp <= 0) {
      return '未知时间';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }

  String _typeText(int type) {
    return switch (type) {
      1 => '新购订单',
      2 => '续费订单',
      3 => '重置流量',
      _ => '订阅订单',
    };
  }

  Future<void> _cancelOrder(V2BoardOrder order) async {
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) {
      return;
    }
    try {
      await api.cancelOrder(order.tradeNo);
      await ref.read(subscriptionOrdersProvider.notifier).refresh();
      if (!mounted) {
        return;
      }
      globalState.showNotifier('订单已取消');
    } catch (error) {
      if (!mounted) {
        return;
      }
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: error.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(subscriptionOrdersProvider);
    final plansState = ref.watch(subscriptionPlansProvider);
    final plans = plansState is AsyncData<List<V2BoardPlan>>
        ? plansState.value
        : const <V2BoardPlan>[];
    return Scaffold(
      backgroundColor: _ordersBackground,
      appBar: AppBar(
        backgroundColor: _ordersBackground,
        elevation: 0,
        centerTitle: false,
        title: const Text('订单记录'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ordersState.when(
          data: (orders) {
            final pendingCount = orders.where((order) => order.status == 0).length;
            final paidCount = orders.where((order) => order.status == 1).length;
            final totalPaid = orders
                .where((order) => order.status == 1)
                .fold<int>(0, (sum, order) => sum + order.totalAmount);
            if (orders.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _OrdersHeader(pendingCount: 0, paidCount: 0, totalPaid: '¥0.00'),
                  SizedBox(height: 16),
                  _OrdersEmptyState(),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: orders.length + 1,
              itemBuilder: (_, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _OrdersHeader(
                      pendingCount: pendingCount,
                      paidCount: paidCount,
                      totalPaid: _formatPrice(totalPaid),
                    ),
                  );
                }
                final order = orders[index - 1];
                final planName = plans
                    .where((plan) => plan.id == order.planId)
                    .map((plan) => plan.name)
                    .firstOrNull;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _OrderCard(
                    order: order,
                    planName: planName,
                    statusText: _statusText(order.status),
                    statusColor: _statusColor(order.status),
                    statusBackground: _statusBackground(order.status),
                    priceText: _formatPrice(order.totalAmount),
                    timeText: _formatTime(order.createdAt),
                    typeText: _typeText(order.type),
                    onCopy: () async {
                      await Clipboard.setData(
                        ClipboardData(text: order.tradeNo),
                      );
                      if (mounted) {
                        globalState.showNotifier('订单号已复制');
                      }
                    },
                    onCancel: order.status == 0 ? () => _cancelOrder(order) : null,
                  ),
                );
              },
            );
          },
          error: (error, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _OrdersHeader(pendingCount: 0, paidCount: 0, totalPaid: '¥0.00'),
              const SizedBox(height: 16),
              _OrdersErrorState(error: error),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  final int pendingCount;
  final int paidCount;
  final String totalPaid;

  const _OrdersHeader({
    required this.pendingCount,
    required this.paidCount,
    required this.totalPaid,
  });

  @override
  Widget build(BuildContext context) {
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
            '订单中心',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '查看购买、续费和支付状态',
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _OrdersMetric(
                  label: '待支付',
                  value: '$pendingCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OrdersMetric(
                  label: '已支付',
                  value: '$paidCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OrdersMetric(
                  label: '累计支付',
                  value: totalPaid,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrdersMetric extends StatelessWidget {
  final String label;
  final String value;

  const _OrdersMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final V2BoardOrder order;
  final String? planName;
  final String statusText;
  final Color statusColor;
  final Color statusBackground;
  final String priceText;
  final String timeText;
  final String typeText;
  final VoidCallback onCopy;
  final VoidCallback? onCancel;

  const _OrderCard({
    required this.order,
    required this.planName,
    required this.statusText,
    required this.statusColor,
    required this.statusBackground,
    required this.priceText,
    required this.timeText,
    required this.typeText,
    required this.onCopy,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName?.isNotEmpty == true ? planName! : '订阅服务订单',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      typeText,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _OrderInfoRow(label: '订单号', value: order.tradeNo),
          const SizedBox(height: 10),
          _OrderInfoRow(label: '创建时间', value: timeText),
          const SizedBox(height: 10),
          _OrderInfoRow(label: '订单金额', value: priceText, emphasize: true),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCopy,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: const Text('复制订单号'),
                ),
              ),
              if (onCancel != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onCancel,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('取消订单'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _OrderInfoRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: (emphasize
                    ? context.textTheme.titleMedium
                    : context.textTheme.bodyLarge)
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _OrdersEmptyState extends StatelessWidget {
  const _OrdersEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text(
        '当前没有任何订单记录，下拉可以重新获取最新结果。',
        style: context.textTheme.titleMedium,
      ),
    );
  }
}

class _OrdersErrorState extends StatelessWidget {
  final Object error;

  const _OrdersErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text(error.toString(), style: context.textTheme.titleMedium),
    );
  }
}

extension _FirstOrNullIterable<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
