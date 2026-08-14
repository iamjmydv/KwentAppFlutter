import 'package:kwentappflutter/core/resources/keys.dart';
import 'package:kwentappflutter/core/utils/list_equality.dart';
import 'package:kwentappflutter/data/models/comment_image.dart';
import 'package:kwentappflutter/data/models/profile.dart';

class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.body,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String postId;
  final Profile author;
  final String body;
  final List<CommentImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    final authorId = map[Keys.userId] as String? ?? '';
    final authorMap = map[Keys.profilesTable] as Map<String, dynamic>? ?? const {};
    final imageMaps = map[Keys.commentImagesTable] as List<dynamic>? ?? const [];

    final images = imageMaps
        .whereType<Map<String, dynamic>>()
        .map((entry) => CommentImage.fromMap(entry[Keys.id] as String? ?? '', entry))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    return Comment(
      id: id,
      postId: map[Keys.postId] as String? ?? '',
      author: Profile.fromMap(authorId, authorMap),
      body: map[Keys.body] as String? ?? '',
      images: images,
      createdAt: DateTime.parse(map[Keys.createdAt] as String),
      updatedAt: DateTime.parse(map[Keys.updatedAt] as String),
    );
  }

  Comment copyWith({
    Profile? author,
    String? body,
    List<CommentImage>? images,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id,
      postId: postId,
      author: author ?? this.author,
      body: body ?? this.body,
      images: images ?? this.images,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          other.id == id &&
          other.postId == postId &&
          other.author == author &&
          other.body == body &&
          areListsEqual(other.images, images) &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        postId,
        author,
        body,
        Object.hashAll(images),
        createdAt,
        updatedAt,
      );
}
