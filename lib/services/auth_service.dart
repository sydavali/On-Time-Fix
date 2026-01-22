// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user
  User? get currentUser {
    return _auth.currentUser;
  }

  // Sign up with email & password
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ---------------------------------------------------
  // 1. ADD THIS NEW METHOD FOR SIGNING IN
  // ---------------------------------------------------
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // This is the command that signs the user in
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ---------------------------------------------------
  // 2. ADD THIS NEW METHOD FOR SIGNING OUT
  // ---------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }
}