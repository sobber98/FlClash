import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
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
      ref.read(subscriptionOrdersProvider.notifier).refresh();
    });
  }

  String _statusText(int status) {
    return switch (status) {
      0 => 'Pending',
      1 => 'Paid',
      2 => 'Cancelled',
      _ => 'Unknown',
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
      globalState.showNotifier('Order cancelled');
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
    return CommonScaffold(
      title: 'Orders',
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(subscriptionOrdersProvider.notifier).refresh(),
        child: ordersState.when(
          data: (orders) {
            if (orders.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No orders')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, index) {
                final order = orders[index];
                return ListTile(
                  tileColor: context.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(order.tradeNo),
                  subtitle: Text(
                    '${_statusText(order.status)} · ¥${(order.totalAmount / 100).toStringAsFixed(2)}',
                  ),
                  trailing: order.status == 0
                      ? TextButton(
                          onPressed: () => _cancelOrder(order),
                          child: const Text('Cancel'),
                        )
                      : null,
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemCount: orders.length,
            );
          },
          error: (error, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(child: Text(error.toString())),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
