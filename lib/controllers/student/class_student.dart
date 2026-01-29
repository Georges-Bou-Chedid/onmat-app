import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onmat/models/Student.dart';

import '../../models/Belt.dart';
import '../../models/ClassStudent.dart';

class ClassStudentService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

      final classDoc = await _firestore.collection('classes').doc(classId).get();
      if (!classDoc.exists) return false;

      final String instructorId = classDoc.data()?['owner_id'] ?? '';
      final String className = classDoc.data()?['class_name'] ?? 'Class';

      ClassStudent cs = ClassStudent(
        classId: classId,
        studentId: uid,
        isActive: false
      );
      await _firestore.collection('class_student').add(cs.toMap());

      final instructorDoc = await _firestore.collection('instructors').doc(instructorId).get();
      bool notificationsEnabled = true;

      if (instructorDoc.exists) {
        notificationsEnabled = instructorDoc.data()?['notifications'] ?? true;
      }

      if (notificationsEnabled) {
        await _firestore.collection('notifications').add({
          'receiver_id': instructorId,
          'sender_id': uid,
          'title': 'New Join Request',
          'message': '${student.firstName} ${student.lastName} wants to join $className',
          'timestamp': FieldValue.serverTimestamp(),
          'is_read': false,
          'type': 'join_request',
          'class_id': classId,
        });
      }

      _myStudents.add(student);
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Failed to add student to class: $e");
      return false;
    }
  }

  Future<bool> acceptStudent(String classId, String uid, String studentName) async {
    final batch = _firestore.batch();
    final instructorId = _auth.currentUser!.uid;
    const double joinFee = 2.0;

    try {
      // Step 1: Find existing class_student document for this student
      final existing = await _firestore
          .collection('class_student')
          .where('class_id', isEqualTo: classId)
          .where('student_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) return false;
      final enrollmentDoc = existing.docs.first;

      if (enrollmentDoc['is_active'] == true) return false;

      final classDoc = await _firestore.collection('classes').doc(classId).get();
      final String className = classDoc.data()?['class_name'] ?? 'Class';

      batch.update(enrollmentDoc.reference, {'is_active': true});

      final transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'instructor_id': instructorId,
        'student_id': uid,
        'student_name': studentName,
        'type': 'join_fee',
        'amount': joinFee,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      final instructorRef = _firestore.collection('instructors').doc(instructorId);
      batch.update(instructorRef, {
        'outstanding_balance': FieldValue.increment(joinFee),
      });

      // 6. Queue Notification for the Student
      // Check if student has notifications enabled first
      final studentDoc = await _firestore.collection('students').doc(uid).get();
      bool studentWantsNotifs = studentDoc.data()?['notifications'] ?? true;

      if (studentWantsNotifs) {
        final notifRef = _firestore.collection('notifications').doc();
        batch.set(notifRef, {
          'receiver_id': uid,
          'sender_id': instructorId,
          'title': 'Request Accepted! 🥋',
          'message': 'You have been accepted into $className. Welcome to the mats!',
          'timestamp': FieldValue.serverTimestamp(),
          'is_read': false,
          'type': 'join_accepted',
          'class_id': classId,
        });
      }

      // 7. Commit Batch
      await batch.commit();

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

  Future<bool> updateStudentStripes(String classId, String studentUid, String studentName, int newStripes) async {
    final instructorId = _auth.currentUser!.uid;
    const double fee = 2.0;

    try {
      return await _firestore.runTransaction((transaction) async {
        // 1. Find the student record
        final querySnapshot = await _firestore
            .collection('class_student')
            .where('class_id', isEqualTo: classId)
            .where('student_id', isEqualTo: studentUid)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) return false;

        final studentDoc = querySnapshot.docs.first;
        final studentData = studentDoc.data();
        final int oldStripes = studentData['stripes'] ?? 0;

        // 2. Always update the stripes count
        transaction.update(studentDoc.reference, {'stripes': newStripes});

        // 3. ONLY charge and log if stripes increased
        if (newStripes > oldStripes) {
          // Create Transaction Log
          final transactionRef = _firestore.collection('transactions').doc();
          transaction.set(transactionRef, {
            'instructor_id': instructorId,
            'student_name': studentName,
            'student_id': studentUid,
            'type': 'stripe_addition',
            'amount': fee,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Increment Instructor Balance
          final instructorRef = _firestore.collection('instructors').doc(instructorId);
          transaction.update(instructorRef, {
            'outstanding_balance': FieldValue.increment(fee),
          });
        }

        return true;
      });
    } catch (e) {
      print("🔥 Failed to update stripes: $e");
      return false;
    }
  }

  Future<bool> upgradeStudentBelt(String classId, String studentUid, String studentName, Color belt1, Color? belt2) async {
    final batch = _firestore.batch();
    final instructorId = _auth.currentUser!.uid;
    const double fee = 2.0;

    try {
      // 1. Find the student record to get their name and document ID
      final querySnapshot = await _firestore
          .collection('class_student')
          .where('class_id', isEqualTo: classId)
          .where('student_id', isEqualTo: studentUid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      final studentDoc = querySnapshot.docs.first;

      // 2. Queue the Student Update in Batch
      batch.update(studentDoc.reference, {
        'belt1': Belt.getColorName(belt1), // Storing .value (int) is safer for logic than Strings
        'belt2': belt2 != null ? Belt.getColorName(belt2) : null,
        'stripes': 0,
        'class_attended': 0,
      });

      // 3. Queue the Transaction Log in Batch
      final transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'instructor_id': instructorId,
        'student_name': studentName,
        'student_id': studentUid,
        'type': 'belt_upgrade',
        'amount': fee,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 4. Queue the Balance Increment in Batch
      final instructorRef = _firestore.collection('instructors').doc(instructorId);
      batch.update(instructorRef, {
        'outstanding_balance': FieldValue.increment(fee),
      });

      // 5. Commit all changes at once
      await batch.commit();
      return true;

    } catch (e) {
      print("🔥 Failed to upgrade belt and log transaction: $e");
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
