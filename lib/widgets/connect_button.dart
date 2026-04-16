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
    final effectiveStatus = switch (status) {
      CoreStatus.connecting => CoreStatus.connecting,
      CoreStatus.connected => isRunning
          ? CoreStatus.connected
          : CoreStatus.disconnected,
      CoreStatus.disconnected => CoreStatus.disconnected,
    };
    final isConnected = effectiveStatus == CoreStatus.connected;
    final backgroundColor = switch (effectiveStatus) {
      CoreStatus.connected => const Color(0xFF16A34A),
      CoreStatus.connecting => const Color(0xFF1F2937),
      CoreStatus.disconnected => Colors.white,
    };
    final iconColor = switch (effectiveStatus) {
      CoreStatus.connected => Colors.white,
      CoreStatus.connecting => Colors.white,
      CoreStatus.disconnected => const Color(0xFF6B7280),
    };
    final label = switch (effectiveStatus) {
      CoreStatus.connected => appLocalizations.connected,
      CoreStatus.connecting => appLocalizations.connecting,
      CoreStatus.disconnected => appLocalizations.disconnected,
    };
    final detail = switch (effectiveStatus) {
      CoreStatus.connected => utils.getTimeText(runTime),
      CoreStatus.connecting => '正在建立连接',
      CoreStatus.disconnected => '点击连接',
    };
    final labelColor = switch (effectiveStatus) {
      CoreStatus.connected => const Color(0xFF16A34A),
      CoreStatus.connecting => scheme.onSurface,
      CoreStatus.disconnected => scheme.onSurface,
    };
    final borderColor = switch (effectiveStatus) {
      CoreStatus.connected => const Color(0xFF86EFAC),
      CoreStatus.connecting => const Color(0xFF374151),
      CoreStatus.disconnected => const Color(0xFFE5E7EB),
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
            border: Border.all(color: borderColor, width: isConnected ? 3 : 1.5),
            boxShadow: [
              BoxShadow(
                color: (isConnected
                        ? const Color(0xFF16A34A)
                        : Colors.black)
                    .withValues(alpha: isConnected ? 0.22 : 0.06),
                blurRadius: isConnected ? 36 : 30,
                spreadRadius: isConnected ? 4 : 2,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: effectiveStatus == CoreStatus.connecting
                  ? null
                  : () {
                      appController.updateStart();
                    },
              child: Center(
                child: effectiveStatus == CoreStatus.connecting
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
          Text(
            label,
            style: context.textTheme.titleMedium?.toSoftBold.copyWith(
              color: labelColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: context.textTheme.bodySmall?.copyWith(
              color: isConnected
                  ? const Color(0xFF15803D)
                  : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
