import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:onmat/models/Instructor.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../models/AuthResult.dart";
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import "../models/Student.dart";

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? getCurrentUser = FirebaseAuth.instance.currentUser;

  // auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  bool isGoogleUser() {
    final user = _auth.currentUser;
    return user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
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

  Future<AuthResult> signUpByEmail(
      String email,
      String password,
      Instructor? instructor,
      Student? student
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user == null) {
        return AuthResult(success: false, errorMessage: 'auth-user-creation-failed');
      }

      dynamic model;
      var modelString = '';
      if (instructor != null) {
        model = instructor;
        modelString = 'instructors';
      } else {
        model = student;
        modelString = 'students';
      }

    final existing = await FirebaseFirestore.instance
        .collection(modelString)
        .where('username', isEqualTo: model.username)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await user.delete(); // Rollback user creation
      return AuthResult(success: false, errorMessage: 'username-already-taken');
    }

    if (! user.emailVerified) {
      await user.sendEmailVerification();
    }

    model.userId = user.uid;
    // 4. Create Firestore user account
    await FirebaseFirestore.instance
        .collection(modelString)
        .doc(user.uid)
        .set(model.toMap());

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

      final role = await getUserRole(user.uid);
      if (role == null) {
        await user.delete();
        await signOut();
        return AuthResult(success: false, errorMessage: 'user-not-found');
      }

      return AuthResult(success: true);
    } catch (e) {
      print('Sign-in error: $e');
      return AuthResult(success: false, errorMessage: 'unexpected-error');
    }
  }

  Future<AuthResult> signUpWithGoogle(
      Instructor? instructor,
      Student? student
  ) async {
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

      dynamic model;
      var modelString = '';
      if (instructor != null) {
        model = instructor;
        modelString = 'instructors';
      } else {
        model = student;
        modelString = 'students';
      }

      // 🔒 Check if a user_account already exists for this UID
      final existingAccountDoc = await FirebaseFirestore.instance
          .collection(modelString)
          .doc(uid)
          .get();

      if (existingAccountDoc.exists) {
        await signOut();
        return AuthResult(success: false, errorMessage: 'user-already-exists');
      }

      // Check username uniqueness
      final existing = await FirebaseFirestore.instance
          .collection(modelString)
          .where('username', isEqualTo: model.username)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        await signOut();
        return AuthResult(success: false, errorMessage: 'username-already-taken');
      }

      model.userId = uid;
      model.email = user.email;
      await FirebaseFirestore.instance
          .collection(modelString)
          .doc(uid)
          .set(model.toMap());

      return AuthResult(success: true);
    } catch (e) {
      print('Sign-up error: $e');
      return AuthResult(success: false, errorMessage: 'unexpected-error');
    }
  }

  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      final uid = user?.uid;

      if (uid == null) {
        return AuthResult(success: false, errorMessage: 'user-not-found');
      }

      final role = await getUserRole(uid);

      // 1. Delete Firestore user document
      if (role == 'instructor') {
        await FirebaseFirestore.instance.collection('instructors').doc(uid).delete();
      } else if (role == 'student') {
        await FirebaseFirestore.instance.collection('students').doc(uid).delete();
      }

      // 2. Delete FirebaseAuth user
      await user?.delete();

      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.code);
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'unexpected-error');
    }
  }

  Future<void> applyLocale(String code) async {
    Get.updateLocale(Locale(code));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', code);      // persists the choice
  }

  Future<String?> getUserRole(String uid) async {
    final instructorDoc = await FirebaseFirestore.instance
        .collection('instructors')
        .doc(uid)
        .get();
    if (instructorDoc.exists) return 'instructor';

    final studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(uid)
        .get();
    if (studentDoc.exists) return 'student';

    return null;
  }
}