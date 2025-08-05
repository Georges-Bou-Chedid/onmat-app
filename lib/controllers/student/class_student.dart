import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onmat/models/Student.dart';

import '../../models/ClassStudent.dart';

class ClassStudentService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Student> _myStudents = [];
  List<Student> get myStudents => _myStudents;

  StreamSubscription? _subscription;

  void listenToClassStudents(String classId) {
    // Cancel existing listener first (important!)
    _subscription?.cancel();

    _subscription = _firestore
        .collection('class_student')
        .where('class_id', isEqualTo: classId)
        .snapshots()
        .listen((snapshot) async {
      final studentStatusMap = {
        for (var doc in snapshot.docs)
          doc['student_id'] as String: doc['is_active'] ?? false
      };

      final studentIds = studentStatusMap.keys.toList();

      if (studentIds.isEmpty) {
        _myStudents = [];
        notifyListeners();
        return;
      }

      final studentsSnapshot = await _firestore
          .collection('students')
          .where(FieldPath.documentId, whereIn: studentIds)
          .get();

      _myStudents = studentsSnapshot.docs.map((doc) {
        final studentId = doc.id;
        final data = doc.data();
        final isActive = studentStatusMap[studentId] ?? false;

        return Student.fromFirestore(studentId, data, isActive: isActive);
      }).toList();

      notifyListeners();
    }, onError: (error) {
      print("🔥 Real-time listener error: $error");
    });
  }

  void cancelListener() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<bool> addStudentToClass(String classId, String uid, Student student) async {
    try {
      // Step 1: check if student already added
      final existing = await _firestore
          .collection('class_student')
          .where('class_id', isEqualTo: classId)
          .where('student_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        print("ℹ️ Student already added to this class");
        return false;
      }

      ClassStudent cs = ClassStudent(
        classId: classId,
        studentId: uid,
        isActive: false
      );
      await _firestore.collection('class_student').add(cs.toMap());

      _myStudents.add(student);
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Failed to add student to class: $e");
      return false;
    }
  }

  Future<bool> acceptStudent(String classId, String uid) async {
    try {
      // Step 1: Find existing class_student document for this student
      final existing = await _firestore
          .collection('class_student')
          .where('class_id', isEqualTo: classId)
          .where('student_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        print("⚠️ Student not found in this class");
        return false;
      }

      final doc = existing.docs.first;

      // Step 2: Check if already active
      if (doc['is_active'] == true) {
        print("ℹ️ Student already accepted in this class");
        return false;
      }

      // Step 3: Update is_active to true
      await _firestore.collection('class_student').doc(doc.id).update({
        'is_active': true,
      });

      // Optional: update in-memory student if needed
      final idx = _myStudents.indexWhere((s) => s.userId == uid);
      if (idx != -1) {
        _myStudents[idx] = _myStudents[idx].copyWith({}, true);
      }
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Failed to accept student: $e");
      return false;
    }
  }

  Future<bool> ignoreStudent(String classId, String uid) async {
    try {
      // Step 1: Find existing class_student document for this student
      final existing = await _firestore
          .collection('class_student')
          .where('class_id', isEqualTo: classId)
          .where('student_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        print("⚠️ Student not found in this class");
        return false;
      }

      final doc = existing.docs.first;

      // Step 2: Check if already active
      if (doc['is_active'] == true) {
        print("ℹ️ Student already accepted in this class");
        return false;
      }

      // Step 3: Update is_active to true
      await _firestore.collection('class_student').doc(doc.id).delete();

      // Step 4: Remove from in-memory list (optional)
      _myStudents.removeWhere((s) => s.userId == uid);
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Failed to ignore student: $e");
      return false;
    }
  }
}
