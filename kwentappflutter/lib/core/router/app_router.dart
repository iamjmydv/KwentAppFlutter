import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kwentappflutter/core/router/app_routes.dart';
import 'package:kwentappflutter/core/events/app_events.dart';
import 'package:kwentappflutter/core/router/app_shell.dart';
import 'package:kwentappflutter/data/repositories/comment_repository.dart';
import 'package:kwentappflutter/data/repositories/post_repository.dart';
import 'package:kwentappflutter/data/repositories/profile_repository.dart';
import 'package:kwentappflutter/ui/auth/auth_viewmodel.dart';
import 'package:kwentappflutter/ui/auth/login/login_page.dart';
import 'package:kwentappflutter/ui/auth/register/register_page.dart';
import 'package:kwentappflutter/ui/connection_check/connection_check_page.dart';
import 'package:kwentappflutter/ui/feed/feed_page.dart';
import 'package:kwentappflutter/ui/feed/feed_viewmodel.dart';
import 'package:kwentappflutter/ui/post_detail/comment_thread_viewmodel.dart';
import 'package:kwentappflutter/ui/post_detail/post_detail_page.dart';
import 'package:kwentappflutter/ui/post_detail/post_detail_viewmodel.dart';
import 'package:kwentappflutter/ui/post_editor/post_editor_page.dart';
import 'package:kwentappflutter/ui/post_editor/post_editor_viewmodel.dart';
import 'package:kwentappflutter/ui/profile/profile_page.dart';
import 'package:kwentappflutter/ui/profile/profile_viewmodel.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthViewModel auth) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.feed,
    refreshListenable: auth,
    redirect: (context, state) => _guard(auth, state),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.feed,
                builder: (context, state) => ChangeNotifierProvider(
                  create: (context) => FeedViewModel(
                    context.read<PostRepository>(),
                    context.read<AppEventBus>(),
                  ),
                  child: const FeedPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) {
                  final userId = auth.user?.id;
                  if (userId == null) return const SizedBox.shrink();

                  return ChangeNotifierProvider(
                    key: ValueKey(userId),
                    create: (context) => ProfileViewModel(
                      context.read<ProfileRepository>(),
                      context.read<AppEventBus>(),
                      userId,
                    ),
                    child: const ProfilePage(),
                  );
                },
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
        path: AppRoutes.connectionCheck,
        builder: (context, state) => const ConnectionCheckPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.postNew,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => PostEditorViewModel(
            context.read<PostRepository>(),
            context.read<AppEventBus>(),
          ),
          child: const PostEditorPage(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.postEdit,
        builder: (context, state) {
          final id = state.pathParameters['id']!;

          return ChangeNotifierProvider(
            create: (context) => PostEditorViewModel(
              context.read<PostRepository>(),
              context.read<AppEventBus>(),
              postId: id,
            ),
            child: PostEditorPage(postId: id),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.postDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => PostDetailViewModel(
                  context.read<PostRepository>(),
                  context.read<AppEventBus>(),
                  id,
                ),
              ),
              ChangeNotifierProvider(
                create: (context) => CommentThreadViewModel(
                  context.read<CommentRepository>(),
                  context.read<AppEventBus>(),
                  id,
                ),
              ),
            ],
            child: PostDetailPage(postId: id),
          );
        },
      ),
    ],
  );
}

String? _guard(AuthViewModel auth, GoRouterState state) {
  final location = state.matchedLocation;
  final isPublic = AppRoutes.isPublic(location);

  if (!auth.isSignedIn && !isPublic) return AppRoutes.login;

  final onAuthScreen =
      location == AppRoutes.login || location == AppRoutes.register;
  if (auth.isSignedIn && onAuthScreen) return AppRoutes.feed;

  return null;
}
