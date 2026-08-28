import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/core/events/app_events.dart';
import 'package:kwentappflutter/data/models/profile.dart';
import 'package:kwentappflutter/data/repositories/profile_repository.dart';
import 'package:kwentappflutter/ui/profile/profile_state.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._repository, this._events, this._userId) {
    load();
  }

  final ProfileRepository _repository;
  final AppEventBus _events;
  final String _userId;

  ProfileState _state = const ProfileLoading();
  var _isBusy = false;

  ProfileState get state => _state;

  Future<void> load() async {
    if (_isBusy) return;
    _isBusy = true;
    _set(const ProfileLoading());

    try {
      _set(ProfileLoaded(profile: await _repository.fetchProfile(_userId)));
    } catch (error) {
      _set(ProfileError(failureMessage(error)));
    } finally {
      _isBusy = false;
    }
  }

  Future<String?> saveName(String name) {
    return _mutate(
      busy: (current) => current.copyWith(isSavingName: true),
      action: () => _repository.updateName(id: _userId, name: name),
      idle: (current) => current.copyWith(isSavingName: false),
    );
  }

  Future<String?> changeAvatar({
    required Uint8List bytes,
    required String extension,
  }) {
    return _mutate(
      busy: (current) => current.copyWith(isChangingAvatar: true),
      action: () => _repository.updateAvatar(
        id: _userId,
        bytes: bytes,
        extension: extension,
      ),
      idle: (current) => current.copyWith(isChangingAvatar: false),
    );
  }

  Future<String?> removeAvatar() {
    return _mutate(
      busy: (current) => current.copyWith(isChangingAvatar: true),
      action: () => _repository.removeAvatar(_userId),
      idle: (current) => current.copyWith(isChangingAvatar: false),
    );
  }

  Future<String?> _mutate({
    required ProfileLoaded Function(ProfileLoaded current) busy,
    required Future<Profile> Function() action,
    required ProfileLoaded Function(ProfileLoaded current) idle,
  }) async {
    final current = _state;
    if (current is! ProfileLoaded || _isBusy) return null;

    _isBusy = true;
    _set(busy(current));

    try {
      final profile = await action();
      _set(ProfileLoaded(profile: profile));
      _events.publish(ProfileChanged(profile));
      return null;
    } catch (error) {
      _set(idle(current));
      return failureMessage(error);
    } finally {
      _isBusy = false;
    }
  }

  void _set(ProfileState next) {
    _state = next;
    notifyListeners();
  }
}
