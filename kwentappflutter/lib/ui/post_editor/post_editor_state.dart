import 'package:kwentappflutter/data/models/post.dart';

sealed class PostEditorState {
  const PostEditorState();
}

class PostEditorLoading extends PostEditorState {
  const PostEditorLoading();
}

class PostEditorReady extends PostEditorState {
  const PostEditorReady({
    this.post,
    this.isSaving = false,
    this.isDeleting = false,
  });

  final Post? post;
  final bool isSaving;
  final bool isDeleting;

  bool get isBusy => isSaving || isDeleting;

  PostEditorReady copyWith({bool? isSaving, bool? isDeleting}) {
    return PostEditorReady(
      post: post,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

class PostEditorLoadError extends PostEditorState {
  const PostEditorLoadError(this.message);

  final String message;
}

sealed class EditorOutcome {
  const EditorOutcome();
}

class EditorSucceeded extends EditorOutcome {
  const EditorSucceeded(this.postId);

  final String postId;
}

class EditorFailed extends EditorOutcome {
  const EditorFailed(this.message);

  final String message;
}
