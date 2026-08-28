import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/core/events/app_events.dart';
import 'package:kwentappflutter/data/models/comment.dart';
import 'package:kwentappflutter/data/repositories/comment_repository.dart';
import 'package:kwentappflutter/ui/post_detail/comment_thread_state.dart';

class CommentThreadViewModel extends ChangeNotifier {
  CommentThreadViewModel(this._repository, this._events, this._postId) {
    _subscription = _events.events.listen(_onEvent);
    load();
  }

  final CommentRepository _repository;
  final AppEventBus _events;
  final String _postId;
  late final StreamSubscription<DomainEvent> _subscription;

  CommentThreadState _state = const CommentThreadInitial();
  var _isBusy = false;

  CommentThreadState get state => _state;

  void _onEvent(DomainEvent event) {
    final current = _state;
    if (current is! CommentThreadLoaded) return;

    switch (event) {
      case ProfileChanged(:final profile):
        final matches = current.comments.any(
          (comment) => comment.author.id == profile.id,
        );
        if (!matches) return;

        _set(
          current.copyWith(
            comments: [
              for (final Comment comment in current.comments)
                if (comment.author.id == profile.id)
                  comment.copyWith(author: profile)
                else
                  comment,
            ],
          ),
        );

      case PostCreated():
      case PostUpdated():
      case PostDeleted():
      case CommentCountChanged():
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
    _set(const CommentThreadLoading());

    try {
      final comments = await _repository.fetchComments(_postId);
      _set(CommentThreadLoaded(comments: comments));
    } catch (error) {
      _set(CommentThreadError(failureMessage(error)));
    } finally {
      _isBusy = false;
    }
  }

  Future<String?> addComment({
    required String body,
    required List<Uint8List> images,
  }) async {
    final current = _state;
    if (current is! CommentThreadLoaded || _isBusy) return null;

    _isBusy = true;
    _set(current.copyWith(isSubmitting: true));

    try {
      final comment = await _repository.addComment(
        postId: _postId,
        body: body,
        newImages: images,
      );

      _set(CommentThreadLoaded(comments: [...current.comments, comment]));
      _events.publish(CommentCountChanged(postId: _postId, delta: 1));
      return null;
    } catch (error) {
      _set(current.copyWith(isSubmitting: false));
      return failureMessage(error);
    } finally {
      _isBusy = false;
    }
  }

  Future<String?> updateComment({
    required String id,
    required String body,
    required List<String> keptImageIds,
    required List<Uint8List> newImages,
  }) async {
    final current = _state;
    if (current is! CommentThreadLoaded || _isBusy) return null;

    _isBusy = true;
    _set(current.copyWith(busyCommentId: id));

    try {
      final updated = await _repository.updateComment(
        id: id,
        body: body,
        keptImageIds: keptImageIds,
        newImages: newImages,
      );

      _set(
        CommentThreadLoaded(
          comments: [
            for (final Comment comment in current.comments)
              if (comment.id == id) updated else comment,
          ],
        ),
      );
      return null;
    } catch (error) {
      _set(current.copyWith(clearBusyComment: true));
      return failureMessage(error);
    } finally {
      _isBusy = false;
    }
  }

  Future<String?> deleteComment(String id) async {
    final current = _state;
    if (current is! CommentThreadLoaded || _isBusy) return null;

    _isBusy = true;
    _set(current.copyWith(busyCommentId: id));

    try {
      await _repository.deleteComment(id);

      _set(
        CommentThreadLoaded(
          comments: [
            for (final Comment comment in current.comments)
              if (comment.id != id) comment,
          ],
        ),
      );
      _events.publish(CommentCountChanged(postId: _postId, delta: -1));
      return null;
    } catch (error) {
      _set(current.copyWith(clearBusyComment: true));
      return failureMessage(error);
    } finally {
      _isBusy = false;
    }
  }

  void _set(CommentThreadState next) {
    _state = next;
    notifyListeners();
  }
}
