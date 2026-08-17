import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/data/repositories/post_repository.dart';
import 'package:kwentappflutter/ui/feed/feed_state.dart';

class FeedViewModel extends ChangeNotifier {
  FeedViewModel(this._repository) {
    load();
  }

  final PostRepository _repository;

  FeedState _state = const FeedInitial();
  var _page = 0;
  var _isBusy = false;

  FeedState get state => _state;

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
