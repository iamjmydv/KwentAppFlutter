import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/core/events/app_events.dart';
import 'package:kwentappflutter/data/repositories/post_repository.dart';
import 'package:kwentappflutter/ui/post_editor/post_editor_state.dart';

class PostEditorViewModel extends ChangeNotifier {
  PostEditorViewModel(this._repository, this._events, {this.postId}) {
    if (isEditing) {
      load();
    } else {
      _state = const PostEditorReady();
    }
  }

  final PostRepository _repository;
  final AppEventBus _events;
  final String? postId;

  PostEditorState _state = const PostEditorLoading();
  var _isBusy = false;

  PostEditorState get state => _state;
  bool get isEditing => postId != null;

  Future<void> load() async {
    if (!isEditing || _isBusy) return;
    _isBusy = true;
    _set(const PostEditorLoading());

    try {
      _set(PostEditorReady(post: await _repository.fetchPost(postId!)));
    } catch (error) {
      _set(PostEditorLoadError(failureMessage(error)));
    } finally {
      _isBusy = false;
    }
  }

  Future<EditorOutcome?> save({
    required String title,
    required String body,
    required List<String> keptImageIds,
    required List<Uint8List> newImages,
  }) async {
    final current = _state;
    if (current is! PostEditorReady || _isBusy) return null;

    _isBusy = true;
    _set(current.copyWith(isSaving: true));

    try {
      final post = isEditing
          ? await _repository.updatePost(
              id: postId!,
              title: title,
              body: body,
              keptImageIds: keptImageIds,
              newImages: newImages,
            )
          : await _repository.createPost(
              title: title,
              body: body,
              newImages: newImages,
            );

      _events.publish(isEditing ? PostUpdated(post) : PostCreated(post));
      return EditorSucceeded(post.id);
    } catch (error) {
      _set(current.copyWith(isSaving: false));
      return EditorFailed(failureMessage(error));
    } finally {
      _isBusy = false;
    }
  }

  Future<EditorOutcome?> delete() async {
    final current = _state;
    if (current is! PostEditorReady || !isEditing || _isBusy) return null;

    _isBusy = true;
    _set(current.copyWith(isDeleting: true));

    try {
      await _repository.deletePost(postId!);
      _events.publish(PostDeleted(postId!));
      return EditorSucceeded(postId!);
    } catch (error) {
      _set(current.copyWith(isDeleting: false));
      return EditorFailed(failureMessage(error));
    } finally {
      _isBusy = false;
    }
  }

  void _set(PostEditorState next) {
    _state = next;
    notifyListeners();
  }
}
