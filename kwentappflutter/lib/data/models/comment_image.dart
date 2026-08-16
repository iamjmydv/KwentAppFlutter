import 'package:kwentappflutter/core/resources/keys.dart';

class CommentImage {
  const CommentImage({
    required this.id,
    required this.commentId,
    required this.storagePath,
    required this.position,
    this.url = '',
  });

  final String id;
  final String commentId;
  final String storagePath;
  final int position;
  final String url;

  factory CommentImage.fromMap(String id, Map<String, dynamic> map) {
    return CommentImage(
      id: id,
      commentId: map[Keys.commentId] as String? ?? '',
      storagePath: map[Keys.storagePath] as String? ?? '',
      position: map[Keys.position] as int? ?? 0,
    );
  }

  CommentImage withUrl(String url) {
    return CommentImage(
      id: id,
      commentId: commentId,
      storagePath: storagePath,
      position: position,
      url: url,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentImage &&
          other.id == id &&
          other.commentId == commentId &&
          other.storagePath == storagePath &&
          other.position == position &&
          other.url == url;

  @override
  int get hashCode => Object.hash(id, commentId, storagePath, position, url);
}
