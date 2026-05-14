import 'package:v2box/enum/enum.dart';
import 'package:v2box/models/models.dart';
import 'package:v2box/views/dashboard/dashboard.dart';
import 'package:v2box/views/profile/profile_view.dart';
import 'package:v2box/views/subscription/subscription_view.dart';
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
        icon: const Icon(Icons.home_filled),
        label: PageLabel.dashboard,
        builder: (_) =>
            const DashboardView(key: GlobalObjectKey(PageLabel.dashboard)),
      ),
      NavigationItem(
        icon: const Icon(Icons.shopping_bag_rounded),
        label: PageLabel.subscription,
        builder: (_) => const SubscriptionView(
          key: GlobalObjectKey(PageLabel.subscription),
        ),
        modes: const [NavigationItemMode.mobile, NavigationItemMode.desktop],
      ),
      NavigationItem(
        icon: const Icon(Icons.person_rounded),
        label: PageLabel.profile,
        builder: (_) =>
            const ProfileView(key: GlobalObjectKey(PageLabel.profile)),
        modes: const [NavigationItemMode.mobile, NavigationItemMode.desktop],
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
