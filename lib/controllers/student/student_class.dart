import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onmat/models/Class.dart';

import '../../models/Instructor.dart';

class StudentClassService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Class> _classes = [];
  List<Class> get classes => _classes;

  Instructor? _classOwner;
  Instructor? get classOwner => _classOwner;

  StreamSubscription? _classStudentSubscription;
  final Map<String, StreamSubscription> _classListeners = {};

  void listenToStudentClasses(String studentId) {
    _classStudentSubscription?.cancel();
    _cancelAllClassListeners();

    _classStudentSubscription = _firestore
        .collection('class_student')
        .where('student_id', isEqualTo: studentId)
        .where('is_active', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      final classIds = snapshot.docs
          .map((doc) => doc['class_id'] as String)
          .toSet(); // <- Use Set to avoid duplicates

      final currentIds = _classes.map((c) => c.id).toSet();

      // If class IDs changed (added/removed), reset listeners
      if (! setEquals(classIds, currentIds)) {
        _setupClassListeners(classIds.toList());
      }
    });
  }

  void _setupClassListeners(List<String> classIds) {
    // Cancel listeners for removed classes
    _classListeners.keys
        .where((id) => !classIds.contains(id))
        .toList()
        .forEach((id) {
      _classListeners[id]?.cancel();
      _classListeners.remove(id);
      _classes.removeWhere((c) => c.id == id);
    });

    for (var classId in classIds) {
      _classListeners[classId]?.cancel(); // Cancel old if any

      final subscription = _firestore
          .collection('classes')
          .doc(classId)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          final updated = Class.fromFirestore(doc.id, doc.data()!);
          final index = _classes.indexWhere((c) => c.id == classId);
          if (index != -1) {
            _classes[index] = updated;
          } else {
            _classes.add(updated);
          }
        } else {
          _classes.removeWhere((c) => c.id == classId);
          _classListeners[classId]?.cancel();
          _classListeners.remove(classId);
        }
        notifyListeners();
      });

      _classListeners[classId] = subscription;
    }
  }

  void _cancelAllClassListeners() {
    for (var sub in _classListeners.values) {
      sub.cancel();
    }
    _classListeners.clear();
    _classes.clear();
  }

  void cancelListener() {
    _classStudentSubscription?.cancel();
    _cancelAllClassListeners();
  }
}
