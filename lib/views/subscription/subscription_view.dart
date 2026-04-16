import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/views/subscription/order_list_view.dart';
import 'package:fl_clash/views/subscription/plan_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _marketBackground = Color(0xFFF5F6F8);

enum _PlanFilter { all, recurring, onetime }

class SubscriptionView extends ConsumerStatefulWidget {
  const SubscriptionView({super.key});

  @override
  ConsumerState<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends ConsumerState<SubscriptionView> {
  _PlanFilter _filter = _PlanFilter.all;

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

  bool _hasRecurringPrice(V2BoardPlan plan) {
    return [
      plan.monthPrice,
      plan.quarterPrice,
      plan.halfYearPrice,
      plan.yearPrice,
      plan.twoYearPrice,
      plan.threeYearPrice,
    ].any((value) => (value ?? 0) > 0);
  }

  List<V2BoardPlan> _filterPlans(List<V2BoardPlan> plans) {
    return plans.where((plan) {
      return switch (_filter) {
        _PlanFilter.all => true,
        _PlanFilter.recurring => _hasRecurringPrice(plan),
        _PlanFilter.onetime => (plan.onetimePrice ?? 0) > 0,
      };
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final props = ref.watch(v2boardSettingProvider);
    final isLoggedIn = props?.isLoggedIn ?? false;
    final plansState = ref.watch(subscriptionPlansProvider);
    final currentPlan = ref.watch(currentPlanProvider);
    final isMobile = ref.watch(isMobileViewProvider);

    return Scaffold(
      backgroundColor: _marketBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 16 : 24,
              isMobile ? 12 : 22,
              isMobile ? 16 : 24,
              isMobile ? 24 : 32,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '套餐商城',
                          style: context.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '选择适合你的订阅方案',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile)
                    IconButton.filledTonal(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OrderListView(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_outlined),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _PlanFilterBar(
                value: _filter,
                onChanged: (value) {
                  setState(() {
                    _filter = value;
                  });
                },
              ),
              const SizedBox(height: 18),
              if (!isLoggedIn)
                _MarketLoginNotice(
                  onLogin: () => appController.toPage(PageLabel.profile),
                )
              else ...[
                if (currentPlan != null) ...[
                  _ActivePlanBadge(planName: currentPlan.name),
                  const SizedBox(height: 18),
                ],
                plansState.when(
                  data: (plans) {
                    final filteredPlans = _filterPlans(plans);
                    if (filteredPlans.isEmpty) {
                      return const _EmptyMarketState();
                    }
                    if (isMobile) {
                      return Column(
                        children: filteredPlans
                            .map(
                              (plan) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _PlanCard(
                                  plan: plan,
                                  filter: _filter,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    }
                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: filteredPlans
                          .map(
                            (plan) => SizedBox(
                              width: 320,
                              child: _PlanCard(plan: plan, filter: _filter),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                  error: (error, _) => _MarketErrorState(error: error),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final V2BoardPlan plan;
  final _PlanFilter filter;

  const _PlanCard({required this.plan, required this.filter});

  static const Map<String, String> _periodLabels = {
    'month': '月付',
    'quarter': '季付',
    'halfYear': '半年',
    'year': '年付',
    'twoYear': '两年',
    'threeYear': '三年',
    'onetime': '一次性',
  };

  List<({String key, int value})> _periods() {
    final items = <({String key, int value})>[];
    void add(String key, int? value) {
      if ((value ?? 0) > 0) {
        items.add((key: key, value: value!));
      }
    }

    add('month', plan.monthPrice);
    add('quarter', plan.quarterPrice);
    add('halfYear', plan.halfYearPrice);
    add('year', plan.yearPrice);
    add('twoYear', plan.twoYearPrice);
    add('threeYear', plan.threeYearPrice);
    add('onetime', plan.onetimePrice);
    return items;
  }

  ({String label, int value}) _headlinePrice() {
    final periods = _periods();
    if (filter == _PlanFilter.onetime) {
      final onetime = periods.where((item) => item.key == 'onetime').firstOrNull;
      if (onetime != null) {
        return (label: _periodLabels[onetime.key]!, value: onetime.value);
      }
    }
    final recurring = periods.where((item) => item.key != 'onetime').firstOrNull;
    if (recurring != null) {
      return (label: _periodLabels[recurring.key]!, value: recurring.value);
    }
    final fallback = periods.firstOrNull;
    if (fallback != null) {
      return (label: _periodLabels[fallback.key]!, value: fallback.value);
    }
    return (label: '一次性', value: 0);
  }

  String _trafficText() {
    final transfer = plan.transferEnable ?? 0;
    if (transfer <= 0) {
      return '不限流量';
    }
    final gb = transfer / 1024 / 1024 / 1024;
    final value = gb.truncateToDouble() == gb ? gb.toStringAsFixed(0) : gb.toStringAsFixed(1);
    return '$value GB 流量';
  }

  List<String> _featureRows() {
    final lines = (plan.content ?? '')
        .split(RegExp(r'[\n|]'))
        .map((item) => item.replaceAll(RegExp(r'<[^>]+>'), '').trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (lines.isNotEmpty) {
      return lines.take(4).toList(growable: false);
    }
    return const ['高速稳定连接', '全球节点覆盖', '多设备同时在线', '24/7 技术支持'];
  }

  void _openDetail(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PlanDetailView(plan: plan)));
  }

  @override
  Widget build(BuildContext context) {
    final headline = _headlinePrice();
    final periods = _periods();
    final features = _featureRows();
    return InkWell(
      borderRadius: BorderRadius.circular(34),
      onTap: () => _openDetail(context),
      child: Ink(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: Colors.black, width: 2.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.diamond_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              plan.name,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '订阅方案',
              style: context.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFB0B6C0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _trafficText(),
              style: context.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF737B88),
              ),
            ),
            if (periods.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                '选择规格',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFB0B6C0),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: periods.take(3).map((item) {
                  final highlighted = item.key == 'month' ||
                      (filter == _PlanFilter.onetime && item.key == 'onetime');
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: highlighted ? Colors.black : const Color(0xFFF3F5F8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _periodLabels[item.key] ?? item.key,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: highlighted ? Colors.white : const Color(0xFF5F6775),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ],
            const SizedBox(height: 18),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '¥${(headline.value / 100).toStringAsFixed(2)}',
                    style: context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -1.2,
                    ),
                  ),
                  TextSpan(
                    text: headline.label == '一次性'
                        ? '/次'
                        : '/${headline.label.replaceAll('付', '')}',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            for (final feature in features) ...[
              Text(
                feature,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF47505E),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _openDetail(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('立即订阅'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanFilterBar extends StatelessWidget {
  final _PlanFilter value;
  final ValueChanged<_PlanFilter> onChanged;

  const _PlanFilterBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget item(_PlanFilter filter, String label) {
      final selected = value == filter;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(filter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1F2024) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: selected ? Colors.white : const Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EAF0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          item(_PlanFilter.all, '全部'),
          item(_PlanFilter.recurring, '周期性'),
          item(_PlanFilter.onetime, '一次性'),
        ],
      ),
    );
  }
}

class _MarketLoginNotice extends StatelessWidget {
  final VoidCallback onLogin;

  const _MarketLoginNotice({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '登录后即可查看套餐与购买记录',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '套餐购买、续费和订单追踪统一在这里完成。',
            style: context.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: onLogin, child: const Text('前往登录')),
        ],
      ),
    );
  }
}

class _ActivePlanBadge extends StatelessWidget {
  final String planName;

  const _ActivePlanBadge({required this.planName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Color(0xFF10B981)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '当前生效套餐: $planName',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMarketState extends StatelessWidget {
  const _EmptyMarketState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text('当前分类下暂无可购买套餐。', style: context.textTheme.titleMedium),
    );
  }
}

class _MarketErrorState extends StatelessWidget {
  final Object error;

  const _MarketErrorState({required this.error});

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

extension _FirstOrNullPlanExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
