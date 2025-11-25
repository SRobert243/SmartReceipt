import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// AuthService backed by Firebase Authentication.
///
/// Notes:
/// - Make sure Firebase is initialized (call Firebase.initializeApp()) before
///   using this service — `main.dart` does this.
class AuthService {
  AuthService._privateConstructor();

  static final AuthService instance = AuthService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Notifier that indicates whether a user is currently signed in.
  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

  /// Initialize the service and start listening to auth state changes.
  Future<void> init() async {
    // Update initial value
    isLoggedIn.value = _auth.currentUser != null;

    // Listen to changes and update notifier.
    _auth.authStateChanges().listen((user) {
      isLoggedIn.value = user != null;
    });
  }

  String? get currentUser => _auth.currentUser?.email;

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (_) {
      return false;
    }
  }

  Future<bool> signup(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
