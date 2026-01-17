import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onmat/models/Student.dart';

import '../../models/Belt.dart';
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
          doc['student_id'] as String: {
            'is_active': doc['is_active'] ?? false,
            'attendance_at': (doc.data().containsKey('attendance_at') && doc['attendance_at'] != null)
                ? (doc['attendance_at'] as Timestamp).toDate()
                : null,
            'class_attended': doc['class_attended'] ?? 0,
            'belt1': Belt.getColorFromName(doc['belt1']),
            'belt2': doc['belt2'] != null ? Belt.getColorFromName(doc['belt2']) : null,
            'stripes': doc['stripes'] ?? 0
          }
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
        final status = studentStatusMap[studentId] ?? {};
        final isActive = status['is_active'] ?? false;
        final attendanceAt = status['attendance_at'];
        final classAttended = status['class_attended'] ?? 0;
        final belt1 = status['belt1'] ?? Colors.white;
        final belt2 = status['belt2'];
        final stripes = status['stripes'] ?? 0;

        return Student.fromFirestore(
          studentId,
          data,
          isActive: isActive,
          attendanceAt: attendanceAt,
          classAttended: classAttended,
          belt1: belt1,
          belt2: belt2,
          stripes: stripes
        );
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
        _myStudents[idx] = _myStudents[idx].copyWith({}, isActiveOverride: true);
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

  Future<bool> updateAttendance(String classId, String uid, bool increment) async {
    try {
      // Find existing class_student document
      final querySnapshot = await _firestore
          .collection('class_student')
          .where('class_id', isEqualTo: classId)
          .where('student_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("⚠️ Student not found in this class");
        return false;
      }

      final doc = querySnapshot.docs.first;
      final docRef = doc.reference;

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (! snapshot.exists) return;

        var current = snapshot.data()?['class_attended'] ?? 0;
        if (increment) {
          current = current + 1;
        }
        transaction.update(docRef, {
          'class_attended': current,
          'attendance_at': FieldValue.serverTimestamp(),
        });
      });

      final idx = _myStudents.indexWhere((s) => s.userId == uid);
      if (idx != -1) {
        var currentClassAttended = _myStudents[idx].classAttended;
        if (increment) {
          currentClassAttended = currentClassAttended + 1;
        }

        _myStudents[idx] = _myStudents[idx].copyWith(
          {},
          hasAttendanceTodayOverride: true,
          classAttendedOverride: currentClassAttended,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      print("🔥 Failed to update attendance: $e");
      return false;
    }
  }

  Future<bool> updateStudentStripes(String classId, String uid, int newStripes) async {
    try {
      final querySnapshot = await _firestore
          .collection('class_student')
          .where('class_id', isEqualTo: classId)
          .where('student_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      await _firestore.collection('class_student').doc(querySnapshot.docs.first.id).update({
        'stripes': newStripes,
      });

      return true;
    } catch (e) {
      print("🔥 Failed to update stripes: $e");
      return false;
    }
  }

  Future<bool> upgradeStudentBelt(String classId, String uid, Color belt1, Color? belt2) async {
    try {
      final querySnapshot = await _firestore
          .collection('class_student')
          .where('class_id', isEqualTo: classId)
          .where('student_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      await _firestore.collection('class_student').doc(querySnapshot.docs.first.id).update({
        'belt1': Belt.getColorName(belt1), // Assuming you store names like 'White' in DB
        'belt2': belt2 != null ? Belt.getColorName(belt2) : null,
        'stripes': 0, // Reset stripes to 0 when a new belt is awarded
        'class_attended': 0, // Optionally reset attendance for the new rank
      });

      return true;
    } catch (e) {
      print("🔥 Failed to upgrade belt: $e");
      return false;
    }
  }

  Future<bool> removeStudentFromClass(String classId, String uid) async {
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
