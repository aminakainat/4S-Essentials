import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Private constructor
  AuthService._internal();

  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  // Factory constructor to return the same instance
  factory AuthService() => _instance;

  /// Stream of Auth State Changes (allows reactive UI based on user login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current logged in user
  User? get currentUser => _auth.currentUser;

  /// Sign Up with Email and Password
  /// Updates user's display name upon successful creation
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (kDebugMode) {
        print("Firebase Auth: Attempting signup for $email");
      }
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update user display name
      final User? user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await user.reload(); // Refresh user details
        return _auth.currentUser;
      }
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("Firebase Auth Exception (SignUp): [${e.code}] ${e.message}");
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected Auth Exception (SignUp): $e");
      }
      throw 'An unexpected error occurred during registration. Please try again.';
    }
  }

  /// Sign In with Email and Password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print("Firebase Auth: Attempting login for $email");
      }
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("Firebase Auth Exception (SignIn): [${e.code}] ${e.message}");
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected Auth Exception (SignIn): $e");
      }
      throw 'An unexpected error occurred during login. Please try again.';
    }
  }

  /// Sign Out current user
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print("Firebase Auth: Signing out user: ${currentUser?.email}");
      }
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected Auth Exception (SignOut): $e");
      }
      throw 'Failed to sign out. Please try again.';
    }
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      if (kDebugMode) {
        print("Firebase Auth: Requesting password reset for $email");
      }
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("Firebase Auth Exception (Reset): [${e.code}] ${e.message}");
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected Auth Exception (Reset): $e");
      }
      throw 'Failed to send reset link. Please check your email and try again.';
    }
  }

  /// Helper to convert Firebase error codes to human-readable explanations
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account matches this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'operation-not-allowed':
        return 'Email/Password authentication is disabled in Firebase.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again in a few minutes.';
      case 'network-request-failed':
        return 'A network error occurred. Please check your internet connection.';
      case 'channel-error':
        return 'Please fill in all the required authentication fields.';
      case 'invalid-credential':
        return 'Invalid login credentials. Please check your email and password.';
      default:
        return e.message ?? 'An error occurred during authentication. Code: ${e.code}';
    }
  }
}
