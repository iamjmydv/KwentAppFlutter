import 'dart:typed_data';

import 'package:kwentappflutter/data/models/page_result.dart';
import 'package:kwentappflutter/data/models/post.dart';

abstract interface class PostRepository {
  Future<PageResult<Post>> fetchPage({required int page});

  Future<Post> fetchPost(String id);

  Future<Post> createPost({
    required String title,
    required String body,
    required List<Uint8List> newImages,
  });

  Future<Post> updatePost({
    required String id,
    required String title,
    required String body,
    required List<String> keptImageIds,
    required List<Uint8List> newImages,
  });

  Future<void> deletePost(String id);
}
