import 'package:kwentappflutter/data/models/post.dart';

sealed class FeedState {
  const FeedState();
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedLoaded extends FeedState {
  const FeedLoaded({
    required this.posts,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Post> posts;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  bool get isEmpty => posts.isEmpty;

  FeedLoaded copyWith({
    List<Post>? posts,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return FeedLoaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

class FeedError extends FeedState {
  const FeedError(this.message);

  final String message;
}
