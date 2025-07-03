import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:onmat/models/UserAccount.dart";
import "../models/AuthResult.dart";

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? getCurrentUser = FirebaseAuth.instance.currentUser;

  // auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<AuthResult> signInByEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
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

  Future<AuthResult> signUpByEmail(String email, String password, UserAccount userAccount) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user == null) {
        return AuthResult(success: false, errorMessage: 'auth-user-creation-failed');
      }

      final existing = await FirebaseFirestore.instance
          .collection('user_accounts')
          .where('username', isEqualTo: userAccount.username)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        await user.delete(); // Rollback user creation
        return AuthResult(success: false, errorMessage: 'username-already-taken');
      }

      if (! user.emailVerified) {
        await user.sendEmailVerification();
      }

      userAccount.userId = user.uid;
      // 4. Create Firestore user account
      await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(user.uid)
          .set(userAccount.toMap());

      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.code);
    } catch (e) {
      print("Unexpected error during sign up: $e");
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) await user.delete();

      return AuthResult(success: false, errorMessage: 'unexpected-error');
    }
  }

  Future<AuthResult> signInWithGoogleIfExists() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, errorMessage: 'google-cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        return AuthResult(success: false, errorMessage: 'auth-failed');
      }

      final doc = await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(user.uid)
          .get();

      if (! doc.exists) {
        await user.delete();
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        return AuthResult(success: false, errorMessage: 'user-not-found');
      }

      return AuthResult(success: true);
    } catch (e) {
      print('Sign-in error: $e');
      return AuthResult(success: false, errorMessage: 'unexpected-error');
    }
  }


  Future<AuthResult> signUpWithGoogleAndCreateUser(UserAccount userAccount) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, errorMessage: 'google-cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        return AuthResult(success: false, errorMessage: 'auth-failed');
      }

      final uid = user.uid;

      // 🔒 Check if a user_account already exists for this UID
      final existingAccountDoc = await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(uid)
          .get();

      if (existingAccountDoc.exists) {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        return AuthResult(success: false, errorMessage: 'user-already-exists');
      }

      // Check username uniqueness
      final existing = await FirebaseFirestore.instance
          .collection('user_accounts')
          .where('username', isEqualTo: userAccount.username)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        return AuthResult(success: false, errorMessage: 'username-already-taken');
      }

      userAccount.userId = uid;
      userAccount.email = user.email;
      await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(uid)
          .set(userAccount.toMap());

      return AuthResult(success: true);
    } catch (e) {
      print('Sign-up error: $e');
      return AuthResult(success: false, errorMessage: 'unexpected-error');
    }
  }
}