import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/router/app_routes.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:kwentappflutter/data/models/post.dart';
import 'package:kwentappflutter/ui/auth/auth_viewmodel.dart';
import 'package:kwentappflutter/ui/feed/feed_state.dart';
import 'package:kwentappflutter/ui/feed/feed_viewmodel.dart';
import 'package:kwentappflutter/ui/feed/widgets/post_card.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final threshold = position.maxScrollExtent * 0.8;

    if (position.pixels >= threshold) {
      context.read<FeedViewModel>().loadMore();
    }
  }

  Future<void> _refresh() async {
    final message = await context.read<FeedViewModel>().refresh();
    if (!mounted || message == null) return;
    CommonSnackbar.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<FeedViewModel>().state;
    final isSignedIn = context.watch<AuthViewModel>().isSignedIn;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          Strings.appName,
          style: theme.textTheme.titleLarge
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        actions: [
          if (!isSignedIn)
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
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
      body: switch (state) {
        FeedInitial() || FeedLoading() => const CommonLoader(),
        FeedError(:final message) => _FeedMessage(
            icon: Icons.cloud_off_outlined,
            title: Strings.feedLoadFailed,
            detail: message,
            actionLabel: Strings.retry,
            onAction: context.read<FeedViewModel>().load,
          ),
        FeedLoaded(isEmpty: true) => RefreshIndicator(
            onRefresh: _refresh,
            child: _FeedMessage(
              icon: Icons.article_outlined,
              title: Strings.emptyFeed,
              detail: Strings.emptyFeedHint,
              scrollable: true,
            ),
          ),
        FeedLoaded() => RefreshIndicator(
            onRefresh: _refresh,
            child: _FeedList(
              state: state,
              controller: _scrollController,
              onRetryMore: context.read<FeedViewModel>().loadMore,
            ),
          ),
      },
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList({
    required this.state,
    required this.controller,
    required this.onRetryMore,
  });

  final FeedLoaded state;
  final ScrollController controller;
  final VoidCallback onRetryMore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppLayout.contentMaxWidth,
        ),
        child: ListView.separated(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl * 3,
          ),
          itemCount: state.posts.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            if (index == state.posts.length) {
              return _FeedFooter(state: state, onRetryMore: onRetryMore);
            }

            final Post post = state.posts[index];
            return PostCard(
              post: post,
              onTap: () => context.push(AppRoutes.detailOf(post.id)),
            );
          },
        ),
      ),
    );
  }
}

class _FeedFooter extends StatelessWidget {
  const _FeedFooter({required this.state, required this.onRetryMore});

  final FeedLoaded state;
  final VoidCallback onRetryMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.loadMoreFailed) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Column(
          children: [
            Text(Strings.couldNotLoadMore, style: theme.textTheme.bodySmall),
            TextButton(
              onPressed: onRetryMore,
              child: const Text(Strings.retry),
            ),
          ],
        ),
      );
    }

    if (state.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Column(
          children: [
            const CommonLoader(size: 20),
            const SizedBox(height: AppSpacing.sm),
            Text(Strings.loadingMore, style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    if (state.hasMore) return const SizedBox(height: AppSpacing.xl);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Text(
        Strings.endOfFeed,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

class _FeedMessage extends StatelessWidget {
  const _FeedMessage({
    required this.icon,
    required this.title,
    required this.detail,
    this.actionLabel,
    this.onAction,
    this.scrollable = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );

    if (!scrollable) return Center(child: content);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: content),
        ),
      ),
    );
  }
}
