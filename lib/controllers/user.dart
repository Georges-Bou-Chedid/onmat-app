import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/UserAccount.dart';

class UserAccountService with ChangeNotifier {
  UserAccount? _userAccount;

  UserAccount? get userAccount => _userAccount;

  void setUser(UserAccount userAccount) {
    _userAccount = userAccount;
    notifyListeners();
  }

  void clearUser() {
    _userAccount = null;
    notifyListeners();
  }

  /// --------------------------------------- User Account

  /// ✅ Fetch user from Firestore and store in provider
  Future<bool> fetchAndSetUser(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(uid)
          .get();

      if (doc.exists) {
        final userAccount = UserAccount.fromFirestore(uid, doc.data()!);
        setUser(userAccount);
        return true;
      } else {
        return false; // Firestore doc doesn't exist
      }
    } catch (e) {
      print("🔥 Failed to fetch user: $e");
      return false;
    }
  }
}
