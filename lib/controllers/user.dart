import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/AuthResult.dart';
import '../models/UserAccount.dart';
import 'auth.dart';

class UserAccountService with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserAccount? _userAccount;

  UserAccount? get userAccount => _userAccount;

  //--------------------------------------- User Account

  Future<AuthResult> createUserAccount(String uid, UserAccount userAccount) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 🔍 Check if the username already exists
      final existingUser = await firestore
          .collection('user_accounts')
          .where('username', isEqualTo: userAccount.username)
          .limit(1)
          .get();
      if (existingUser.docs.isNotEmpty) {
        // 🚫 Username already exists
        return AuthResult(success: false, errorMessage: 'username-already-taken');
      }

      await firestore.collection('user_accounts').doc(uid).set(userAccount.toMap());

      _userAccount = userAccount;
      notifyListeners();
      return AuthResult(success: true);
    } catch (e) {
      print('Error creating Firestore user: $e');
      return AuthResult(success: false, errorMessage: 'unexpected-error');
    }
  }
}
