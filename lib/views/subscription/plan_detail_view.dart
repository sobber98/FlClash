import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

const _detailBackground = Color(0xFFF5F6F8);

class PlanDetailView extends ConsumerStatefulWidget {
  final V2BoardPlan plan;

  const PlanDetailView({super.key, required this.plan});

  @override
  ConsumerState<PlanDetailView> createState() => _PlanDetailViewState();
}

class _PlanDetailViewState extends ConsumerState<PlanDetailView> {
  static const Map<String, String> _periodLabels = {
    'month_price': '月付',
    'quarter_price': '季付',
    'half_year_price': '半年',
    'year_price': '年付',
    'two_year_price': '两年',
    'three_year_price': '三年',
    'onetime_price': '一次性',
    'reset_price': '重置',
  };

  final _couponController = TextEditingController();
  List<V2BoardPaymentOption> _paymentMethods = const [];
  String? _selectedPeriod;
  String? _selectedPaymentMethodValue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = _availablePeriods.keys.firstOrNull;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentMethods();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Map<String, int> get _availablePeriods {
    final raw = <String, int?>{
      'month_price': widget.plan.monthPrice,
      'quarter_price': widget.plan.quarterPrice,
      'half_year_price': widget.plan.halfYearPrice,
      'year_price': widget.plan.yearPrice,
      'two_year_price': widget.plan.twoYearPrice,
      'three_year_price': widget.plan.threeYearPrice,
      'onetime_price': widget.plan.onetimePrice,
      'reset_price': widget.plan.resetPrice,
    };
    return raw.map((key, value) => MapEntry(key, value ?? 0))
      ..removeWhere((_, value) => value <= 0);
  }

  int get _selectedPrice {
    final period = _selectedPeriod;
    if (period == null) {
      return 0;
    }
    return _availablePeriods[period] ?? 0;
  }

  List<String> get _featureRows {
    return v2boardPlanHighlights(widget.plan.content, limit: 5);
  }

  String _trafficText() {
    final transfer = widget.plan.transferEnable ?? 0;
    if (transfer <= 0) {
      return '不限流量';
    }
    final gb = transfer / 1024 / 1024 / 1024;
    final value = gb.truncateToDouble() == gb
        ? gb.toStringAsFixed(0)
        : gb.toStringAsFixed(1);
    return '$value GB 流量';
  }

  String _priceText(int price) => '¥${(price / 100).toStringAsFixed(2)}';

  String _selectedPaymentLabel() {
    final option = _paymentMethods
        .where((item) => item.value == _selectedPaymentMethodValue)
        .firstOrNull;
    if (option == null || option.label.trim().isEmpty) {
      return '系统默认';
    }
    return option.label;
  }

  Future<void> _loadPaymentMethods() async {
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) {
      return;
    }
    try {
      final methods = await api.getPaymentMethods();
      if (!mounted) {
        return;
      }
      final options = v2boardPaymentOptions(methods);
      setState(() {
        _paymentMethods = options;
        _selectedPaymentMethodValue = options.firstOrNull?.value;
      });
    } catch (_) {
      // Keep empty methods and let server default the payment path.
    }
  }

  Future<void> _submitOrder() async {
    final api = ref.read(v2boardApiClientProvider);
    final period = _selectedPeriod;
    if (api == null || period == null) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final order = await api.createOrder(
        planId: widget.plan.id,
        period: period,
        couponCode: _couponController.text.trim(),
      );
      final tradeNo =
          order['trade_no']?.toString() ?? order['data']?.toString();
      if (tradeNo == null || tradeNo.isEmpty) {
        throw 'trade_no is empty';
      }
      final result = await api.checkoutOrder(
        tradeNo,
        _selectedPaymentMethodValue ?? '',
      );
      final url = _extractCheckoutUrl(result);
      await ref.read(subscriptionOrdersProvider.notifier).refresh();
      if (url != null && url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else if (mounted) {
        globalState.showNotifier('Order created: $tradeNo');
      }
    } catch (error) {
      if (mounted) {
        globalState.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: error.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _extractCheckoutUrl(Map<String, dynamic> result) {
    final candidates = [
      result['url'],
      result['pay_url'],
      result['payment_url'],
      result['data'] is Map ? (result['data'] as Map)['url'] : null,
      result['data'] is Map ? (result['data'] as Map)['payment_url'] : null,
    ];
    for (final value in candidates) {
      final text = value?.toString() ?? '';
      if (text.startsWith('http')) {
        return text;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ref.watch(isMobileViewProvider);
    return Scaffold(
      backgroundColor: _detailBackground,
      appBar: AppBar(
        backgroundColor: _detailBackground,
        elevation: 0,
        centerTitle: false,
        title: const Text('套餐详情'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 24,
          8,
          isMobile ? 16 : 24,
          32,
        ),
        children: [
          _DetailHeroCard(
            planName: widget.plan.name,
            trafficText: _trafficText(),
            priceText: _priceText(_selectedPrice),
            periodText: _periodLabels[_selectedPeriod] ?? '请选择周期',
            features: _featureRows,
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: '订阅规格',
            subtitle: '选择你想购买的计费周期',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availablePeriods.entries.map((entry) {
                final selected = _selectedPeriod == entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = entry.key;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? Colors.black : const Color(0xFFF3F5F8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _periodLabels[entry.key] ?? entry.key,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _priceText(entry.value),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: selected
                                ? Colors.white70
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: '优惠与支付',
            subtitle: '可选填写优惠码并选择支付方式',
            child: Column(
              children: [
                TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: '输入优惠码可自动参与结算',
                    filled: true,
                    fillColor: const Color(0xFFF7F8FB),
                    prefixIcon: const Icon(Icons.local_offer_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                  ),
                ),
                if (_paymentMethods.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '支付方式',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _paymentMethods.map((method) {
                      final selected = _selectedPaymentMethodValue == method.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethodValue = method.value;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF1F2024)
                                : const Color(0xFFF3F5F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            method.label,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: selected ? Colors.white : const Color(0xFF4B5563),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: '订单摘要',
            subtitle: '确认后将创建订单并跳转到支付流程',
            child: Column(
              children: [
                _SummaryRow(label: '套餐名称', value: widget.plan.name),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: '计费周期',
                  value: _periodLabels[_selectedPeriod] ?? '-',
                ),
                const SizedBox(height: 12),
                _SummaryRow(label: '支付方式', value: _selectedPaymentLabel()),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: '优惠码',
                  value: _couponController.text.trim().isEmpty
                      ? '未填写'
                      : _couponController.text.trim(),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '应付金额',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _priceText(_selectedPrice),
                              style: context.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.shopping_bag_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submitOrder,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('立即购买并支付'),
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

class _DetailHeroCard extends StatelessWidget {
  final String planName;
  final String trafficText;
  final String priceText;
  final String periodText;
  final List<String> features;

  const _DetailHeroCard({
    required this.planName,
    required this.trafficText,
    required this.priceText,
    required this.periodText,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black, width: 2.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            planName,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trafficText,
            style: context.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF7B8492),
            ),
          ),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: priceText,
                  style: context.textTheme.displaySmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                ),
                TextSpan(
                  text: ' / $periodText',
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
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: Color(0xFF111827),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
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
            title,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

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
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

extension _FirstOrNullList<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
