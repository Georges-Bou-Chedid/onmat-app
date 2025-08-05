import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onmat/models/Student.dart';

class StudentService with ChangeNotifier {
  Student? _student;

  Student? get student => _student;

  Future<bool> fetchAndSetStudent(String studentId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      if (doc.exists) {
        _student = Student.fromFirestore(studentId, doc.data()!);
        notifyListeners();
        return true;
      } else {
        return false; // Firestore doc doesn't exist
      }
    } catch (e) {
      print("🔥 Failed to fetch student: $e");
      return false;
    }
  }

  Future<bool> updateFields(String? studentId, Map<String, dynamic> changes) async {
    try {
      if (studentId == null) {
        return false;
      }
      changes.removeWhere((_, value) => value == null);
      changes['updated_at'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .set(changes, SetOptions(merge: true));

      _student = _student?.copyWith(changes, null);
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Failed to update student: $e");
      return false;
    }
  }
}
