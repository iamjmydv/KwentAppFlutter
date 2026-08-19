import 'package:kwentappflutter/data/models/comment.dart';

sealed class CommentThreadState {
  const CommentThreadState();
}

class CommentThreadInitial extends CommentThreadState {
  const CommentThreadInitial();
}

class CommentThreadLoading extends CommentThreadState {
  const CommentThreadLoading();
}

class CommentThreadLoaded extends CommentThreadState {
  const CommentThreadLoaded({
    required this.comments,
    this.isSubmitting = false,
    this.busyCommentId,
  });

  final List<Comment> comments;
  final bool isSubmitting;
  final String? busyCommentId;

  int get count => comments.length;
  bool get isEmpty => comments.isEmpty;

  CommentThreadLoaded copyWith({
    List<Comment>? comments,
    bool? isSubmitting,
    String? busyCommentId,
    bool clearBusyComment = false,
  }) {
    return CommentThreadLoaded(
      comments: comments ?? this.comments,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      busyCommentId:
          clearBusyComment ? null : (busyCommentId ?? this.busyCommentId),
    );
  }
}

class CommentThreadError extends CommentThreadState {
  const CommentThreadError(this.message);

  final String message;
}
