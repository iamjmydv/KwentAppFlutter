import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/router/app_routes.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:kwentappflutter/core/utils/time_ago.dart';
import 'package:kwentappflutter/data/models/comment.dart';
import 'package:kwentappflutter/data/models/post.dart';
import 'package:kwentappflutter/ui/auth/auth_viewmodel.dart';
import 'package:kwentappflutter/ui/post_detail/comment_thread_state.dart';
import 'package:kwentappflutter/ui/post_detail/comment_thread_viewmodel.dart';
import 'package:kwentappflutter/ui/post_detail/post_detail_state.dart';
import 'package:kwentappflutter/ui/post_detail/post_detail_viewmodel.dart';
import 'package:kwentappflutter/ui/post_detail/widgets/comment_composer.dart';
import 'package:kwentappflutter/ui/post_detail/widgets/comment_tile.dart';
import 'package:kwentappflutter/ui/post_detail/widgets/post_gallery.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<PostDetailViewModel>().state;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _leave(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          Strings.appName,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.primary),
        ),
      ),
      body: switch (state) {
        PostDetailInitial() || PostDetailLoading() => const CommonLoader(),
        PostDetailError(:final message) => _DetailMessage(
            title: Strings.kwentoLoadFailed,
            detail: message,
            onRetry: context.read<PostDetailViewModel>().load,
          ),
        PostDetailLoaded(:final post) => _DetailBody(post: post),
      },
    );
  }

  static void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.feed);
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl * 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  AuthorAvatar(profile: post.author),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      post.author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    timeAgo(post.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (post.images.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                PostGallery(images: post.images),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(post.body, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              Divider(color: theme.colorScheme.outline),
              const SizedBox(height: AppSpacing.md),
              const _CommentSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentSection extends StatelessWidget {
  const _CommentSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<CommentThreadViewModel>();
    final state = viewModel.state;
    final auth = context.watch<AuthViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          switch (state) {
            CommentThreadLoaded(:final count) => Strings.commentsHeading(count),
            _ => Strings.comments,
          },
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        if (auth.isSignedIn)
          CommentComposer(
            isSubmitting: state is CommentThreadLoaded && state.isSubmitting,
            onSubmit: (body, images) =>
                viewModel.addComment(body: body, images: images),
          )
        else
          const _SignInPrompt(),
        const SizedBox(height: AppSpacing.lg),
        switch (state) {
          CommentThreadInitial() || CommentThreadLoading() => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.lg),
              child: CommonLoader(size: 20),
            ),
          CommentThreadError(:final message) => _DetailMessage(
              title: Strings.commentsLoadFailed,
              detail: message,
              onRetry: viewModel.load,
            ),
          CommentThreadLoaded(isEmpty: true) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                Strings.emptyComments,
                style: theme.textTheme.bodySmall,
              ),
            ),
          CommentThreadLoaded(:final comments, :final busyCommentId) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final Comment comment in comments)
                  CommentTile(
                    key: ValueKey(comment.id),
                    comment: comment,
                    isOwn: auth.user?.id == comment.author.id,
                    isBusy: busyCommentId == comment.id,
                    onSave: (body, keptImageIds, newImages) =>
                        viewModel.updateComment(
                      id: comment.id,
                      body: body,
                      keptImageIds: keptImageIds,
                      newImages: newImages,
                    ),
                    onDelete: () => viewModel.deleteComment(comment.id),
                  ),
              ],
            ),
        },
      ],
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Strings.signInToComment, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(Strings.signInToCommentHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () => context.push(AppRoutes.login),
            child: const Text(Strings.signIn),
          ),
        ],
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({
    required this.title,
    required this.detail,
    required this.onRetry,
  });

  final String title;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(onPressed: onRetry, child: const Text(Strings.retry)),
        ],
      ),
    );
  }
}
