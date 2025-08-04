import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onmat/models/Student.dart';

import '../../models/ClassStudent.dart';

class ClassStudentService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Student> _myStudents = [];
  List<Student> get myStudents => _myStudents;

  Future<void> fetchStudentProfiles(String classId) async {
    try {
      // Step 1: Get all class_student docs for this class
      final classStudentsSnapshot = await _firestore
          .collection('class_student')
          .where('class_id', isEqualTo: classId)
          .get();

      // Step 2: Build a map of student_id -> is_active
      final studentStatusMap = {
        for (var doc in classStudentsSnapshot.docs)
          doc.data()['student_id'] as String: doc.data()['is_active'] ?? false
      };

      final studentIds = studentStatusMap.keys.toList();

      if (studentIds.isEmpty) {
        _myStudents = [];
        notifyListeners();
        return;
      }

      // Step 3: Fetch student profiles by IDs
      final studentsSnapshot = await _firestore
          .collection('students')
          .where(FieldPath.documentId, whereIn: studentIds)
          .get();

      // Step 4: Combine profile + is_active into Student objects
      _myStudents = studentsSnapshot.docs.map((doc) {
        final studentId = doc.id;
        final data = doc.data();

        final student = Student.fromFirestore(studentId, data);

        // 👇 Set isActive using class_student mapping
        student.isActive = studentStatusMap[studentId] ?? false;

        return student;
      }).toList();

      notifyListeners();
    } catch (e) {
      print("🔥 Error: $e");
      _myStudents = [];
      notifyListeners();
    }
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
}
