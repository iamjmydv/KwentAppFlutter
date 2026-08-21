import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/data/models/comment.dart';
import 'package:kwentappflutter/data/repositories/comment_repository.dart';
import 'package:kwentappflutter/ui/post_detail/comment_thread_state.dart';

class CommentThreadViewModel extends ChangeNotifier {
  CommentThreadViewModel(this._repository, this._postId) {
    load();
  }

  final CommentRepository _repository;
  final String _postId;

  CommentThreadState _state = const CommentThreadInitial();
  var _isBusy = false;

  CommentThreadState get state => _state;

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
