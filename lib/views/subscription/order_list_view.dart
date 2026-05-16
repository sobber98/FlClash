import 'package:v2box/common/common.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/services/v2board/v2board.dart';
import 'package:v2box/state.dart';
import 'package:v2box/views/subscription/payment_flow.dart';
import 'package:v2box/views/v2board/v2board_design.dart';
import 'package:v2box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      1 => '开通中',
      2 => '已取消',
      3 => '已完成',
      _ => '未知',
    };
  }

  Color _statusColor(int status) {
    return switch (status) {
      0 => const Color(0xFFB45309),
      1 => v2BoardPrimary,
      2 => v2BoardMuted,
      3 => v2BoardSuccess,
      _ => v2BoardMuted,
    };
  }

  Color _statusBackground(int status) {
    return switch (status) {
      0 => const Color(0xFFFFF7ED),
      1 => v2BoardSoft,
      2 => const Color(0xFFF3F6FA),
      3 => const Color(0xFFEAFBF3),
      _ => const Color(0xFFF3F6FA),
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
        message: TextSpan(
          text: formatPaymentFlowError(error, fallback: '取消订单失败，请稍后重试。'),
        ),
      );
    }
  }

  Future<V2BoardPaymentOption?> _selectPaymentMethod(
    List<V2BoardPaymentOption> options,
  ) async {
    if (options.isEmpty) {
      return null;
    }
    if (options.length == 1) {
      return options.first;
    }
    return await globalState.showCommonDialog<V2BoardPaymentOption>(
      child: _PaymentMethodDialog(options: options),
    );
  }

  Future<void> _continuePayment(V2BoardOrder order, String? planName) async {
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) {
      return;
    }
    try {
      final methods = await api.getPaymentMethods();
      final options = v2boardPaymentOptions(methods);
      final selected = await _selectPaymentMethod(options);
      if (options.isNotEmpty && selected == null) {
        return;
      }
      if (!mounted) {
        return;
      }
      final paid = await startV2BoardPaymentFlow(
        context: context,
        ref: ref,
        tradeNo: order.tradeNo,
        planName: planName?.isNotEmpty == true ? planName! : '订阅服务订单',
        periodLabel: _typeText(order.type),
        amountText: _formatPrice(order.totalAmount),
        paymentMethodValue: selected?.value ?? '',
        paymentMethodLabel: selected?.label ?? '系统默认',
      );
      await ref.read(subscriptionOrdersProvider.notifier).refresh();
      if (paid && mounted) {
        globalState.showNotifier('支付成功，订单已完成');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(
          text: formatPaymentFlowError(error, fallback: '恢复订单支付失败，请稍后重试。'),
        ),
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
    final isMobile = ref.watch(isMobileViewProvider);

    return Scaffold(
      backgroundColor: v2BoardPageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ordersState.when(
            data: (orders) => _OrdersContent(
              orders: orders,
              plans: plans,
              isMobile: isMobile,
              statusText: _statusText,
              statusColor: _statusColor,
              statusBackground: _statusBackground,
              formatPrice: _formatPrice,
              formatTime: _formatTime,
              typeText: _typeText,
              onCopy: (order) async {
                await Clipboard.setData(ClipboardData(text: order.tradeNo));
                if (mounted) {
                  globalState.showNotifier('订单号已复制');
                }
              },
              onContinuePay: _continuePayment,
              onCancel: _cancelOrder,
            ),
            error: (error, _) => _OrdersContent(
              orders: const [],
              plans: plans,
              isMobile: isMobile,
              error: error,
              statusText: _statusText,
              statusColor: _statusColor,
              statusBackground: _statusBackground,
              formatPrice: _formatPrice,
              formatTime: _formatTime,
              typeText: _typeText,
              onCopy: (_) async {},
              onContinuePay: _continuePayment,
              onCancel: _cancelOrder,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

class _OrdersContent extends StatelessWidget {
  final List<V2BoardOrder> orders;
  final List<V2BoardPlan> plans;
  final bool isMobile;
  final Object? error;
  final String Function(int status) statusText;
  final Color Function(int status) statusColor;
  final Color Function(int status) statusBackground;
  final String Function(int amount) formatPrice;
  final String Function(int? timestamp) formatTime;
  final String Function(int type) typeText;
  final Future<void> Function(V2BoardOrder order) onCopy;
  final Future<void> Function(V2BoardOrder order, String? planName)
  onContinuePay;
  final Future<void> Function(V2BoardOrder order) onCancel;

  const _OrdersContent({
    required this.orders,
    required this.plans,
    required this.isMobile,
    required this.statusText,
    required this.statusColor,
    required this.statusBackground,
    required this.formatPrice,
    required this.formatTime,
    required this.typeText,
    required this.onCopy,
    required this.onContinuePay,
    required this.onCancel,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = orders.where((order) => order.status == 0).length;
    final completedCount = orders.where((order) => order.status == 3).length;
    final totalCompleted = orders
        .where((order) => order.status == 3)
        .fold<int>(0, (sum, order) => sum + order.totalAmount);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 12 : 22,
        isMobile ? 16 : 24,
        isMobile ? 24 : 32,
      ),
      children: [
        _OrdersPageHeader(compact: isMobile),
        const SizedBox(height: 18),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OrdersHeader(
                  pendingCount: pendingCount,
                  completedCount: completedCount,
                  totalCompleted: formatPrice(totalCompleted),
                  compact: isMobile,
                ),
                const SizedBox(height: 14),
                if (error != null)
                  _OrdersErrorState(error: error!)
                else if (orders.isEmpty)
                  const _OrdersEmptyState()
                else
                  for (var index = 0; index < orders.length; index++) ...[
                    _buildOrderCard(orders[index], index),
                    if (index != orders.length - 1) const SizedBox(height: 14),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(V2BoardOrder order, int index) {
    final planName = plans
        .where((plan) => plan.id == order.planId)
        .map((plan) => plan.name)
        .firstOrNull;
    return _OrderCard(
      key: ValueKey('order-card-$index'),
      order: order,
      planName: planName,
      statusText: statusText(order.status),
      statusColor: statusColor(order.status),
      statusBackground: statusBackground(order.status),
      priceText: formatPrice(order.totalAmount),
      timeText: formatTime(order.createdAt),
      typeText: typeText(order.type),
      compact: isMobile,
      onCopy: () => onCopy(order),
      onContinuePay: order.status == 0
          ? () => onContinuePay(order, planName)
          : null,
      onCancel: order.status == 0 ? () => onCancel(order) : null,
    );
  }
}

class _OrdersPageHeader extends StatelessWidget {
  final bool compact;

  const _OrdersPageHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: v2BoardInk,
              tooltip: '返回',
            ),
            const SizedBox(width: 4),
            Expanded(
              child: V2BoardPageHeader(
                title: '订单记录',
                subtitle: compact ? null : '查看购买、续费和支付状态',
                compact: compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  final int pendingCount;
  final int completedCount;
  final String totalCompleted;
  final bool compact;

  const _OrdersHeader({
    required this.pendingCount,
    required this.completedCount,
    required this.totalCompleted,
    required this.compact,
  }) : super(key: const ValueKey('orders-stats-card'));

  @override
  Widget build(BuildContext context) {
    return V2BoardCard(
      padding: EdgeInsets.all(compact ? 18 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '订单中心',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: v2BoardInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '查看购买、续费和支付状态',
            style: context.textTheme.bodyMedium?.copyWith(
              color: v2BoardMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          compact ? _compactMetrics(context) : _desktopMetrics(),
        ],
      ),
    );
  }

  Widget _desktopMetrics() {
    return Row(
      children: [
        Expanded(
          child: _OrdersMetric(label: '待支付', value: '$pendingCount'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OrdersMetric(label: '已完成', value: '$completedCount'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OrdersMetric(label: '累计支付', value: totalCompleted),
        ),
      ],
    );
  }

  Widget _compactMetrics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OrdersMetric.plain(label: '待支付', value: '$pendingCount'),
        ),
        const SizedBox(
          height: 42,
          child: VerticalDivider(width: 1, color: v2BoardLine),
        ),
        Expanded(
          child: _OrdersMetric.plain(label: '已完成', value: '$completedCount'),
        ),
        const SizedBox(
          height: 42,
          child: VerticalDivider(width: 1, color: v2BoardLine),
        ),
        Expanded(
          child: _OrdersMetric.plain(label: '累计支付', value: totalCompleted),
        ),
      ],
    );
  }
}

class _OrdersMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool framed;

  const _OrdersMetric({required this.label, required this.value})
    : framed = true;

  const _OrdersMetric.plain({required this.label, required this.value})
    : framed = false;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: framed
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: v2BoardMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: v2BoardInk,
          ),
        ),
      ],
    );
    if (!framed) {
      return content;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: v2BoardLine),
      ),
      child: content,
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
  final bool compact;
  final VoidCallback onCopy;
  final VoidCallback? onContinuePay;
  final VoidCallback? onCancel;

  const _OrderCard({
    super.key,
    required this.order,
    required this.planName,
    required this.statusText,
    required this.statusColor,
    required this.statusBackground,
    required this.priceText,
    required this.timeText,
    required this.typeText,
    required this.compact,
    required this.onCopy,
    required this.onContinuePay,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return V2BoardCard(
      padding: EdgeInsets.all(compact ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 42 : 48,
                height: compact ? 42 : 48,
                decoration: BoxDecoration(
                  gradient: v2BoardGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: compact ? 22 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName?.isNotEmpty == true ? planName! : '订阅服务订单',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: v2BoardInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      typeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: v2BoardMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusChip(
                text: statusText,
                foreground: statusColor,
                background: statusBackground,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _OrderInfoRow(label: '订单号', value: order.tradeNo),
          const SizedBox(height: 10),
          _OrderInfoRow(label: '创建时间', value: timeText),
          const SizedBox(height: 10),
          _OrderInfoRow(label: '订单金额', value: priceText, emphasize: true),
          const SizedBox(height: 16),
          _OrderActions(
            compact: compact,
            onCopy: onCopy,
            onContinuePay: onContinuePay,
            onCancel: onCancel,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color foreground;
  final Color background;

  const _StatusChip({
    required this.text,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OrderActions extends StatelessWidget {
  final bool compact;
  final VoidCallback onCopy;
  final VoidCallback? onContinuePay;
  final VoidCallback? onCancel;

  const _OrderActions({
    required this.compact,
    required this.onCopy,
    required this.onContinuePay,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      Expanded(child: _CopyButton(onPressed: onCopy)),
      if (onContinuePay != null) ...[
        const SizedBox(width: 10),
        Expanded(
          child: V2BoardPrimaryButton(label: '继续支付', onPressed: onContinuePay),
        ),
      ],
    ];

    return Column(
      children: [
        Row(children: buttons),
        if (onCancel != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: v2BoardMuted,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: v2BoardLine),
              ),
              child: const Text('取消订单'),
            ),
          ),
        ],
      ],
    );
  }
}

class _CopyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CopyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: v2BoardPrimary,
        minimumSize: const Size.fromHeight(46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: Color(0xFFC9D0FF)),
      ),
      child: const Text('复制订单号'),
    );
  }
}

class _PaymentMethodDialog extends StatefulWidget {
  final List<V2BoardPaymentOption> options;

  const _PaymentMethodDialog({required this.options});

  @override
  State<_PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<_PaymentMethodDialog> {
  V2BoardPaymentOption? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.options.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: '选择支付方式',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop(_selected),
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.options
              .map((option) {
                final selected = _selected?.value == option.value;
                return ListTile(
                  onTap: () {
                    setState(() {
                      _selected = option;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(option.label),
                  subtitle: option.value == option.label
                      ? null
                      : Text(option.value),
                );
              })
              .toList(growable: false),
        ),
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
            color: v2BoardMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (emphasize
                        ? context.textTheme.titleMedium
                        : context.textTheme.bodyMedium)
                    ?.copyWith(fontWeight: FontWeight.w800, color: v2BoardInk),
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
    return V2BoardCard(
      padding: const EdgeInsets.all(24),
      child: Text(
        '当前没有任何订单记录，下拉可以重新获取最新结果。',
        style: context.textTheme.titleMedium?.copyWith(
          color: v2BoardMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OrdersErrorState extends StatelessWidget {
  final Object error;

  const _OrdersErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return V2BoardCard(
      padding: const EdgeInsets.all(24),
      child: Text(
        error.toString(),
        style: context.textTheme.titleMedium?.copyWith(
          color: v2BoardInk,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

extension _FirstOrNullIterable<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
