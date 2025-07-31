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

      _myClasses = snapshot.docs.map((doc) => Class.fromFirestore(doc.id, doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print("🔥 Error fetching classes: $e");
      _myClasses = [];
      notifyListeners();
    }
  }

  Future<bool> createClass(Class cl) async {
    try {
      final docRef = _firestore.collection('classes').doc();
      final classId = docRef.id;
      cl.id = classId;

      await docRef.set(cl.toMap());

      _myClasses.add(cl);
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Failed to create class: $e");
      return false;
    }
  }

  Future<bool> updateFields(String? classId, Map<String, dynamic> changes) async {
    try {
      if (classId == null) {
        return false;
      }
      changes.removeWhere((_, value) => value == null);
      changes['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('classes')
          .doc(classId)
          .set(changes, SetOptions(merge: true));

      final idx = _myClasses.indexWhere((c) => c.id == classId);
      if (idx != -1) {
        final updated = _myClasses[idx].copyWith(changes);
        _myClasses[idx] = updated;
        notifyListeners();
      }

      return true;
    } catch (e) {
      print("🔥 Failed to update class: $e");
      return false;
    }
  }
}
