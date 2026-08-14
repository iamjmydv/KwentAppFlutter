import 'package:kwentappflutter/core/resources/keys.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
  });

  final String id;
  final String email;
  final String name;

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      email: map[Keys.email] as String? ?? '',
      name: map[Keys.name] as String? ?? '',
    );
  }

  AppUser copyWith({String? email, String? name}) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          other.id == id &&
          other.email == email &&
          other.name == name;

  @override
  int get hashCode => Object.hash(id, email, name);
}
