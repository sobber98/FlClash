import 'package:v2box/common/common.dart';
import 'package:v2box/controller.dart';
import 'package:v2box/enum/enum.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/services/v2board/v2board.dart';
import 'package:v2box/views/subscription/order_list_view.dart';
import 'package:v2box/views/subscription/plan_detail_view.dart';
import 'package:v2box/views/v2board/v2board_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _marketBackground = v2BoardPageBackground;
const _cardTextColor = v2BoardInk;
const _cardSubtitleColor = v2BoardMuted;

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
    return plans
        .where((plan) {
          return switch (_filter) {
            _PlanFilter.all => true,
            _PlanFilter.recurring => _hasRecurringPrice(plan),
            _PlanFilter.onetime => (plan.onetimePrice ?? 0) > 0,
          };
        })
        .toList(growable: false);
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
              V2BoardPageHeader(
                title: '套餐 / 订阅',
                subtitle: '选择适合你的订阅方案',
                compact: isMobile,
                trailing: !isMobile
                    ? IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OrderListView(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long_outlined),
                      )
                    : null,
              ),
              const SizedBox(height: 18),
              if (currentPlan != null && isLoggedIn) ...[
                _CurrentPlanSummary(planName: currentPlan.name),
                const SizedBox(height: 18),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '选择套餐',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: v2BoardInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrderListView(),
                        ),
                      );
                    },
                    child: const Text('套餐对比'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                                child: _PlanCard(plan: plan, filter: _filter),
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
                              width: 300,
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
      final onetime = periods
          .where((item) => item.key == 'onetime')
          .firstOrNull;
      if (onetime != null) {
        return (label: _periodLabels[onetime.key]!, value: onetime.value);
      }
    }
    final recurring = periods
        .where((item) => item.key != 'onetime')
        .firstOrNull;
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
    final value = gb.truncateToDouble() == gb
        ? gb.toStringAsFixed(0)
        : gb.toStringAsFixed(1);
    return '$value GB 流量';
  }

  List<String> _featureRows() {
    return v2boardPlanHighlights(plan.content, limit: 4);
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
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openDetail(context),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: v2BoardLine),
          boxShadow: v2BoardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: v2BoardGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.diamond_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: _cardTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _trafficText(),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: v2BoardMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (periods.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: periods
                    .take(3)
                    .map((item) {
                      final highlighted =
                          item.key == 'month' ||
                          (filter == _PlanFilter.onetime &&
                              item.key == 'onetime');
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: highlighted ? v2BoardPrimary : v2BoardSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _periodLabels[item.key] ?? item.key,
                          locale: const Locale('zh', 'CN'),
                          style: context.textTheme.labelMedium?.copyWith(
                            color: highlighted ? Colors.white : v2BoardInk,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '¥${(headline.value / 100).toStringAsFixed(2)}',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: v2BoardPrimary,
                        ),
                      ),
                      TextSpan(
                        text: headline.label == '一次性'
                            ? '/次'
                            : '/${headline.label.replaceAll('付', '')}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => _openDetail(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: v2BoardPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('订阅'),
                ),
              ],
            ),
            if (features.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final feature in features) ...[
                Text(
                  feature,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: v2BoardMuted,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ],
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
              color: selected ? v2BoardPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              label,
              locale: const Locale('zh', 'CN'),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: selected ? Colors.white : v2BoardInk,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: v2BoardLine),
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

class _CurrentPlanSummary extends StatelessWidget {
  final String planName;

  const _CurrentPlanSummary({required this.planName});

  @override
  Widget build(BuildContext context) {
    return V2BoardCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const V2BoardIconBox(icon: Icons.workspace_premium_rounded, size: 54),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前套餐',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: v2BoardMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  planName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: v2BoardInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: v2BoardSuccess),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: v2BoardLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '登录后即可查看套餐与购买记录',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: _cardTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '套餐购买、续费和订单追踪统一在这里完成。',
            style: context.textTheme.bodyLarge?.copyWith(color: v2BoardMuted),
          ),
          const SizedBox(height: 18),
          V2BoardPrimaryButton(label: '前往登录', onPressed: onLogin),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: v2BoardLine),
      ),
      child: Text(
        '当前分类下暂无可购买套餐。',
        style: context.textTheme.titleMedium?.copyWith(
          color: _cardSubtitleColor,
        ),
      ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: v2BoardLine),
      ),
      child: Text(
        error.toString(),
        style: context.textTheme.titleMedium?.copyWith(color: _cardTextColor),
      ),
    );
  }
}

extension _FirstOrNullPlanExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
