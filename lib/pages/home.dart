import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/window_manager.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/views/v2board/login_view.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _shellBackground = Color(0xFFF5F6F8);
const _sidebarWidth = 248.0;

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  Text(
                    appName,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const V2BoardLoginView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthenticatedHomePage extends ConsumerWidget {
  const _AuthenticatedHomePage();

  void _syncSideWidth(WidgetRef ref, double width) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sideWidthProvider.notifier).value = width;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);
    final navigationItems = ref.watch(currentNavigationItemsStateProvider).value;
    final currentIndex = navigationState.currentIndex;
    final isMobile = navigationState.viewMode == ViewMode.mobile;
    _syncSideWidth(ref, isMobile ? 0 : _sidebarWidth);
    final pageView = _HomePageView(
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
        systemNavigationBarColor: const Color(0xFFE8EEF7),
      ),
      child: Column(
        children: [
          Expanded(child: child),
          SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE8EEF7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
            width: _sidebarWidth,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AppIcon(),
                      ),
                    ),
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
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Enterprise Client',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                for (var index = 0; index < navigationItems.length; index++) ...[
                  _DesktopNavItem(
                    item: navigationItems[index],
                    selected: index == currentIndex,
                    onTap: () {
                      appController.toPage(navigationItems[index].label);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => appController.toPage(PageLabel.profile),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(14),
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
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email?.isNotEmpty == true ? email! : '管理您的账户',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF9CA3AF),
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
            child: Container(
              color: _shellBackground,
              child: child,
            ),
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
    PageLabel.subscription => '套餐商城',
    PageLabel.profile => '用户中心',
    _ => item.label.name,
  };

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF123E63);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDDE8F7) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(
                color: selected ? activeColor : const Color(0xFF4B5563),
                size: 24,
              ),
              child: item.icon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: selected ? activeColor : const Color(0xFF4B5563),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
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
    required this.item,
    required this.selected,
    required this.onTap,
  });

  String get label => switch (item.label) {
    PageLabel.dashboard => '仪表盘',
    PageLabel.subscription => '套餐商城',
    PageLabel.profile => '用户中心',
    _ => item.label.name,
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(
                color: selected ? Colors.white : const Color(0xFF6B7280),
                size: 20,
              ),
              child: item.icon,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: context.textTheme.titleSmall?.copyWith(
                color: selected ? Colors.white : const Color(0xFF4B5563),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePageView extends ConsumerStatefulWidget {
  final IndexedWidgetBuilder pageBuilder;
  final List<NavigationItem> navigationItems;

  const _HomePageView({
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

  Future<void> _toPage(PageLabel pageLabel, [bool ignoreAnimateTo = false]) async {
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
        final realContext = GlobalObjectKey(pageLabel).currentContext ?? context;
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
