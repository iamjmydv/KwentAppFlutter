import 'package:kwentappflutter/core/resources/keys.dart';

class Profile {
  const Profile({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? avatarUrl;

  factory Profile.fromMap(String id, Map<String, dynamic> map) {
    return Profile(
      id: id,
      name: map[Keys.name] as String? ?? '',
      avatarUrl: map[Keys.avatarUrl] as String?,
    );
  }

  Profile copyWith({
    String? name,
    String? avatarUrl,
    bool clearAvatar = false,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          other.id == id &&
          other.name == name &&
          other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hash(id, name, avatarUrl);
}
