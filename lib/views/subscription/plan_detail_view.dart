import 'package:v2box/common/common.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/services/v2board/v2board.dart';
import 'package:v2box/state.dart';
import 'package:v2box/views/subscription/payment_flow.dart';
import 'package:v2box/views/v2board/v2board_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    _couponController.addListener(_onCouponChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentMethods();
    });
  }

  @override
  void dispose() {
    _couponController
      ..removeListener(_onCouponChanged)
      ..dispose();
    super.dispose();
  }

  void _onCouponChanged() {
    if (mounted) {
      setState(() {});
    }
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

  String _selectedPeriodLabel() {
    return _periodLabels[_selectedPeriod] ?? '请选择周期';
  }

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
      if (!mounted) {
        return;
      }
      final paid = await startV2BoardPaymentFlow(
        context: context,
        ref: ref,
        tradeNo: tradeNo,
        planName: widget.plan.name,
        periodLabel: _selectedPeriodLabel(),
        amountText: _priceText(_selectedPrice),
        paymentMethodValue: _selectedPaymentMethodValue ?? '',
        paymentMethodLabel: _selectedPaymentLabel(),
      );
      if (paid == true && mounted) {
        globalState.showNotifier('支付成功，订单已完成');
      }
    } catch (error) {
      if (mounted) {
        globalState.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(
            text: formatPaymentFlowError(error, fallback: '下单或拉起支付失败，请稍后重试。'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ref.watch(isMobileViewProvider);
    final horizontal = isMobile ? 16.0 : 24.0;
    final bottomPadding = isMobile ? 108.0 : 32.0;
    final content = ListView(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        isMobile ? 12 : 22,
        horizontal,
        bottomPadding,
      ),
      children: [
        _DetailHeader(compact: isMobile),
        const SizedBox(height: 18),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: isMobile ? _mobileContent() : _desktopContent(),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: v2BoardPageBackground,
      body: SafeArea(child: content),
      bottomNavigationBar: isMobile ? _mobilePayBar() : null,
    );
  }

  Widget _desktopContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailHeroCard(
          planName: widget.plan.name,
          trafficText: _trafficText(),
          priceText: _priceText(_selectedPrice),
          periodText: _selectedPeriodLabel(),
          features: _featureRows,
          compact: false,
        ),
        const SizedBox(height: 14),
        _SpecificationSection(
          periods: _availablePeriods,
          selectedPeriod: _selectedPeriod,
          periodLabels: _periodLabels,
          priceText: _priceText,
          onChanged: (period) {
            setState(() => _selectedPeriod = period);
          },
        ),
        const SizedBox(height: 14),
        Row(
          key: const ValueKey('plan-detail-desktop-grid'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: _PaymentSection(
                couponController: _couponController,
                paymentMethods: _paymentMethods,
                selectedPaymentMethodValue: _selectedPaymentMethodValue,
                onPaymentChanged: (value) {
                  setState(() => _selectedPaymentMethodValue = value);
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 4,
              child: _OrderSummaryCard(
                planName: widget.plan.name,
                periodLabel: _selectedPeriodLabel(),
                paymentLabel: _selectedPaymentLabel(),
                couponCode: _couponController.text.trim(),
                amountText: _priceText(_selectedPrice),
                isLoading: _isLoading,
                onSubmit: _submitOrder,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _mobileContent() {
    return Column(
      children: [
        _DetailHeroCard(
          planName: widget.plan.name,
          trafficText: _trafficText(),
          priceText: _priceText(_selectedPrice),
          periodText: _selectedPeriodLabel(),
          features: _featureRows,
          compact: true,
        ),
        const SizedBox(height: 12),
        _SpecificationSection(
          periods: _availablePeriods,
          selectedPeriod: _selectedPeriod,
          periodLabels: _periodLabels,
          priceText: _priceText,
          compact: true,
          onChanged: (period) {
            setState(() => _selectedPeriod = period);
          },
        ),
        const SizedBox(height: 12),
        _PaymentSection(
          couponController: _couponController,
          paymentMethods: _paymentMethods,
          selectedPaymentMethodValue: _selectedPaymentMethodValue,
          compact: true,
          onPaymentChanged: (value) {
            setState(() => _selectedPaymentMethodValue = value);
          },
        ),
      ],
    );
  }

  Widget _mobilePayBar() {
    return SafeArea(
      key: const ValueKey('plan-detail-mobile-sticky-pay'),
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: v2BoardSurface,
          border: Border(top: BorderSide(color: v2BoardLine)),
          boxShadow: [
            BoxShadow(
              color: Color(0x120D1B3D),
              blurRadius: 18,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '应付金额',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: v2BoardMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _priceText(_selectedPrice),
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: v2BoardInk,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 156,
              child: V2BoardPrimaryButton(
                label: '立即支付',
                loading: _isLoading,
                onPressed: _selectedPeriod == null ? null : _submitOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final bool compact;

  const _DetailHeader({required this.compact});

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
                title: '套餐详情',
                subtitle: compact ? null : '确认规格、优惠与支付方式',
                compact: compact,
              ),
            ),
          ],
        ),
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
  final bool compact;

  const _DetailHeroCard({
    required this.planName,
    required this.trafficText,
    required this.priceText,
    required this.periodText,
    required this.features,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final overview = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: compact ? 52 : 72,
              height: compact ? 52 : 72,
              decoration: BoxDecoration(
                gradient: v2BoardGradient,
                borderRadius: BorderRadius.circular(compact ? 12 : 16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x264F5BFF),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                color: Colors.white,
                size: compact ? 28 : 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (compact
                                ? context.textTheme.titleLarge
                                : context.textTheme.headlineSmall)
                            ?.copyWith(
                              color: v2BoardInk,
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trafficText,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: v2BoardMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: priceText,
                style:
                    (compact
                            ? context.textTheme.headlineMedium
                            : context.textTheme.displaySmall)
                        ?.copyWith(
                          color: v2BoardInk,
                          fontWeight: FontWeight.w800,
                        ),
              ),
              TextSpan(
                text: ' / $periodText',
                style: context.textTheme.titleMedium?.copyWith(
                  color: v2BoardMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final featureList = Column(
      children: [
        for (final feature in features)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: v2BoardInk,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    feature,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: v2BoardInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    return V2BoardCard(
      padding: EdgeInsets.all(compact ? 18 : 22),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                overview,
                if (features.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  featureList,
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: overview),
                if (features.isNotEmpty) ...[
                  const SizedBox(width: 26),
                  Container(width: 1, height: 112, color: v2BoardLine),
                  const SizedBox(width: 26),
                  Expanded(flex: 4, child: featureList),
                ],
              ],
            ),
    );
  }
}

class _SpecificationSection extends StatelessWidget {
  final Map<String, int> periods;
  final String? selectedPeriod;
  final Map<String, String> periodLabels;
  final String Function(int price) priceText;
  final ValueChanged<String> onChanged;
  final bool compact;

  const _SpecificationSection({
    required this.periods,
    required this.selectedPeriod,
    required this.periodLabels,
    required this.priceText,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '订阅规格',
      subtitle: compact ? null : '选择你想购买的计费周期',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = compact ? 3 : 3;
          final spacing = compact ? 8.0 : 12.0;
          final itemWidth =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: periods.entries
                .map((entry) {
                  final selected = selectedPeriod == entry.key;
                  return SizedBox(
                    width: itemWidth.clamp(88.0, 260.0),
                    child: _PeriodOption(
                      label: periodLabels[entry.key] ?? entry.key,
                      price: priceText(entry.value),
                      selected: selected,
                      compact: compact,
                      onTap: () => onChanged(entry.key),
                    ),
                  );
                })
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _PeriodOption extends StatelessWidget {
  final String label;
  final String price;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _PeriodOption({
    required this.label,
    required this.price,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : v2BoardInk;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: compact ? 66 : 76,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 16,
            vertical: compact ? 9 : 12,
          ),
          decoration: BoxDecoration(
            gradient: selected ? v2BoardGradient : null,
            color: selected ? null : const Color(0xFFF7F9FD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? v2BoardPrimary : v2BoardLine),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: selected ? Colors.white70 : v2BoardMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (selected)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  final TextEditingController couponController;
  final List<V2BoardPaymentOption> paymentMethods;
  final String? selectedPaymentMethodValue;
  final ValueChanged<String> onPaymentChanged;
  final bool compact;

  const _PaymentSection({
    required this.couponController,
    required this.paymentMethods,
    required this.selectedPaymentMethodValue,
    required this.onPaymentChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '优惠与支付',
      subtitle: compact ? null : '可选填写优惠码并选择支付方式',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '优惠码',
            style: context.textTheme.bodyMedium?.copyWith(
              color: v2BoardInk,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  decoration: InputDecoration(
                    hintText: '输入优惠码',
                    filled: true,
                    fillColor: const Color(0xFFF7F9FD),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: v2BoardLine),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: v2BoardLine),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: v2BoardPrimary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 76,
                height: 46,
                child: V2BoardPrimaryButton(label: '使用', onPressed: () {}),
              ),
            ],
          ),
          if (paymentMethods.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '支付方式',
              style: context.textTheme.bodyMedium?.copyWith(
                color: v2BoardInk,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: paymentMethods
                  .map((method) {
                    final selected = selectedPaymentMethodValue == method.value;
                    return _PaymentMethodOption(
                      label: method.label,
                      selected: selected,
                      onTap: () => onPaymentChanged(method.value),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  IconData get _icon {
    final text = label.toLowerCase();
    if (text.contains('stripe') ||
        text.contains('card') ||
        text.contains('信用')) {
      return Icons.credit_card_rounded;
    }
    if (text.contains('微信') || text.contains('wechat')) {
      return Icons.wechat_rounded;
    }
    return Icons.account_balance_wallet_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 118,
          height: 70,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? v2BoardSoft : const Color(0xFFF7F9FD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? v2BoardPrimary : v2BoardLine,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icon,
                      color: selected ? v2BoardPrimary : v2BoardMuted,
                      size: 24,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: v2BoardInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: v2BoardPrimary,
                    size: 17,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final String planName;
  final String periodLabel;
  final String paymentLabel;
  final String couponCode;
  final String amountText;
  final bool isLoading;
  final VoidCallback? onSubmit;

  const _OrderSummaryCard({
    required this.planName,
    required this.periodLabel,
    required this.paymentLabel,
    required this.couponCode,
    required this.amountText,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '订单摘要',
      subtitle: null,
      child: Column(
        children: [
          _SummaryRow(label: '套餐', value: planName),
          const SizedBox(height: 12),
          _SummaryRow(label: '周期', value: periodLabel),
          const SizedBox(height: 12),
          _SummaryRow(label: '支付方式', value: paymentLabel),
          const SizedBox(height: 12),
          _SummaryRow(
            label: '优惠码',
            value: couponCode.isEmpty ? '未填写' : couponCode,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: v2BoardLine),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '应付金额',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: v2BoardInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                amountText,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: v2BoardInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          V2BoardPrimaryButton(
            label: '立即支付',
            loading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return V2BoardCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: v2BoardInk,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: v2BoardMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
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
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: v2BoardInk,
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
