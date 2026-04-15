import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionCard extends ConsumerWidget {
  final VoidCallback? onPressed;

  const SubscriptionCard({super.key, this.onPressed});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var index = 0;
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    return '${value.toStringAsFixed(2)} ${units[index]}';
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null || timestamp == 0) {
      return appLocalizations.infiniteTime;
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).show;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = _asyncDataOrNull(ref.watch(v2boardUserProvider));
    final subscription = _asyncDataOrNull(
      ref.watch(v2boardSubscriptionProvider),
    );
    final currentPlan = ref.watch(currentPlanProvider);
    final hasSubscription = user != null || subscription != null;
    final title = hasSubscription
        ? (currentPlan?.name.isNotEmpty == true
              ? currentPlan!.name
              : appLocalizations.v2boardSubscription)
        : '未登录';
    final used = (user?.upload ?? 0) + (user?.download ?? 0);
    final total = user?.transferEnable ?? subscription?.transferEnable ?? 0;
    final progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;

    return CommonCard(
      type: CommonCardType.filled,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: context.textTheme.titleMedium?.toSoftBold),
                Text(
                  hasSubscription
                      ? _formatDate(subscription?.expiredAt ?? user?.expiredAt)
                      : '登录后查看',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (hasSubscription) ...[
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 10),
              Text(
                '${_formatBytes(used)} / ${_formatBytes(total)}',
                style: context.textTheme.bodyMedium,
              ),
            ] else
              Text(
                '登录账号后可在这里查看剩余流量、到期时间与重置日。',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            if (hasSubscription && subscription?.resetDay != null) ...[
              const SizedBox(height: 4),
              Text(
                '${appLocalizations.reset}: ${subscription!.resetDay}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

T? _asyncDataOrNull<T>(AsyncValue<T> value) {
  return value is AsyncData<T> ? value.value : null;
}
