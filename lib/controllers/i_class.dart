import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onmat/models/Class.dart';

class InstructorClassService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Class> _myClasses = [];
  List<Class> get myClasses => _myClasses;

  Future<void> refresh() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await fetchClassesForOwner(uid);
    }
  }

  /// --------------------------------------- Class
  Future<void> fetchClassesForOwner(String ownerId) async {
    try {
      final snapshot = await _firestore
          .collection('classes')
          .where('owner_id', isEqualTo: ownerId)
          .get();

      _myClasses = snapshot.docs.map((doc) => Class.fromFirestore(ownerId, doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print("🔥 Error fetching classes: $e");
      _myClasses = [];
      notifyListeners();
    }
  }

  Future<bool> createClass(Class cl) async {
    try {
      await _firestore
          .collection('classes')
          .add(cl.toMap());

      _myClasses.add(cl);
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Failed to create class: $e");
      return false;
    }
  }
}
