import 'package:kwentappflutter/data/models/post.dart';

sealed class PostDetailState {
  const PostDetailState();
}

class PostDetailInitial extends PostDetailState {
  const PostDetailInitial();
}

class PostDetailLoading extends PostDetailState {
  const PostDetailLoading();
}

class PostDetailLoaded extends PostDetailState {
  const PostDetailLoaded(this.post);

  final Post post;
}

class PostDetailError extends PostDetailState {
  const PostDetailError(this.message);

  final String message;
}
