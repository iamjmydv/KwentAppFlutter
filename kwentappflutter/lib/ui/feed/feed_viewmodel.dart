import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/core/events/app_events.dart';
import 'package:kwentappflutter/data/models/post.dart';
import 'package:kwentappflutter/data/repositories/post_repository.dart';
import 'package:kwentappflutter/ui/feed/feed_state.dart';

class FeedViewModel extends ChangeNotifier {
  FeedViewModel(this._repository, this._events) {
    _subscription = _events.events.listen(_onEvent);
    load();
  }

  final PostRepository _repository;
  final AppEventBus _events;
  late final StreamSubscription<DomainEvent> _subscription;

  FeedState _state = const FeedInitial();
  var _page = 0;
  var _isBusy = false;

  FeedState get state => _state;

  void _onEvent(DomainEvent event) {
    final current = _state;
    if (current is! FeedLoaded) return;

    switch (event) {
      case PostCreated(:final post):
        _set(current.copyWith(posts: [post, ...current.posts]));

      case PostUpdated(:final post):
        if (!current.posts.any((existing) => existing.id == post.id)) return;
        _set(
          current.copyWith(
            posts: [
              for (final Post existing in current.posts)
                if (existing.id == post.id) post else existing,
            ],
          ),
        );

      case PostDeleted(:final postId):
        if (!current.posts.any((existing) => existing.id == postId)) return;
        _set(
          current.copyWith(
            posts: [
              for (final Post existing in current.posts)
                if (existing.id != postId) existing,
            ],
          ),
        );

      case CommentCountChanged(:final postId, :final delta):
        if (!current.posts.any((existing) => existing.id == postId)) return;
        _set(
          current.copyWith(
            posts: [
              for (final Post existing in current.posts)
                if (existing.id == postId)
                  existing.copyWith(
                    commentCount: existing.commentCount + delta,
                  )
                else
                  existing,
            ],
          ),
        );

      case ProfileChanged(:final profile):
        if (!current.posts.any((post) => post.author.id == profile.id)) return;
        _set(
          current.copyWith(
            posts: [
              for (final Post existing in current.posts)
                if (existing.author.id == profile.id)
                  existing.copyWith(author: profile)
                else
                  existing,
            ],
          ),
        );
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> load() async {
    if (_isBusy) return;
    _isBusy = true;
    _set(const FeedLoading());

    try {
      final result = await _repository.fetchPage(page: 0);
      _page = 0;
      _set(FeedLoaded(posts: result.items, hasMore: result.hasMore));
    } catch (error) {
      _set(FeedError(failureMessage(error)));
    } finally {
      _isBusy = false;
    }
  }

  Future<String?> refresh() async {
    if (_isBusy) return null;
    _isBusy = true;

    try {
      final result = await _repository.fetchPage(page: 0);
      _page = 0;
      _set(FeedLoaded(posts: result.items, hasMore: result.hasMore));
      return null;
    } catch (error) {
      final message = failureMessage(error);
      if (_state is! FeedLoaded) _set(FeedError(message));
      return message;
    } finally {
      _isBusy = false;
    }
  }

  Future<void> loadMore() async {
    final current = _state;
    if (current is! FeedLoaded) return;
    if (!current.hasMore || current.isLoadingMore || _isBusy) return;

    _isBusy = true;
    _set(current.copyWith(isLoadingMore: true, loadMoreFailed: false));

    try {
      final result = await _repository.fetchPage(page: _page + 1);
      _page += 1;
      _set(
        FeedLoaded(
          posts: [...current.posts, ...result.items],
          hasMore: result.hasMore,
        ),
      );
    } catch (_) {
      _set(current.copyWith(isLoadingMore: false, loadMoreFailed: true));
    } finally {
      _isBusy = false;
    }
  }

  void _set(FeedState next) {
    _state = next;
    notifyListeners();
  }
}
