import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/data/models/app_user.dart';
import 'package:kwentappflutter/data/models/profile.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/data/repositories/auth_repository.dart';
import 'package:kwentappflutter/data/repositories/profile_repository.dart';
import 'package:kwentappflutter/data/services/profile_cache_service.dart';
import 'package:kwentappflutter/ui/auth/auth_form_state.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository, this._profiles, this._cache) {
    _user = _repository.currentUser;
    _subscription = _repository.authState.listen(_onAuthChanged);
    _restoreCachedProfile();
    reloadProfile();
  }

  final AuthRepository _repository;
  final ProfileRepository _profiles;
  final ProfileCacheService _cache;
  late final StreamSubscription<AppUser?> _subscription;

  AppUser? _user;
  Profile? _profile;
  AuthFormState _formState = const AuthFormIdle();

  AppUser? get user => _user;
  Profile? get profile => _profile;
  bool get isSignedIn => _user != null;

  Future<void> reloadProfile() async {
    final id = _user?.id;
    if (id == null) return;

    final Profile profile;

    try {
      profile = await _profiles.fetchProfile(id);
    } catch (_) {
      return;
    }

    _profile = profile;
    notifyListeners();
    await _cache.write(profile);
  }

  Future<void> _restoreCachedProfile() async {
    final id = _user?.id;
    if (id == null || _profile != null) return;

    final cached = await _cache.read(id);
    if (cached == null || _profile != null) return;

    _profile = cached;
    notifyListeners();
  }

  AuthFormState get formState => _formState;
  bool get isBusy => _formState is AuthFormSubmitting;

  void resetForm() {
    if (_formState is AuthFormIdle) return;
    _set(const AuthFormIdle());
  }

  Future<AuthFormState> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => _repository.register(name: name, email: email, password: password),
      Strings.accountCreatedMessage,
    );
  }

  Future<AuthFormState> login({
    required String email,
    required String password,
  }) {
    return _run(
      () => _repository.login(email: email, password: password),
      Strings.signedInMessage,
    );
  }

  Future<bool> logout() async {
    if (isBusy) return false;
    _set(const AuthFormSubmitting());

    try {
      await _repository.logout();
      _user = null;
      _set(const AuthFormIdle());
      return true;
    } catch (error) {
      _set(AuthFormFailed(failureMessage(error)));
      return false;
    }
  }

  Future<AuthFormState> _run(
    Future<AppUser> Function() action,
    String successMessage,
  ) async {
    if (isBusy) return _formState;
    _set(const AuthFormSubmitting());

    try {
      _user = await action();
      _set(AuthFormSucceeded(successMessage));
    } catch (error) {
      _set(AuthFormFailed(failureMessage(error)));
    }

    return _formState;
  }

  void _onAuthChanged(AppUser? user) {
    if (_user == user) return;
    _user = user;
    _profile = null;
    notifyListeners();

    if (user == null) {
      _cache.clear();
      return;
    }

    _restoreCachedProfile();
    reloadProfile();
  }

  void _set(AuthFormState next) {
    _formState = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
