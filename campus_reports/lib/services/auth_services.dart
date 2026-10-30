import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(name.trim());
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await cred.user!.sendEmailVerification();
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() => _auth.signOut();

  Future<void> resendVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<bool> refreshVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
}
