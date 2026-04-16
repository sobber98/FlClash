import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/list.dart';
import 'package:fl_clash/views/proxies/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'setting.dart';
import 'tab.dart';

const _proxiesBackground = Color(0xFFF5F6F8);

class ProxiesView extends ConsumerStatefulWidget {
  const ProxiesView({super.key});

  @override
  ConsumerState<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<ProxiesView> {
  final GlobalKey<CommonScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();
  bool _hasProviders = false;
  bool _isTab = false;

  Future<void> _runAutoTest() async {
    await ref.read(autoTestControllerProvider).runNow();
  }

  List<Widget> _buildActions() {
    final autoTestState = ref.watch(autoTestStateProvider);
    return [
      if (_isTab)
        IconButton(
          onPressed: () {
            _proxiesTabKey.currentState?.scrollToGroupSelected();
          },
          icon: Icon(Icons.adjust, weight: 1),
        ),
      IconButton(
        onPressed: autoTestState.isTesting ? null : _runAutoTest,
        icon: autoTestState.isTesting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.network_ping_outlined),
      ),
      CommonPopupBox(
        targetBuilder: (open) {
          return IconButton(
            onPressed: () {
              final isMobile = ref.read(isMobileViewProvider);
              open(offset: Offset(0, isMobile ? 0 : 20));
            },
            icon: Icon(Icons.more_vert),
          );
        },
        popup: CommonPopupMenu(
          items: [
            PopupMenuItemData(
              icon: Icons.tune,
              label: appLocalizations.settings,
              onPressed: () {
                showSheet(
                  context: context,
                  props: SheetProps(isScrollControlled: true),
                  builder: (_, type) {
                    return AdaptiveSheetScaffold(
                      type: type,
                      body: const ProxiesSetting(),
                      title: appLocalizations.settings,
                    );
                  },
                );
              },
            ),
            if (_hasProviders)
              PopupMenuItemData(
                icon: Icons.poll_outlined,
                label: appLocalizations.providers,
                onPressed: () {
                  showExtend(
                    context,
                    builder: (_, type) {
                      return ProvidersView(type: type);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    ];
  }

  Widget? _buildFAB() {
    return _isTab
        ? DelayTestButton(
            onClick: () async {
              await _proxiesTabKey.currentState?.delayTestCurrentGroup();
            },
          )
        : null;
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.proxies).notifier).value = value;
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(providersProvider.select((state) => state.isNotEmpty), (
      prev,
      next,
    ) {
      if (prev != next) {
        setState(() {
          _hasProviders = next;
        });
      }
    }, fireImmediately: true);
    ref.listenManual(
      proxiesStyleSettingProvider.select(
        (state) => state.type == ProxiesType.tab,
      ),
      (prev, next) {
        if (prev != next) {
          setState(() {
            _isTab = next;
          });
        }
      },
      fireImmediately: true,
    );
    ref.listenManual(
      currentPageLabelProvider.select((state) => state == PageLabel.proxies),
      (prev, next) {
        if (prev != next && next == false) {
          _scaffoldKey.currentState?.handleExitSearching();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ref.watch(isMobileViewProvider);
    final proxiesType = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.type),
    );
    final isLoading = ref.watch(loadingProvider(LoadingTag.proxies));
    final autoTestState = ref.watch(autoTestStateProvider);
    final currentGroupName = ref.watch(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    final selectedProxyName = currentGroupName == null
        ? null
        : ref.watch(getSelectedProxyNameProvider(currentGroupName));
    final lastTestText = autoTestState.lastUpdatedAt == null
        ? '未测速'
        : '最近测速 ${autoTestState.lastUpdatedAt!.hour.toString().padLeft(2, '0')}:${autoTestState.lastUpdatedAt!.minute.toString().padLeft(2, '0')}';
    return CommonScaffold(
      key: _scaffoldKey,
      isLoading: isLoading,
      resizeToAvoidBottomInset: false,
      floatingActionButton: _buildFAB(),
      actions: _buildActions(),
      title: appLocalizations.proxies,
      searchState: AppBarSearchState(onSearch: _onSearch),
      body: Container(
        color: _proxiesBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                12,
                isMobile ? 16 : 24,
                0,
              ),
              child: _ProxyOverviewCard(
                currentGroupName: currentGroupName,
                selectedProxyName: selectedProxyName,
                lastTestText: lastTestText,
                viewModeText: proxiesType == ProxiesType.tab ? '标签视图' : '列表视图',
                isTesting: autoTestState.isTesting,
                onRunAutoTest: autoTestState.isTesting ? null : _runAutoTest,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 24,
                  16,
                  isMobile ? 16 : 24,
                  0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 18,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: switch (proxiesType) {
                    ProxiesType.tab => ProxiesTabView(key: _proxiesTabKey),
                    ProxiesType.list => const ProxiesListView(),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProxyOverviewCard extends StatelessWidget {
  final String? currentGroupName;
  final String? selectedProxyName;
  final String lastTestText;
  final String viewModeText;
  final bool isTesting;
  final VoidCallback? onRunAutoTest;

  const _ProxyOverviewCard({
    required this.currentGroupName,
    required this.selectedProxyName,
    required this.lastTestText,
    required this.viewModeText,
    required this.isTesting,
    required this.onRunAutoTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '代理中心',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '快速切换分组、查看节点状态并执行延迟测试',
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ProxyMetric(
                  label: '当前分组',
                  value: currentGroupName?.isNotEmpty == true
                      ? currentGroupName!
                      : '自动分组',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProxyMetric(
                  label: '当前节点',
                  value: selectedProxyName?.isNotEmpty == true
                      ? selectedProxyName!
                      : '自动选择',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ProxyMetric(label: '显示模式', value: viewModeText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProxyMetric(label: '测速状态', value: lastTestText),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRunAutoTest,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: isTesting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bolt_rounded),
              label: Text(isTesting ? '测速中' : '重新测试全部节点'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProxyMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ProxyMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
