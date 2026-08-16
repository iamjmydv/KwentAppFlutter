import 'dart:math';
import 'dart:typed_data';

import 'package:kwentappflutter/core/resources/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService(this._client);

  final SupabaseClient _client;
  final _random = Random.secure();

  String buildPath({
    required String ownerId,
    required String extension,
  }) {
    final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final noise = List.generate(
      8,
      (_) => _random.nextInt(36).toRadixString(36),
    ).join();

    return '$ownerId/$stamp$noise.$extension';
  }

  Future<String> upload({
    required String bucket,
    required String ownerId,
    required Uint8List bytes,
    String extension = Constants.defaultImageExtension,
  }) async {
    final path = buildPath(ownerId: ownerId, extension: extension);

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _contentTypeFor(extension)),
        );

    return path;
  }

  Future<void> remove({
    required String bucket,
    required List<String> paths,
  }) async {
    if (paths.isEmpty) return;
    await _client.storage.from(bucket).remove(paths);
  }

  String publicUrl({required String bucket, required String path}) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  static String _contentTypeFor(String extension) {
    return switch (extension.toLowerCase()) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}
