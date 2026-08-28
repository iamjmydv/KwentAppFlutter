import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/core/events/app_events.dart';
import 'package:kwentappflutter/data/repositories/post_repository.dart';
import 'package:kwentappflutter/ui/post_detail/post_detail_state.dart';

class PostDetailViewModel extends ChangeNotifier {
  PostDetailViewModel(this._repository, this._events, this._postId) {
    _subscription = _events.events.listen(_onEvent);
    load();
  }

  final PostRepository _repository;
  final AppEventBus _events;
  final String _postId;
  late final StreamSubscription<DomainEvent> _subscription;

  PostDetailState _state = const PostDetailInitial();
  var _isBusy = false;

  PostDetailState get state => _state;

  void _onEvent(DomainEvent event) {
    final current = _state;
    if (current is! PostDetailLoaded) return;

    switch (event) {
      case PostUpdated(:final post):
        if (post.id != _postId) return;
        _set(PostDetailLoaded(post));

      case CommentCountChanged(:final postId, :final delta):
        if (postId != _postId) return;
        _set(
          PostDetailLoaded(
            current.post.copyWith(
              commentCount: current.post.commentCount + delta,
            ),
          ),
        );

      case ProfileChanged(:final profile):
        if (current.post.author.id != profile.id) return;
        _set(PostDetailLoaded(current.post.copyWith(author: profile)));

      case PostCreated():
      case PostDeleted():
        break;
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
    _set(const PostDetailLoading());

    try {
      _set(PostDetailLoaded(await _repository.fetchPost(_postId)));
    } catch (error) {
      _set(PostDetailError(failureMessage(error)));
    } finally {
      _isBusy = false;
    }
  }

  void _set(PostDetailState next) {
    _state = next;
    notifyListeners();
  }
}
