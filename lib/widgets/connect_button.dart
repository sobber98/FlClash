import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectButton extends ConsumerWidget {
  final double size;
  final bool showDetails;

  const ConnectButton({
    super.key,
    this.size = 112,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(coreStatusProvider);
    final isRunning = ref.watch(isStartProvider);
    final runTime = ref.watch(runTimeProvider);
    final scheme = Theme.of(context).colorScheme;
    final isConnected = status == CoreStatus.connected && isRunning;
    final backgroundColor = switch (status) {
      CoreStatus.connected => Colors.black,
      CoreStatus.connecting => const Color(0xFF1F2937),
      CoreStatus.disconnected => Colors.white,
    };
    final iconColor = switch (status) {
      CoreStatus.connected => Colors.white,
      CoreStatus.connecting => Colors.white,
      CoreStatus.disconnected => const Color(0xFFC6CBD4),
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
            border: Border.all(
              color: isConnected
                  ? Colors.black
                  : const Color(0xFFF0F2F6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 16),
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
                    ? SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: iconColor,
                        ),
                      )
                    : Icon(
                        Icons.power_settings_new_rounded,
                        size: size * 0.34,
                        color: iconColor,
                      ),
              ),
            ),
          ),
        ),
        if (showDetails) ...[
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
      ],
    );
  }
}
