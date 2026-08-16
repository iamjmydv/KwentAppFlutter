import 'dart:typed_data';

import 'package:kwentappflutter/core/resources/keys.dart';
import 'package:kwentappflutter/data/models/profile.dart';
import 'package:kwentappflutter/data/repositories/profile_repository.dart';
import 'package:kwentappflutter/data/repositories/supabase/failure_mapper.dart';
import 'package:kwentappflutter/data/services/database_service.dart';
import 'package:kwentappflutter/data/services/storage_service.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._database, this._storage);

  final DatabaseService _database;
  final StorageService _storage;

  @override
  Future<Profile> fetchProfile(String id) {
    return guard(() async => _toProfile(await _database.fetchProfile(id)));
  }

  @override
  Future<Profile> updateName({required String id, required String name}) {
    return guard(() async {
      final row = await _database.updateProfile(
        id: id,
        values: {Keys.name: name},
      );
      return _toProfile(row);
    });
  }

  @override
  Future<Profile> updateAvatar({
    required String id,
    required Uint8List bytes,
    required String extension,
  }) {
    return guard(() async {
      final previous = await _database.fetchProfile(id);
      final previousPath = previous[Keys.avatarUrl] as String?;

      final path = await _storage.upload(
        bucket: Keys.avatarsBucket,
        ownerId: id,
        bytes: bytes,
        extension: extension,
      );

      final row = await _database.updateProfile(
        id: id,
        values: {Keys.avatarUrl: path},
      );

      if (previousPath != null && previousPath.isNotEmpty) {
        await _storage.remove(
          bucket: Keys.avatarsBucket,
          paths: [previousPath],
        );
      }

      return _toProfile(row);
    });
  }

  @override
  Future<Profile> removeAvatar(String id) {
    return guard(() async {
      final previous = await _database.fetchProfile(id);
      final previousPath = previous[Keys.avatarUrl] as String?;

      final row = await _database.updateProfile(
        id: id,
        values: {Keys.avatarUrl: null},
      );

      if (previousPath != null && previousPath.isNotEmpty) {
        await _storage.remove(
          bucket: Keys.avatarsBucket,
          paths: [previousPath],
        );
      }

      return _toProfile(row);
    });
  }

  Profile _toProfile(Map<String, dynamic> row) {
    final profile = Profile.fromMap(row[Keys.id] as String, row);
    final path = profile.avatarUrl;

    if (path == null || path.isEmpty) return profile;
    if (path.startsWith('http')) return profile;

    return profile.copyWith(
      avatarUrl: _storage.publicUrl(bucket: Keys.avatarsBucket, path: path),
    );
  }
}
