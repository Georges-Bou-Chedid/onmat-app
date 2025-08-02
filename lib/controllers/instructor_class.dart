import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onmat/models/Class.dart';

import '../models/Instructor.dart';

class InstructorClassService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Class> _ownerClasses = [];
  List<Class> _assistantClasses = [];
  List<Class> get ownerClasses => _ownerClasses;
  List<Class> get assistantClasses => _assistantClasses;
  Instructor? _classOwner;
  Instructor? get classOwner => _classOwner;

  Future<void> refresh() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await fetchClassesForOwnerAndAssistant(uid);
    }
  }

  Future<void> fetchClassesForOwnerAndAssistant(String userId) async {
    try {
      // 1. Fetch classes owned by the user
      final ownedSnapshot = await _firestore
          .collection('classes')
          .where('owner_id', isEqualTo: userId)
          .get();

      _ownerClasses = ownedSnapshot.docs
          .map((doc) => Class.fromFirestore(doc.id, doc.data()))
          .toList();

      // 2. Fetch class IDs where the user is an assistant
      final assistantSnapshot = await _firestore
          .collection('class_assistant')
          .where('assistant_id', isEqualTo: userId)
          .get();

      final assistantClassIds = assistantSnapshot.docs
          .map((doc) => doc['class_id'] as String)
          .toSet();

      // 3. Fetch class documents for assistant class IDs
      _assistantClasses = [];
      if (assistantClassIds.isNotEmpty) {
        final assistantClassSnapshots = await _firestore
            .collection('classes')
            .where(FieldPath.documentId, whereIn: assistantClassIds.toList())
            .get();

        _assistantClasses = assistantClassSnapshots.docs
            .map((doc) => Class.fromFirestore(doc.id, doc.data()))
            .where((classDoc) => classDoc.ownerId != userId)
            .toList();
      }

      notifyListeners();
    } catch (e) {
      print("🔥 Error fetching classes: $e");
      _ownerClasses = [];
      _assistantClasses = [];
      notifyListeners();
    }
  }

  Future<void> getClassOwner(String? ownerId) async {
    if (ownerId == null) return;

    try {
      // 1. Fetch class owner
      final doc = await _firestore
          .collection('instructors')
          .doc(ownerId)
          .get();

      _classOwner = Instructor.fromFirestore(ownerId, doc.data()!);
      notifyListeners();
    } catch (e) {
      print("🔥 Error fetching owner: $e");
    }
  }

  Future<bool> createClass(Class cl) async {
    try {
      final docRef = _firestore.collection('classes').doc();
      final classId = docRef.id;
      cl.id = classId;

      await docRef.set(cl.toMap());

      _ownerClasses.add(cl);
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

      final ownerIdx = _ownerClasses.indexWhere((c) => c.id == classId);
      final assistantIdx = _assistantClasses.indexWhere((c) => c.id == classId);
      if (ownerIdx != -1) {
        final updated = _ownerClasses[ownerIdx].copyWith(changes);
        _ownerClasses[ownerIdx] = updated;
        notifyListeners();
      }
      else if (assistantIdx != -1) {
        final updated = _assistantClasses[assistantIdx].copyWith(changes);
        _assistantClasses[assistantIdx] = updated;
        notifyListeners();
      }

      return true;
    } catch (e) {
      print("🔥 Failed to update class: $e");
      return false;
    }
  }
}
