import 'package:kwentappflutter/core/resources/keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  DatabaseService(this._client);

  final SupabaseClient _client;

  static const _postSelect =
      '*, ${Keys.profilesTable}(${Keys.name}, ${Keys.avatarUrl}), '
      '${Keys.postImagesTable}(${Keys.id}, ${Keys.storagePath}, ${Keys.position}), '
      '${Keys.commentsTable}(${Keys.count})';

  static const _commentSelect =
      '*, ${Keys.profilesTable}(${Keys.name}, ${Keys.avatarUrl}), '
      '${Keys.commentImagesTable}(${Keys.id}, ${Keys.storagePath}, ${Keys.position})';

  Future<List<Map<String, dynamic>>> fetchPostsPage({
    required int from,
    required int to,
  }) async {
    final rows = await _client
        .from(Keys.postsTable)
        .select(_postSelect)
        .order(Keys.createdAt, ascending: false)
        .range(from, to);

    return rows.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchPost(String id) async {
    return await _client
        .from(Keys.postsTable)
        .select(_postSelect)
        .eq(Keys.id, id)
        .single();
  }

  Future<Map<String, dynamic>> insertPost({
    required String userId,
    required String title,
    required String body,
  }) async {
    return await _client
        .from(Keys.postsTable)
        .insert({
          Keys.userId: userId,
          Keys.title: title,
          Keys.body: body,
        })
        .select(Keys.id)
        .single();
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String body,
  }) async {
    await _client
        .from(Keys.postsTable)
        .update({Keys.title: title, Keys.body: body}).eq(Keys.id, id);
  }

  Future<void> deletePost(String id) async {
    await _client.from(Keys.postsTable).delete().eq(Keys.id, id);
  }

  Future<List<Map<String, dynamic>>> fetchPostImages(String postId) async {
    final rows = await _client
        .from(Keys.postImagesTable)
        .select('${Keys.id}, ${Keys.storagePath}, ${Keys.position}')
        .eq(Keys.postId, postId)
        .order(Keys.position);

    return rows.cast<Map<String, dynamic>>();
  }

  Future<void> insertPostImages(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    await _client.from(Keys.postImagesTable).insert(rows);
  }

  Future<void> deletePostImages(List<String> ids) async {
    if (ids.isEmpty) return;
    await _client.from(Keys.postImagesTable).delete().inFilter(Keys.id, ids);
  }

  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final rows = await _client
        .from(Keys.commentsTable)
        .select(_commentSelect)
        .eq(Keys.postId, postId)
        .order(Keys.createdAt);

    return rows.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchComment(String id) async {
    return await _client
        .from(Keys.commentsTable)
        .select(_commentSelect)
        .eq(Keys.id, id)
        .single();
  }

  Future<Map<String, dynamic>> insertComment({
    required String postId,
    required String userId,
    required String body,
  }) async {
    return await _client
        .from(Keys.commentsTable)
        .insert({
          Keys.postId: postId,
          Keys.userId: userId,
          Keys.body: body,
        })
        .select(Keys.id)
        .single();
  }

  Future<void> updateComment({required String id, required String body}) async {
    await _client
        .from(Keys.commentsTable)
        .update({Keys.body: body}).eq(Keys.id, id);
  }

  Future<void> deleteComment(String id) async {
    await _client.from(Keys.commentsTable).delete().eq(Keys.id, id);
  }

  Future<List<Map<String, dynamic>>> fetchCommentImages(
    String commentId,
  ) async {
    final rows = await _client
        .from(Keys.commentImagesTable)
        .select('${Keys.id}, ${Keys.storagePath}, ${Keys.position}')
        .eq(Keys.commentId, commentId)
        .order(Keys.position);

    return rows.cast<Map<String, dynamic>>();
  }

  Future<void> insertCommentImages(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    await _client.from(Keys.commentImagesTable).insert(rows);
  }

  Future<void> deleteCommentImages(List<String> ids) async {
    if (ids.isEmpty) return;
    await _client.from(Keys.commentImagesTable).delete().inFilter(Keys.id, ids);
  }

  Future<Map<String, dynamic>> fetchProfile(String id) async {
    return await _client
        .from(Keys.profilesTable)
        .select()
        .eq(Keys.id, id)
        .single();
  }

  Future<Map<String, dynamic>> updateProfile({
    required String id,
    required Map<String, dynamic> values,
  }) async {
    return await _client
        .from(Keys.profilesTable)
        .update(values)
        .eq(Keys.id, id)
        .select()
        .single();
  }
}
