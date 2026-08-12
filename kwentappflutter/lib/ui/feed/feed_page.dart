import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/router/app_routes.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PlaceholderPage(
      icon: Icons.article_outlined,
      title: Strings.emptyFeed,
      arrivesOn: 'The paginated feed arrives on Day 5.',
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          Strings.appName,
          style: theme.textTheme.titleLarge
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.login),
            child: const Text(Strings.signIn),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.postNew),
        tooltip: Strings.writeAction,
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }
}
