import 'package:kwentappflutter/core/resources/keys.dart';

class PostImage {
  const PostImage({
    required this.id,
    required this.postId,
    required this.storagePath,
    required this.position,
    this.url = '',
  });

  final String id;
  final String postId;
  final String storagePath;
  final int position;
  final String url;

  factory PostImage.fromMap(String id, Map<String, dynamic> map) {
    return PostImage(
      id: id,
      postId: map[Keys.postId] as String? ?? '',
      storagePath: map[Keys.storagePath] as String? ?? '',
      position: map[Keys.position] as int? ?? 0,
    );
  }

  PostImage withUrl(String url) {
    return PostImage(
      id: id,
      postId: postId,
      storagePath: storagePath,
      position: position,
      url: url,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostImage &&
          other.id == id &&
          other.postId == postId &&
          other.storagePath == storagePath &&
          other.position == position &&
          other.url == url;

  @override
  int get hashCode => Object.hash(id, postId, storagePath, position, url);
}
