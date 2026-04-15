import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/tab.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NodeSelector extends ConsumerWidget {
  const NodeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGroupName = ref.watch(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    final selectedProxyName = currentGroupName == null
        ? null
        : ref.watch(getSelectedProxyNameProvider(currentGroupName));
    final delay = selectedProxyName == null
        ? null
        : ref.watch(getDelayProvider(proxyName: selectedProxyName));

    return CommonCard(
      type: CommonCardType.filled,
      onPressed: () {
        showSheet(
          context: context,
          props: SheetProps(isScrollControlled: true),
          builder: (_, type) {
            return AdaptiveSheetScaffold(
              type: type,
              title: appLocalizations.proxies,
              body: const ProxiesTabView(),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '节点选择',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              selectedProxyName?.isNotEmpty == true
                  ? selectedProxyName!
                  : appLocalizations.proxies,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium?.toSoftBold,
            ),
            const SizedBox(height: 4),
            Text(
              delay == null
                  ? '点击打开节点列表'
                  : delay > 0
                  ? '$delay ms'
                  : 'Timeout',
              style: context.textTheme.bodySmall?.copyWith(
                color: utils.getDelayColor(delay),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
