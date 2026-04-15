import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/views/subscription/order_list_view.dart';
import 'package:fl_clash/views/subscription/plan_detail_view.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionView extends ConsumerStatefulWidget {
  const SubscriptionView({super.key});

  @override
  ConsumerState<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends ConsumerState<SubscriptionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    ref.read(v2boardPlansProvider.notifier).fetch();
    ref.read(v2boardUserProvider.notifier).fetch();
    ref.read(v2boardSubscriptionProvider.notifier).fetch();
    await ref.read(subscriptionOrdersProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final props = ref.watch(v2boardSettingProvider);
    final isLoggedIn = props?.isLoggedIn ?? false;
    final plansState = ref.watch(subscriptionPlansProvider);
    final currentPlan = ref.watch(currentPlanProvider);
    return CommonScaffold(
      title: '套餐',
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const OrderListView()));
          },
          icon: const Icon(Icons.receipt_long),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!isLoggedIn)
              CommonCard(
                type: CommonCardType.filled,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '登录后即可查看套餐与购买记录',
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '套餐购买、续费和订单追踪统一在这里完成。',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            appController.toPage(PageLabel.profile),
                        child: const Text('前往登录'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SubscriptionCard(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderListView()),
                ),
              ),
              const SizedBox(height: 20),
              Text('可购买套餐', style: context.textTheme.titleLarge),
              const SizedBox(height: 12),
              if (currentPlan != null)
                Text(
                  '当前生效: ${currentPlan.name}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 12),
              ...plansState.when(
                data: (plans) {
                  if (plans.isEmpty) {
                    return [const Text('暂无可购买套餐')];
                  }
                  return plans
                      .map((plan) => _PlanCard(plan: plan))
                      .toList(growable: false);
                },
                error: (error, _) => [Text(error.toString())],
                loading: () => [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final V2BoardPlan plan;

  const _PlanCard({required this.plan});

  List<String> _priceRows() {
    final entries = <String, int?>{
      '月付': plan.monthPrice,
      '季付': plan.quarterPrice,
      '半年': plan.halfYearPrice,
      '年付': plan.yearPrice,
      '两年': plan.twoYearPrice,
      '三年': plan.threeYearPrice,
      '一次性': plan.onetimePrice,
    };
    return entries.entries
        .where((entry) => (entry.value ?? 0) > 0)
        .map(
          (entry) =>
              '${entry.key} ¥${((entry.value ?? 0) / 100).toStringAsFixed(2)}',
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final prices = _priceRows();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CommonCard(
        type: CommonCardType.filled,
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => PlanDetailView(plan: plan)));
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(plan.name, style: context.textTheme.titleLarge),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              if ((plan.content ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  plan.content!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (prices.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: prices
                      .map((price) => Chip(label: Text(price)))
                      .toList(growable: false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
