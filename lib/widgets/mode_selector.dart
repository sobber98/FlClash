import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ModeSelector extends ConsumerWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    return CommonCard(
      type: CommonCardType.filled,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.outboundMode,
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<Mode>(
              showSelectedIcon: false,
              multiSelectionEnabled: false,
              segments: Mode.values
                  .map(
                    (item) => ButtonSegment<Mode>(
                      value: item,
                      label: Text(Intl.message(item.name)),
                    ),
                  )
                  .toList(),
              selected: {mode},
              onSelectionChanged: (selection) {
                final value = selection.firstOrNull;
                if (value != null) {
                  appController.changeMode(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension _ModeSelectionExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
