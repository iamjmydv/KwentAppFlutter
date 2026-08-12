import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentappflutter/core/router/app_routes.dart';
import 'package:kwentappflutter/core/router/app_shell.dart';
import 'package:kwentappflutter/ui/auth/login/login_page.dart';
import 'package:kwentappflutter/ui/auth/register/register_page.dart';
import 'package:kwentappflutter/ui/feed/feed_page.dart';
import 'package:kwentappflutter/ui/post_detail/post_detail_page.dart';
import 'package:kwentappflutter/ui/post_editor/post_editor_page.dart';
import 'package:kwentappflutter/ui/profile/profile_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.feed,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.feed,
                builder: (context, state) => const FeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.postNew,
        builder: (context, state) => const PostEditorPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.postEdit,
        builder: (context, state) =>
            PostEditorPage(postId: state.pathParameters['id']),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.postDetail,
        builder: (context, state) =>
            PostDetailPage(postId: state.pathParameters['id']!),
      ),
    ],
  );
}
