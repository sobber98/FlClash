import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/views/subscription/payment_checkout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String formatPaymentFlowError(
  Object error, {
  String fallback = '支付流程异常，请稍后重试。',
}) {
  final text = error.toString().trim();
  if (text.isEmpty || text == 'null') {
    return fallback;
  }
  return text;
}

Future<bool> startV2BoardPaymentFlow({
  required BuildContext context,
  required WidgetRef ref,
  required String tradeNo,
  required String planName,
  required String periodLabel,
  required String amountText,
  String paymentMethodValue = '',
  String paymentMethodLabel = '系统默认',
}) async {
  final api = ref.read(v2boardApiClientProvider);
  if (api == null) {
    throw 'V2Board API is not initialized';
  }

  final result = await api.checkoutOrder(
    tradeNo,
    paymentMethodValue,
    callbackUrl: v2boardPaymentCallbackUrl(tradeNo),
  );
  final url = v2boardCheckoutUrl(
    result,
    baseUrl: api.endpoints.baseUrl,
  );
  if (url == null || url.isEmpty) {
    throw StateError('未获取到有效支付链接，请检查支付通道配置后重试。');
  }
  await ref.read(subscriptionOrdersProvider.notifier).refresh();
  if (!context.mounted) {
    return false;
  }
  final paid = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => PaymentCheckoutView(
        tradeNo: tradeNo,
        planName: planName,
        periodLabel: periodLabel,
        amountText: amountText,
        paymentMethodLabel: paymentMethodLabel,
        paymentUrl: url,
      ),
    ),
  );
  return paid == true;
}