import 'dart:typed_data';

import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/core/resources/constants.dart';
import 'package:kwentappflutter/core/resources/keys.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/data/models/page_result.dart';
import 'package:kwentappflutter/data/models/post.dart';
import 'package:kwentappflutter/data/models/post_image.dart';
import 'package:kwentappflutter/data/repositories/post_repository.dart';
import 'package:kwentappflutter/data/repositories/supabase/failure_mapper.dart';
import 'package:kwentappflutter/data/services/auth_service.dart';
import 'package:kwentappflutter/data/services/database_service.dart';
import 'package:kwentappflutter/data/services/storage_service.dart';

class SupabasePostRepository implements PostRepository {
  SupabasePostRepository(this._database, this._storage, this._auth);

  final DatabaseService _database;
  final StorageService _storage;
  final AuthService _auth;

  @override
  Future<PageResult<Post>> fetchPage({required int page}) {
    return guard(() async {
      final from = page * Constants.pageSize;
      final to = from + Constants.pageSize;

      final rows = await _database.fetchPostsPage(from: from, to: to);
      final hasMore = rows.length > Constants.pageSize;
      final visible =
          hasMore ? rows.sublist(0, Constants.pageSize) : rows;

      return PageResult<Post>(
        items: visible.map(_toPost).toList(),
        hasMore: hasMore,
      );
    });
  }

  @override
  Future<Post> fetchPost(String id) {
    return guard(() async => _toPost(await _database.fetchPost(id)));
  }

  @override
  Future<Post> createPost({
    required String title,
    required String body,
    required List<Uint8List> newImages,
  }) {
    return guard(() async {
      final userId = _requireUserId();

      final inserted = await _database.insertPost(
        userId: userId,
        title: title,
        body: body,
      );
      final postId = inserted[Keys.id] as String;

      try {
        final paths = await _uploadAll(userId, newImages);
        await _database.insertPostImages([
          for (var i = 0; i < paths.length; i++)
            {
              Keys.postId: postId,
              Keys.storagePath: paths[i],
              Keys.position: i,
            },
        ]);
      } catch (_) {
        await _discardPost(postId);
        rethrow;
      }

      return _toPost(await _database.fetchPost(postId));
    });
  }

  @override
  Future<Post> updatePost({
    required String id,
    required String title,
    required String body,
    required List<String> keptImageIds,
    required List<Uint8List> newImages,
  }) {
    return guard(() async {
      final userId = _requireUserId();

      await _database.updatePost(id: id, title: title, body: body);

      final existing = await _database.fetchPostImages(id);
      final removed = existing
          .where((row) => !keptImageIds.contains(row[Keys.id] as String))
          .toList();

      await _database.deletePostImages(
        removed.map((row) => row[Keys.id] as String).toList(),
      );

      final nextPosition = _nextPositionAfter(existing);

      final paths = await _uploadAll(userId, newImages);
      await _database.insertPostImages([
        for (var i = 0; i < paths.length; i++)
          {
            Keys.postId: id,
            Keys.storagePath: paths[i],
            Keys.position: nextPosition + i,
          },
      ]);

      await _storage.remove(
        bucket: Keys.postImagesBucket,
        paths: removed.map((row) => row[Keys.storagePath] as String).toList(),
      );

      return _toPost(await _database.fetchPost(id));
    });
  }

  @override
  Future<void> deletePost(String id) {
    return guard(() async {
      final images = await _database.fetchPostImages(id);
      final paths =
          images.map((row) => row[Keys.storagePath] as String).toList();

      await _database.deletePost(id);
      await _storage.remove(bucket: Keys.postImagesBucket, paths: paths);
    });
  }

  Future<List<String>> _uploadAll(String userId, List<Uint8List> images) async {
    final paths = <String>[];

    try {
      for (final bytes in images) {
        paths.add(
          await _storage.upload(
            bucket: Keys.postImagesBucket,
            ownerId: userId,
            bytes: bytes,
          ),
        );
      }
    } catch (_) {
      await _storage.remove(bucket: Keys.postImagesBucket, paths: paths);
      rethrow;
    }

    return paths;
  }

  Future<void> _discardPost(String id) async {
    try {
      await _database.deletePost(id);
    } catch (_) {
      return;
    }
  }

  static int _nextPositionAfter(List<Map<String, dynamic>> rows) {
    var next = 0;

    for (final row in rows) {
      final position = row[Keys.position] as int? ?? 0;
      if (position >= next) next = position + 1;
    }

    return next;
  }

  String _requireUserId() {
    final id = _auth.currentUser?.id;
    if (id == null) throw const ServerFailure(Strings.signInRequired);
    return id;
  }

  Post _toPost(Map<String, dynamic> row) {
    final post = Post.fromMap(row[Keys.id] as String, row);

    return post.copyWith(
      author: post.author.copyWith(
        avatarUrl: _avatarUrl(post.author.avatarUrl),
      ),
      images: post.images.map(_withPublicUrl).toList(),
    );
  }

  PostImage _withPublicUrl(PostImage image) {
    return image.withUrl(
      _storage.publicUrl(
        bucket: Keys.postImagesBucket,
        path: image.storagePath,
      ),
    );
  }

  String? _avatarUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return _storage.publicUrl(bucket: Keys.avatarsBucket, path: path);
  }
}
