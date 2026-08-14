import 'dart:typed_data';

import 'package:kwentappflutter/data/models/comment.dart';

abstract interface class CommentRepository {
  Future<List<Comment>> fetchComments(String postId);

  Future<Comment> addComment({
    required String postId,
    required String body,
    required List<Uint8List> newImages,
  });

  Future<Comment> updateComment({
    required String id,
    required String body,
    required List<String> keptImageIds,
    required List<Uint8List> newImages,
  });

  Future<void> deleteComment(String id);
}
