import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In 7.x
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized || kIsWeb) return;

    await _googleSignIn.initialize();

    _googleInitialized = true;
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Web
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider =
            GoogleAuthProvider();

        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);

        return userCredential.user;
      }

      // Android / iOS
      await _initializeGoogleSignIn();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print('Registration Error: $e');
      return null;
    }
  }

  // Login with email and password
  Future<User?> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }

    await _auth.signOut();
  }

  Stream<User?> get userStream => _auth.authStateChanges();
}