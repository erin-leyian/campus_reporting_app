import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  User? _user;
  bool _loading = false;
  String? _error;

  AuthProvider() {
    _service.authStateChanges.listen((user) async {
      _user = user;
      _role = user == null ? 'student' : await _service.fetchRole(user.uid);
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isVerified => (_user?.emailVerified ?? false) || isStaff;
  String _role = 'student';
  String get role => _role;
  bool get isStaff => _role == 'staff';

  Future<bool> register(String name, String email, String password) => _run(
    () => _service.register(name: name, email: email, password: password),
  );

  Future<bool> login(String email, String password) =>
      _run(() => _service.login(email, password));

  Future<void> logout() => _service.logout();

  Future<void> resendVerification() =>
      _run(() => _service.resendVerification());

  Future<void> checkVerified() async {
    await _service.refreshVerified();
    _user = _service.currentUser;
    if (_user != null) _role = await _service.fetchRole(_user!.uid);
    notifyListeners();
  }

  // One place that handles loading, errors and notifying screens.
  Future<bool> _run(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _message(e.code);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _message(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication failed ($code).';
    }
  }
}
