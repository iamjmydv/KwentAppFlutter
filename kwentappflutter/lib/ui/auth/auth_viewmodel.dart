import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/data/models/app_user.dart';
import 'package:kwentappflutter/data/models/profile.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/data/repositories/auth_repository.dart';
import 'package:kwentappflutter/data/repositories/profile_repository.dart';
import 'package:kwentappflutter/ui/auth/auth_form_state.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository, this._profiles) {
    _user = _repository.currentUser;
    _subscription = _repository.authState.listen(_onAuthChanged);
    reloadProfile();
  }

  final AuthRepository _repository;
  final ProfileRepository _profiles;
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

    try {
      _profile = await _profiles.fetchProfile(id);
    } catch (_) {
      _profile = null;
    }

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
