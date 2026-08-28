import 'dart:typed_data';

import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/core/resources/keys.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/data/models/comment.dart';
import 'package:kwentappflutter/data/models/comment_image.dart';
import 'package:kwentappflutter/data/repositories/comment_repository.dart';
import 'package:kwentappflutter/data/repositories/supabase/failure_mapper.dart';
import 'package:kwentappflutter/data/services/auth_service.dart';
import 'package:kwentappflutter/data/services/database_service.dart';
import 'package:kwentappflutter/data/services/storage_service.dart';

class SupabaseCommentRepositoryImpl implements CommentRepository {
  SupabaseCommentRepositoryImpl(this._database, this._storage, this._auth);

  final DatabaseService _database;
  final StorageService _storage;
  final AuthService _auth;

  @override
  Future<List<Comment>> fetchComments(String postId) {
    return guard(() async {
      final rows = await _database.fetchComments(postId);
      return rows.map(_toComment).toList();
    });
  }

  @override
  Future<Comment> addComment({
    required String postId,
    required String body,
    required List<Uint8List> newImages,
  }) {
    return guard(() async {
      final userId = _requireUserId();

      final inserted = await _database.insertComment(
        postId: postId,
        userId: userId,
        body: body,
      );
      final commentId = inserted[Keys.id] as String;

      try {
        final paths = await _uploadAll(userId, newImages);
        await _database.insertCommentImages([
          for (var i = 0; i < paths.length; i++)
            {
              Keys.commentId: commentId,
              Keys.storagePath: paths[i],
              Keys.position: i,
            },
        ]);
      } catch (_) {
        await _discardComment(commentId);
        rethrow;
      }

      return _toComment(await _database.fetchComment(commentId));
    });
  }

  @override
  Future<Comment> updateComment({
    required String id,
    required String body,
    required List<String> keptImageIds,
    required List<Uint8List> newImages,
  }) {
    return guard(() async {
      final userId = _requireUserId();

      await _database.updateComment(id: id, body: body);

      final existing = await _database.fetchCommentImages(id);
      final removed = existing
          .where((row) => !keptImageIds.contains(row[Keys.id] as String))
          .toList();

      await _database.deleteCommentImages(
        removed.map((row) => row[Keys.id] as String).toList(),
      );

      final nextPosition = _nextPositionAfter(existing);

      final paths = await _uploadAll(userId, newImages);
      await _database.insertCommentImages([
        for (var i = 0; i < paths.length; i++)
          {
            Keys.commentId: id,
            Keys.storagePath: paths[i],
            Keys.position: nextPosition + i,
          },
      ]);

      await _storage.remove(
        bucket: Keys.commentImagesBucket,
        paths: removed.map((row) => row[Keys.storagePath] as String).toList(),
      );

      return _toComment(await _database.fetchComment(id));
    });
  }

  @override
  Future<void> deleteComment(String id) {
    return guard(() async {
      final images = await _database.fetchCommentImages(id);
      final paths =
          images.map((row) => row[Keys.storagePath] as String).toList();

      await _database.deleteComment(id);
      await _storage.remove(bucket: Keys.commentImagesBucket, paths: paths);
    });
  }

  Future<List<String>> _uploadAll(String userId, List<Uint8List> images) async {
    final paths = <String>[];

    try {
      for (final bytes in images) {
        paths.add(
          await _storage.upload(
            bucket: Keys.commentImagesBucket,
            ownerId: userId,
            bytes: bytes,
          ),
        );
      }
    } catch (_) {
      await _storage.remove(bucket: Keys.commentImagesBucket, paths: paths);
      rethrow;
    }

    return paths;
  }

  Future<void> _discardComment(String id) async {
    try {
      await _database.deleteComment(id);
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

  Comment _toComment(Map<String, dynamic> row) {
    final comment = Comment.fromMap(row[Keys.id] as String, row);

    return comment.copyWith(
      author: comment.author.copyWith(
        avatarUrl: _avatarUrl(comment.author.avatarUrl),
      ),
      images: comment.images.map(_withPublicUrl).toList(),
    );
  }

  CommentImage _withPublicUrl(CommentImage image) {
    return image.withUrl(
      _storage.publicUrl(
        bucket: Keys.commentImagesBucket,
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
