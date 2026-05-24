import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventsync_mobile/features/notifications/presentation/providers/notification_provider.dart';

/// Bottom navigation shell that wraps all main tabs.
class AppScaffold extends ConsumerWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  static const _tabs = [
    _TabItem(icon: Icons.dashboard_rounded, label: 'Home', path: '/'),
    _TabItem(icon: Icons.checklist_rounded, label: 'Tugas', path: '/tasks'),
    _TabItem(icon: Icons.event_rounded, label: 'Event', path: '/events'),
    _TabItem(
        icon: Icons.notifications_rounded,
        label: 'Notifikasi',
        path: '/notifications'),
    _TabItem(icon: Icons.person_rounded, label: 'Profil', path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);
    final unreadCount = ref.watch(notificationNotifierProvider.select((state) => state.unreadCount));

    return Scaffold(
      extendBody: true, // Needed for floating nav bar
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A), // Dark pill
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  if (index != currentIndex) {
                    context.go(_tabs[index].path);
                  }
                },
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.white.withAlpha(20),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                destinations: _tabs.map((tab) {
                  final isNotifTab = tab.path == '/notifications';
                  
                  Widget icon = Icon(tab.icon, color: Colors.white70);
                  Widget selectedIcon = Icon(tab.icon, color: Colors.white);
                  
                  if (isNotifTab && unreadCount > 0) {
                    icon = Badge(
                      label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
                      child: icon,
                    );
                    selectedIcon = Badge(
                      label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
                      child: selectedIcon,
                    );
                  }

                  return NavigationDestination(
                    icon: icon,
                    selectedIcon: selectedIcon,
                    label: tab.label,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final String path;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}
