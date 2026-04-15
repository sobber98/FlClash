import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectButton extends ConsumerWidget {
  final double size;

  const ConnectButton({super.key, this.size = 112});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(coreStatusProvider);
    final isRunning = ref.watch(isStartProvider);
    final runTime = ref.watch(runTimeProvider);
    final scheme = Theme.of(context).colorScheme;
    final backgroundColor = switch (status) {
      CoreStatus.connected => Colors.green,
      CoreStatus.connecting => scheme.secondary,
      CoreStatus.disconnected => scheme.error,
    };
    final label = switch (status) {
      CoreStatus.connected =>
        isRunning ? appLocalizations.connected : appLocalizations.disconnected,
      CoreStatus.connecting => appLocalizations.connecting,
      CoreStatus.disconnected => appLocalizations.disconnected,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.28),
                blurRadius: 24,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: status == CoreStatus.connecting
                  ? null
                  : () {
                      appController.updateStart();
                    },
              child: Center(
                child: status == CoreStatus.connecting
                    ? const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isRunning ? Icons.power_settings_new : Icons.play_arrow,
                        size: 42,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(label, style: context.textTheme.titleMedium?.toSoftBold),
        const SizedBox(height: 4),
        Text(
          utils.getTimeText(runTime),
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
