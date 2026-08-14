import 'dart:typed_data';

import 'package:kwentappflutter/data/models/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile> fetchProfile(String id);

  Future<Profile> updateName({required String id, required String name});

  Future<Profile> updateAvatar({
    required String id,
    required Uint8List bytes,
    required String extension,
  });

  Future<Profile> removeAvatar(String id);
}
