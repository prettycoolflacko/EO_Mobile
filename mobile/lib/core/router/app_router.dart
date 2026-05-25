import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:eventsync_mobile/core/router/route_names.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:eventsync_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:eventsync_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:eventsync_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:eventsync_mobile/features/events/presentation/screens/event_list_screen.dart';
import 'package:eventsync_mobile/features/events/presentation/screens/event_detail_screen.dart';
import 'package:eventsync_mobile/features/tasks/presentation/screens/task_list_screen.dart';
import 'package:eventsync_mobile/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:eventsync_mobile/features/tasks/presentation/screens/task_form_screen.dart';
import 'package:eventsync_mobile/features/rundown/domain/entities/rundown.dart';
import 'package:eventsync_mobile/features/rundown/presentation/screens/rundown_screen.dart';
import 'package:eventsync_mobile/features/rundown/presentation/screens/rundown_form_screen.dart';
import 'package:eventsync_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:eventsync_mobile/features/notifications/presentation/screens/notification_screen.dart';
import 'package:eventsync_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:eventsync_mobile/features/vendors/presentation/screens/vendor_list_screen.dart';
import 'package:eventsync_mobile/features/vendors/presentation/screens/vendor_detail_screen.dart';
import 'package:eventsync_mobile/features/vendors/presentation/screens/vendor_form_screen.dart';
import 'package:eventsync_mobile/features/admin/presentation/screens/user_management_screen.dart';
import 'package:eventsync_mobile/features/events/presentation/screens/event_form_screen.dart';
import 'package:eventsync_mobile/shared/widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  // Use a ValueNotifier to bridge Riverpod and GoRouter's refreshListenable
  final authStateNotifier = ValueNotifier<AsyncValue<dynamic>>(const AsyncLoading());
  
  ref.listen(
    authStateProvider,
    (_, next) {
      authStateNotifier.value = next;
    },
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authStateNotifier,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app shell with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/tasks',
            name: RouteNames.tasks,
            builder: (context, state) => const TaskListScreen(),
          ),
          GoRoute(
            path: '/events',
            name: RouteNames.events,
            builder: (context, state) => const EventListScreen(),
          ),
          GoRoute(
            path: '/notifications',
            name: RouteNames.notifications,
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Detail routes (push on top of shell)
      GoRoute(
        path: '/events/:id',
        name: RouteNames.eventDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/tasks/:id',
        name: RouteNames.taskDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TaskDetailScreen(taskId: id);
        },
      ),
      GoRoute(
        path: '/events/:id/tasks',
        name: 'eventTasks',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TaskListScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/events/:id/tasks/new',
        name: 'newTask',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TaskFormScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/rundown/:eventId',
        name: RouteNames.rundown,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = int.parse(state.pathParameters['eventId']!);
          return RundownScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/rundown/:eventId/new',
        name: 'newRundown',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = int.parse(state.pathParameters['eventId']!);
          final rundown = state.extra as Rundown?;
          return RundownFormScreen(eventId: eventId, rundown: rundown);
        },
      ),
      GoRoute(
        path: '/vendors/:eventId',
        name: RouteNames.vendors,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = int.parse(state.pathParameters['eventId']!);
          return VendorListScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/vendors/detail/:id',
        name: RouteNames.vendorDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return VendorDetailScreen(vendorId: id);
        },
      ),
      GoRoute(
        path: '/vendors/:eventId/new',
        name: 'newVendor',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = int.parse(state.pathParameters['eventId']!);
          return VendorFormScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/chat/:eventId',
        name: RouteNames.chat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = int.parse(state.pathParameters['eventId']!);
          return ChatScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/admin/users',
        name: 'adminUsers',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/events/new',
        name: 'adminEventNew',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EventFormScreen(),
      ),
    ],
  );
});
