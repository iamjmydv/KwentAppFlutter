import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/data/models/app_user.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/data/repositories/auth_repository.dart';
import 'package:kwentappflutter/ui/auth/auth_form_state.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository) {
    _user = _repository.currentUser;
    _subscription = _repository.authState.listen(_onAuthChanged);
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _subscription;

  AppUser? _user;
  AuthFormState _formState = const AuthFormIdle();

  AppUser? get user => _user;
  bool get isSignedIn => _user != null;
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
    notifyListeners();
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
