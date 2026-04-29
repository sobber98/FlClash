import 'package:v2box/common/common.dart';
import 'package:v2box/controller.dart';
import 'package:v2box/enum/enum.dart';
import 'package:v2box/models/models.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/state.dart';
import 'package:v2box/views/proxies/common.dart';
import 'package:v2box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxyCard extends StatelessWidget {
  final String groupName;
  final Proxy proxy;
  final GroupType groupType;
  final ProxyCardType type;
  final String? testUrl;

  const ProxyCard({
    super.key,
    required this.groupName,
    required this.testUrl,
    required this.proxy,
    required this.groupType,
    required this.type,
  });

  Measure get measure => globalState.measure;

  void _handleTestCurrentDelay() {
    proxyDelayTest(proxy, testUrl);
  }

  Widget _buildDelayText({required bool isSelected, required BuildContext context}) {
    final onCardColor = isSelected
        ? context.colorScheme.surface
        : context.colorScheme.onSurface;
    final onCardVariantColor = isSelected
        ? context.colorScheme.surface.opacity80
        : context.colorScheme.onSurfaceVariant;
    return SizedBox(
      height: measure.labelSmallHeight,
      child: Consumer(
        builder: (context, ref, _) {
          final autoTestState = ref.watch(autoTestStateProvider);
          final delay = ref.watch(
            getDelayProvider(proxyName: proxy.name, testUrl: testUrl),
          );
          final updatedAt = autoTestState.lastUpdatedAt;
          final updatedText = updatedAt == null
              ? ''
              : '${updatedAt.hour.toString().padLeft(2, '0')}:${updatedAt.minute.toString().padLeft(2, '0')}';
          return FadeThroughBox(
            alignment: type == ProxyCardType.expand
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (type == ProxyCardType.expand && updatedText.isNotEmpty) ...[
                  Text(
                    updatedText,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: onCardVariantColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                delay == 0 || delay == null
                    ? SizedBox(
                        height: measure.labelSmallHeight,
                        width: measure.labelSmallHeight,
                        child: delay == 0
                            ? CircularProgressIndicator(
                                strokeWidth: 2,
                                color: onCardColor,
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.bolt_rounded,
                                  color: onCardColor,
                                ),
                                iconSize: globalState.measure.labelSmallHeight,
                                padding: EdgeInsets.zero,
                                onPressed: _handleTestCurrentDelay,
                              ),
                      )
                    : GestureDetector(
                        onTap: _handleTestCurrentDelay,
                        child: Text(
                          delay > 0 ? '$delay ms' : 'Timeout',
                          style: context.textTheme.labelSmall?.copyWith(
                            overflow: TextOverflow.ellipsis,
                            color: isSelected
                                ? onCardColor
                                : utils.getDelayColor(delay),
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProxyNameText(BuildContext context, {required bool isSelected}) {
    final onCardColor = isSelected
        ? context.colorScheme.surface
        : context.colorScheme.onSurface;
    if (type == ProxyCardType.min) {
      return SizedBox(
        height: measure.bodyMediumHeight * 1,
        child: EmojiText(
          proxy.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: onCardColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return SizedBox(
        height: measure.bodyMediumHeight * 2,
        child: EmojiText(
          proxy.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: onCardColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  Future<void> _changeProxy(WidgetRef ref) async {
    final isComputedSelected = groupType.isComputedSelected;
    final isSelector = groupType == GroupType.Selector;
    if (isComputedSelected || isSelector) {
      final currentProxyName = ref.read(getProxyNameProvider(groupName));
      final nextProxyName = switch (isComputedSelected) {
        true => currentProxyName == proxy.name ? '' : proxy.name,
        false => proxy.name,
      };
      appController.updateCurrentSelectedMap(groupName, nextProxyName);
      appController.changeProxyDebounce(groupName, nextProxyName);
      return;
    }
    globalState.showNotifier(appLocalizations.notSelectedTip);
  }

  @override
  Widget build(BuildContext context) {
    final measure = globalState.measure;
    return Stack(
      children: [
        Consumer(
          builder: (_, ref, child) {
            final selectedProxyName = ref.watch(
              getSelectedProxyNameProvider(groupName),
            );
            final isSelected = selectedProxyName == proxy.name;
            final delayText = _buildDelayText(isSelected: isSelected, context: context);
            final proxyNameText = _buildProxyNameText(
              context,
              isSelected: isSelected,
            );
            return Material(
              color: Colors.transparent,
              child: InkWell(
                key: key,
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  _changeProxy(ref);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colorScheme.onSurface
                        : context.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? context.colorScheme.onSurface
                          : context.colorScheme.outlineVariant,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      proxyNameText,
                      const SizedBox(height: 8),
                      if (type == ProxyCardType.expand) ...[
                        SizedBox(
                          height: measure.bodySmallHeight,
                          child: _ProxyDesc(
                            proxy: proxy,
                            isSelected: isSelected,
                          ),
                        ),
                        const SizedBox(height: 6),
                        delayText,
                      ] else
                        SizedBox(
                          height: measure.bodySmallHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 1,
                                child: TooltipText(
                                  text: Text(
                                    proxy.type,
                                    style: context.textTheme.bodySmall?.copyWith(
                                      overflow: TextOverflow.ellipsis,
                                      color: isSelected
                                          ? context.colorScheme.surface.opacity80
                                          : context.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              delayText,
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (groupType.isComputedSelected)
          Positioned(
            top: 0,
            right: 0,
            child: _ProxyComputedMark(groupName: groupName, proxy: proxy),
          ),
      ],
    );
  }
}

class _ProxyDesc extends ConsumerWidget {
  final Proxy proxy;
  final bool isSelected;

  const _ProxyDesc({required this.proxy, required this.isSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desc = ref.watch(getProxyDescProvider(proxy));
    return EmojiText(
      desc,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.bodySmall?.copyWith(
        color: isSelected
            ? context.colorScheme.surface.opacity80
            : context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ProxyComputedMark extends ConsumerWidget {
  final String groupName;
  final Proxy proxy;

  const _ProxyComputedMark({required this.groupName, required this.proxy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxyName = ref.watch(getProxyNameProvider(groupName));
    if (proxyName != proxy.name) {
      return SizedBox();
    }
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: const SelectIcon(),
      ),
    );
  }
}
