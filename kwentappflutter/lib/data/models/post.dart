import 'package:kwentappflutter/core/resources/keys.dart';
import 'package:kwentappflutter/core/utils/list_equality.dart';
import 'package:kwentappflutter/data/models/post_image.dart';
import 'package:kwentappflutter/data/models/profile.dart';

class Post {
  const Post({
    required this.id,
    required this.author,
    required this.title,
    required this.body,
    this.images = const [],
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final Profile author;
  final String title;
  final String body;
  final List<PostImage> images;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    final authorId = map[Keys.userId] as String? ?? '';
    final authorMap = map[Keys.profilesTable] as Map<String, dynamic>? ?? const {};
    final imageMaps = map[Keys.postImagesTable] as List<dynamic>? ?? const [];

    final images = imageMaps
        .whereType<Map<String, dynamic>>()
        .map((entry) => PostImage.fromMap(entry[Keys.id] as String? ?? '', entry))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    return Post(
      id: id,
      author: Profile.fromMap(authorId, authorMap),
      title: map[Keys.title] as String? ?? '',
      body: map[Keys.body] as String? ?? '',
      images: images,
      commentCount: _commentCountFrom(map[Keys.commentsTable]),
      createdAt: DateTime.parse(map[Keys.createdAt] as String),
      updatedAt: DateTime.parse(map[Keys.updatedAt] as String),
    );
  }

  static int _commentCountFrom(Object? value) {
    if (value is int) return value;
    if (value is Map<String, dynamic>) return value[Keys.count] as int? ?? 0;
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map<String, dynamic>) return first[Keys.count] as int? ?? 0;
    }
    return 0;
  }

  Post copyWith({
    Profile? author,
    String? title,
    String? body,
    List<PostImage>? images,
    int? commentCount,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id,
      author: author ?? this.author,
      title: title ?? this.title,
      body: body ?? this.body,
      images: images ?? this.images,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          other.id == id &&
          other.author == author &&
          other.title == title &&
          other.body == body &&
          areListsEqual(other.images, images) &&
          other.commentCount == commentCount &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        author,
        title,
        body,
        Object.hashAll(images),
        commentCount,
        createdAt,
        updatedAt,
      );
}
