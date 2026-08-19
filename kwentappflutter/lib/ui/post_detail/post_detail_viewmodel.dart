import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/data/repositories/post_repository.dart';
import 'package:kwentappflutter/ui/post_detail/post_detail_state.dart';

class PostDetailViewModel extends ChangeNotifier {
  PostDetailViewModel(this._repository, this._postId) {
    load();
  }

  final PostRepository _repository;
  final String _postId;

  PostDetailState _state = const PostDetailInitial();
  var _isBusy = false;

  PostDetailState get state => _state;

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
