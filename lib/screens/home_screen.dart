import 'package:flutter/material.dart';
import 'package:mastodon/base/keys.dart';
import 'package:mastodon/base/routes.dart';
import 'package:mastodon/providers/home_provider.dart';
import 'package:mastodon/screens/my_profile_screen.dart';
import 'package:mastodon/screens/notifications_screen.dart';
import 'package:mastodon/screens/timeline_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _Sidebar(),
        Expanded(child: _MainContent()),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    return NavigationRail(
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: Text('Notifications'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
      onDestinationSelected: (value) {
        homeProvider.selectIndex(value);
      },
      selectedIndex: homeProvider.selectedIndex,
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    switch (homeProvider.selectedIndex) {
      case 0:
        return TimelineScreen();
      case 1:
        return NotificationsScreen();
      case 2:
        return MyProfileScreen();
      default:
        return Center(child: Text("Empty Screen"));
    }
  }
}
