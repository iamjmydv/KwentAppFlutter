import 'package:kwentappflutter/data/models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCacheService {
  static const _idKey = 'profile.id';
  static const _nameKey = 'profile.name';
  static const _avatarKey = 'profile.avatarUrl';

  Future<Profile?> read(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_idKey) != userId) return null;

    return Profile(
      id: userId,
      name: prefs.getString(_nameKey) ?? '',
      avatarUrl: prefs.getString(_avatarKey),
    );
  }

  Future<void> write(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idKey, profile.id);
    await prefs.setString(_nameKey, profile.name);

    final avatarUrl = profile.avatarUrl;

    if (avatarUrl == null || avatarUrl.isEmpty) {
      await prefs.remove(_avatarKey);
      return;
    }

    await prefs.setString(_avatarKey, avatarUrl);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_idKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_avatarKey);
  }
}
