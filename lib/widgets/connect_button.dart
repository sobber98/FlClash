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
    final connectionState = ref.watch(connectionVisualStateProvider);
    final runTime = ref.watch(runTimeProvider);
    final scheme = Theme.of(context).colorScheme;
    final isConnected = connectionState == ConnectionVisualState.connected;
    final backgroundColor = switch (connectionState) {
      ConnectionVisualState.connected => const Color(0xFF16A34A),
      ConnectionVisualState.connecting => const Color(0xFF1F2937),
      ConnectionVisualState.disconnecting => const Color(0xFF7C2D12),
      ConnectionVisualState.disconnected => Colors.white,
    };
    final iconColor = switch (connectionState) {
      ConnectionVisualState.connected => Colors.white,
      ConnectionVisualState.connecting => Colors.white,
      ConnectionVisualState.disconnecting => Colors.white,
      ConnectionVisualState.disconnected => const Color(0xFF6B7280),
    };
    final label = switch (connectionState) {
      ConnectionVisualState.connected => appLocalizations.connected,
      ConnectionVisualState.connecting => appLocalizations.connecting,
      ConnectionVisualState.disconnecting => '断开中',
      ConnectionVisualState.disconnected => appLocalizations.disconnected,
    };
    final detail = switch (connectionState) {
      ConnectionVisualState.connected => utils.getTimeText(runTime),
      ConnectionVisualState.connecting => '正在建立连接',
      ConnectionVisualState.disconnecting => '正在断开连接',
      ConnectionVisualState.disconnected => '点击连接',
    };
    final labelColor = switch (connectionState) {
      ConnectionVisualState.connected => const Color(0xFF16A34A),
      ConnectionVisualState.connecting => scheme.onSurface,
      ConnectionVisualState.disconnecting => const Color(0xFF9A3412),
      ConnectionVisualState.disconnected => scheme.onSurface,
    };
    final borderColor = switch (connectionState) {
      ConnectionVisualState.connected => const Color(0xFF86EFAC),
      ConnectionVisualState.connecting => const Color(0xFF374151),
      ConnectionVisualState.disconnecting => const Color(0xFFF97316),
      ConnectionVisualState.disconnected => const Color(0xFFE5E7EB),
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
              onTap: connectionState == ConnectionVisualState.connecting ||
                      connectionState == ConnectionVisualState.disconnecting
                  ? null
                  : () {
                      appController.updateStart();
                    },
              child: Center(
                child: connectionState == ConnectionVisualState.connecting ||
                        connectionState == ConnectionVisualState.disconnecting
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
              color: switch (connectionState) {
                ConnectionVisualState.connected => const Color(0xFF15803D),
                ConnectionVisualState.disconnecting => const Color(0xFF9A3412),
                _ => scheme.onSurfaceVariant,
              },
            ),
          ),
        ],
      ],
    );
  }
}
