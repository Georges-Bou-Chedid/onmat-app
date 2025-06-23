import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";
import "../models/AuthResult.dart";

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User? getCurrentUser = FirebaseAuth.instance.currentUser;

  // auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<AuthResult> signInByEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: code=${e.code}, message=${e.message}");
      return AuthResult(success: false, errorMessage: e.code);
    } catch (e) {
      print("Unexpected error during sign in: $e");
      return AuthResult(success: false, errorMessage: 'unexpected-error');
    }
  }

  Future<AuthResult> signUpByEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null && ! user.emailVerified) {
        await user.sendEmailVerification();
      }

      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.code);
    } catch (e) {
      print("Unexpected error during sign up: $e");
      return AuthResult(success: false, errorMessage: 'unexpected-error');
    }
  }
}