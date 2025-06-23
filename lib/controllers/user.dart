import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/UserAccount.dart';
import 'auth.dart';

class UserAccountService with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserAccount? _userAccount;

  UserAccount? get userAccount => _userAccount;

  //--------------------------------------- User Account

  Future<UserAccount?> createUserAccount(String uid, UserAccount userAccount) async {
    try {
      // final DatabaseReference storeRef = FirebaseDatabase.instance.ref();
      // await storeRef.child("user_account").child(uid).set(account.toMap());
      //
      // _userAccount = account;
      // notifyListeners();
      // return account;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  String getTimestamp() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }
}
