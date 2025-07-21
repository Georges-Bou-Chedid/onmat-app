import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/Instructor.dart';

class InstructorService with ChangeNotifier {
  Instructor? _instructor;

  Instructor? get instructor => _instructor;

  Future<bool> fetchAndSetInstructor(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('instructors')
          .doc(uid)
          .get();

      if (doc.exists) {
        _instructor = Instructor.fromFirestore(uid, doc.data()!);
        notifyListeners();
        return true;
      } else {
        return false; // Firestore doc doesn't exist
      }
    } catch (e) {
      print("🔥 Failed to fetch instructor: $e");
      return false;
    }
  }

  Future<bool> updateFields(String? uid, Map<String, dynamic> changes) async {
    try {
      if (uid == null) {
        return false;
      }
      changes.removeWhere((_, value) => value == null);
      changes['updated_at'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('instructors')
          .doc(uid)
          .set(changes, SetOptions(merge: true));

      _instructor = _instructor?.copyWith(changes);
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Failed to update instructor: $e");
      return false;
    }
  }
}
