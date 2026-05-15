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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide =
                constraints.maxWidth >= 1040 && constraints.maxHeight >= 700;
            if (isWide) {
              return Container(
                key: const ValueKey('startup-login-shell'),
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      flex: 38,
                      child: V2BoardAuthHeroPanel(appName: appName),
                    ),
                    Expanded(
                      flex: 62,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 54,
                          vertical: 44,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: V2BoardLoginView(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final canUseStaticCard =
                constraints.maxWidth >= 520 && constraints.maxHeight >= 560;
            final cardPadding = canUseStaticCard
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 18)
                : const EdgeInsets.symmetric(horizontal: 20, vertical: 24);
            final card = Container(
              key: const ValueKey('startup-login-shell'),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: v2BoardLine),
                boxShadow: v2BoardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(18, 20, 18, 24),
                child: V2BoardLoginView(),
              ),
            );
            if (canUseStaticCard) {
              return Padding(
                padding: cardPadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 680,
                      maxHeight: constraints.maxHeight - cardPadding.vertical,
                    ),
                    child: card,
                  ),
                ),
              );
            }
            return Center(
              child: SingleChildScrollView(padding: cardPadding, child: card),
            );
          },
        ),
      ),
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
