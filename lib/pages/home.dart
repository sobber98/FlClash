import 'package:v2box/common/common.dart';
import 'package:v2box/controller.dart';
import 'package:v2box/enum/enum.dart';
import 'package:v2box/models/common.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/services/v2board/v2board.dart';
import 'package:v2box/views/v2board/login_view.dart';
import 'package:v2box/views/v2board/v2board_design.dart';
import 'package:v2box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _shellBackground = v2BoardPageBackground;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final props = ref.watch(v2boardSettingProvider);
    final isLoggedIn = props?.isLoggedIn ?? false;
    if (!isLoggedIn) {
      return const _StartupLoginPage();
    }
    return const _AuthenticatedHomePage();
  }
}

class _StartupLoginPage extends ConsumerWidget {
  const _StartupLoginPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appName = ref.watch(appDisplayNameProvider);
    return Scaffold(
      backgroundColor: v2BoardPageBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 860;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: v2BoardLine),
                      boxShadow: v2BoardShadow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(
                                flex: 38,
                                child: _AuthHeroPanel(appName: appName),
                              ),
                              const Expanded(
                                flex: 62,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 54,
                                    vertical: 44,
                                  ),
                                  child: V2BoardLoginView(),
                                ),
                              ),
                            ],
                          )
                        : const Padding(
                            padding: EdgeInsets.fromLTRB(18, 20, 18, 24),
                            child: V2BoardLoginView(),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeroPanel extends StatelessWidget {
  final String appName;

  const _AuthHeroPanel({required this.appName});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 620),
      padding: const EdgeInsets.fromLTRB(42, 48, 36, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F6FF), Color(0xFFEAF0FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2BoardLogo(size: 48, showText: false),
          const SizedBox(height: 18),
          Text(
            '$appName Client',
            style: context.textTheme.headlineSmall?.copyWith(
              color: v2BoardInk,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBFF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '安全 · 稳定 · 高效',
              style: context.textTheme.labelMedium?.copyWith(
                color: v2BoardPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 46),
          Text(
            '安全连接全球网络\n极速稳定的访问体验',
            style: context.textTheme.displaySmall?.copyWith(
              color: v2BoardInk,
              fontWeight: FontWeight.w800,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '为个人与团队提供安全、稳定、易用的网络连接服务，多端同步，随时随地畅享全球资源。',
            style: context.textTheme.bodyLarge?.copyWith(
              color: v2BoardMuted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),
          const _HeroFeature(
            icon: Icons.verified_user_outlined,
            title: '安全连接',
            text: '多重加密协议，保障数据传输安全可靠',
          ),
          const SizedBox(height: 18),
          const _HeroFeature(
            icon: Icons.flash_on_outlined,
            title: '极速节点',
            text: '全球优质节点加速，智能路由低延迟',
          ),
          const SizedBox(height: 18),
          const _HeroFeature(
            icon: Icons.devices_outlined,
            title: '多端同步',
            text: '支持 PC / Mobile 多端使用，数据实时同步',
          ),
          const Spacer(),
          Text(
            '© 2024 V2Board. All rights reserved.',
            style: context.textTheme.bodySmall?.copyWith(color: v2BoardMuted),
          ),
        ],
      ),
    );
  }
}

class _HeroFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _HeroFeature({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        V2BoardIconBox(icon: icon, size: 42),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  color: v2BoardInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: context.textTheme.bodySmall?.copyWith(
                  color: v2BoardMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthenticatedHomePage extends ConsumerWidget {
  const _AuthenticatedHomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);
    final navigationItems = ref
        .watch(currentNavigationItemsStateProvider)
        .value;
    final currentPageLabel = ref.watch(currentPageLabelProvider);
    final currentIndex = navigationState.currentIndex;
    final isMobile = navigationState.viewMode == ViewMode.mobile;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sideWidthProvider.notifier).value = isMobile
          ? 0
          : desktopSidebarWidth;
      final containsCurrentPage = navigationItems.any(
        (item) => item.label == currentPageLabel,
      );
      if (!containsCurrentPage) {
        appController.toPage(PageLabel.dashboard);
      }
    });
    final pageView = _HomePageView(
      key: ValueKey(
        'home-${navigationState.viewMode.name}-${navigationItems.length}',
      ),
      navigationItems: navigationItems,
      pageBuilder: (_, index) {
        final navigationItem = navigationItems[index];
        final navigationView = navigationItem.builder(context);
        return KeepScope(
          keep: navigationItem.keep,
          child: isMobile
              ? navigationView
              : Navigator(
                  pages: [MaterialPage(child: navigationView)],
                  onDidRemovePage: (_) {},
                ),
        );
      },
    );
    return HomeBackScopeContainer(
      child: Material(
        color: _shellBackground,
        child: isMobile
            ? _MobileShell(
                currentIndex: currentIndex,
                navigationItems: navigationItems,
                child: pageView,
              )
            : _DesktopShell(
                currentIndex: currentIndex,
                navigationItems: navigationItems,
                child: pageView,
              ),
      ),
    );
  }
}

class _MobileShell extends ConsumerWidget {
  final Widget child;
  final int currentIndex;
  final List<NavigationItem> navigationItems;

  const _MobileShell({
    required this.child,
    required this.currentIndex,
    required this.navigationItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemUiOverlayStyle = ref.read(systemUiOverlayStyleStateProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle.copyWith(
        systemNavigationBarColor: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(child: child),
          SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                border: Border(top: BorderSide(color: v2BoardLine)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x120D1B3D),
                    blurRadius: 20,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  for (var index = 0; index < navigationItems.length; index++)
                    Expanded(
                      child: _MobileNavItem(
                        item: navigationItems[index],
                        selected: index == currentIndex,
                        onTap: () {
                          appController.toPage(navigationItems[index].label);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopShell extends ConsumerWidget {
  final Widget child;
  final int currentIndex;
  final List<NavigationItem> navigationItems;

  const _DesktopShell({
    required this.child,
    required this.currentIndex,
    required this.navigationItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appName = ref.watch(appDisplayNameProvider);
    final email = ref.watch(v2boardSettingProvider)?.email;
    return SafeArea(
      child: Row(
        children: [
          Container(
            width: desktopSidebarWidth,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 24, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const V2BoardLogo(size: 34, showText: false),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Client',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: v2BoardMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: navigationItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      return _DesktopNavItem(
                        key: ValueKey(navigationItems[index].label),
                        item: navigationItems[index],
                        selected: index == currentIndex,
                        onTap: () {
                          appController.toPage(navigationItems[index].label);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => appController.toPage(PageLabel.profile),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: v2BoardSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: v2BoardGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '用户中心',
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email?.isNotEmpty == true ? email! : '管理您的账户',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: v2BoardMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(color: _shellBackground, child: child),
          ),
        ],
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  String get label => switch (item.label) {
    PageLabel.dashboard => '仪表盘',
    PageLabel.subscription => '套餐 / 订阅',
    PageLabel.profile => '用户中心',
    _ => item.label.name,
  };

  @override
  Widget build(BuildContext context) {
    const activeColor = v2BoardPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? v2BoardSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme(
                data: IconThemeData(
                  color: selected ? activeColor : v2BoardMuted,
                  size: 23,
                ),
                child: item.icon,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: selected ? activeColor : v2BoardMuted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopNavItem extends StatelessWidget {
  final NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  const _DesktopNavItem({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  String get label => switch (item.label) {
    PageLabel.dashboard => '仪表盘',
    PageLabel.subscription => '套餐 / 订阅',
    PageLabel.profile => '用户中心',
    _ => item.label.name,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? v2BoardSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconTheme(
                data: IconThemeData(
                  color: selected ? v2BoardPrimary : v2BoardMuted,
                  size: 20,
                ),
                child: item.icon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: selected ? v2BoardPrimary : v2BoardInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomePageView extends ConsumerStatefulWidget {
  final IndexedWidgetBuilder pageBuilder;
  final List<NavigationItem> navigationItems;

  const _HomePageView({
    super.key,
    required this.pageBuilder,
    required this.navigationItems,
  });

  @override
  ConsumerState createState() => _HomePageViewState();
}

class _HomePageViewState extends ConsumerState<_HomePageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    ref.listenManual(currentPageLabelProvider, (prev, next) {
      if (prev != next) {
        _toPage(next);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _HomePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationItems.length != widget.navigationItems.length) {
      _updatePageController();
    }
  }

  int get _pageIndex {
    final pageLabel = ref.read(currentPageLabelProvider);
    return widget.navigationItems.indexWhere((item) => item.label == pageLabel);
  }

  Future<void> _toPage(
    PageLabel pageLabel, [
    bool ignoreAnimateTo = false,
  ]) async {
    if (!mounted) {
      return;
    }
    final index = widget.navigationItems.indexWhere(
      (item) => item.label == pageLabel,
    );
    if (index == -1) {
      return;
    }
    final isAnimateToPage = ref.read(appSettingProvider).isAnimateToPage;
    final isMobile = ref.read(isMobileViewProvider);
    if (isAnimateToPage && isMobile && !ignoreAnimateTo) {
      await _pageController.animateToPage(
        index,
        duration: kTabScrollDuration,
        curve: Curves.easeOut,
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }

  void _updatePageController() {
    final pageLabel = ref.read(currentPageLabelProvider);
    _toPage(pageLabel, true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = ref.watch(
      currentNavigationItemsStateProvider.select((state) => state.value.length),
    );
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return widget.pageBuilder(context, index);
      },
    );
  }
}

class HomeBackScopeContainer extends ConsumerWidget {
  final Widget child;

  const HomeBackScopeContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context, ref) {
    return CommonPopScope(
      onPop: (context) async {
        final pageLabel = ref.read(currentPageLabelProvider);
        final realContext =
            GlobalObjectKey(pageLabel).currentContext ?? context;
        final canPop = Navigator.canPop(realContext);
        if (canPop) {
          Navigator.of(realContext).pop();
        } else {
          await appController.handleBackOrExit();
        }
        return false;
      },
      child: child,
    );
  }
}
