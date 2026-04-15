import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<dynamic> _paymentMethods = const [];
  String? _selectedPeriod;
  String? _selectedPaymentMethod;
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
      setState(() {
        _paymentMethods = methods;
        _selectedPaymentMethod = methods.firstOrNull?.toString();
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
        _selectedPaymentMethod ?? '',
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
    return CommonScaffold(
      title: widget.plan.name,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CommonCard(
            type: CommonCardType.filled,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plan.name,
                    style: context.textTheme.headlineSmall,
                  ),
                  if ((widget.plan.content ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(widget.plan.content!),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availablePeriods.entries
                        .map(
                          (entry) => ChoiceChip(
                            label: Text(
                              '${_periodLabels[entry.key] ?? entry.key} ¥${(entry.value / 100).toStringAsFixed(2)}',
                            ),
                            selected: _selectedPeriod == entry.key,
                            onSelected: (_) {
                              setState(() {
                                _selectedPeriod = entry.key;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _couponController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '优惠码',
            ),
          ),
          if (_paymentMethods.isNotEmpty) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedPaymentMethod,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '支付方式',
              ),
              items: _paymentMethods
                  .map(
                    (method) => DropdownMenuItem<String>(
                      value: method.toString(),
                      child: Text(method.toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _submitOrder,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('立即购买'),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNullList<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
