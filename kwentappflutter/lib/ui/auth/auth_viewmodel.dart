import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/data/models/app_user.dart';
import 'package:kwentappflutter/data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository) {
    _user = _repository.currentUser;
    _subscription = _repository.authState.listen(_onAuthChanged);
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _subscription;

  AppUser? _user;
  var _isBusy = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => _repository.register(name: name, email: email, password: password),
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) {
    return _run(() => _repository.login(email: email, password: password));
  }

  Future<bool> logout() async {
    if (_isBusy) return false;
    _setBusy(true);

    try {
      await _repository.logout();
      _user = null;
      return true;
    } catch (error) {
      _errorMessage = failureMessage(error);
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> _run(Future<AppUser> Function() action) async {
    if (_isBusy) return false;
    _errorMessage = null;
    _setBusy(true);

    try {
      _user = await action();
      return true;
    } catch (error) {
      _errorMessage = failureMessage(error);
      return false;
    } finally {
      _setBusy(false);
    }
  }

  void _onAuthChanged(AppUser? user) {
    if (_user == user) return;
    _user = user;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
