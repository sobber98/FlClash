import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/views.dart';
import 'package:flutter/material.dart';

class Navigation {
  static Navigation? _instance;

  List<NavigationItem> getItems({
    bool openLogs = false,
    bool hasProxies = false,
  }) {
    return [
      NavigationItem(
        keep: false,
        icon: Icon(Icons.space_dashboard),
        label: PageLabel.dashboard,
        builder: (_) =>
            const DashboardView(key: GlobalObjectKey(PageLabel.dashboard)),
      ),
      NavigationItem(
        icon: const Icon(Icons.lan_outlined),
        label: PageLabel.proxies,
        builder: (_) =>
            const ProxiesView(key: GlobalObjectKey(PageLabel.proxies)),
        modes: const [NavigationItemMode.mobile, NavigationItemMode.desktop],
      ),
      NavigationItem(
        icon: const Icon(Icons.construction_outlined),
        label: PageLabel.tools,
        builder: (_) => const ToolsView(key: GlobalObjectKey(PageLabel.tools)),
        modes: const [NavigationItemMode.mobile, NavigationItemMode.desktop],
      ),
      NavigationItem(
        icon: const Icon(Icons.shopping_cart_outlined),
        label: PageLabel.subscription,
        builder: (_) => const SubscriptionView(
          key: GlobalObjectKey(PageLabel.subscription),
        ),
        modes: const [NavigationItemMode.mobile, NavigationItemMode.desktop],
      ),
      NavigationItem(
        icon: const Icon(Icons.person_outline),
        label: PageLabel.profile,
        builder: (_) =>
            const ProfileView(key: GlobalObjectKey(PageLabel.profile)),
        modes: const [NavigationItemMode.mobile, NavigationItemMode.desktop],
      ),
      NavigationItem(
        icon: const Icon(Icons.folder_outlined),
        label: PageLabel.profiles,
        builder: (_) =>
            const ProfilesView(key: GlobalObjectKey(PageLabel.profiles)),
        modes: const [NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(Icons.view_timeline),
        label: PageLabel.requests,
        builder: (_) =>
            const RequestsView(key: GlobalObjectKey(PageLabel.requests)),
        description: 'requestsDesc',
        modes: const [NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(Icons.ballot_outlined),
        label: PageLabel.connections,
        builder: (_) =>
            const ConnectionsView(key: GlobalObjectKey(PageLabel.connections)),
        description: 'connectionsDesc',
        modes: const [NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(Icons.storage_outlined),
        label: PageLabel.resources,
        description: 'resourcesDesc',
        builder: (_) =>
            const ResourcesView(key: GlobalObjectKey(PageLabel.resources)),
        modes: const [NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(Icons.adb_outlined),
        label: PageLabel.logs,
        builder: (_) => const LogsView(key: GlobalObjectKey(PageLabel.logs)),
        description: 'logsDesc',
        modes: openLogs ? const [NavigationItemMode.more] : const [],
      ),
    ];
  }

  Navigation._internal();

  factory Navigation() {
    _instance ??= Navigation._internal();
    return _instance!;
  }
}

final navigation = Navigation();
