import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onmat/models/Class.dart';

import '../../models/Instructor.dart';

class InstructorClassService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Class> _ownerClasses = [];
  List<Class> _assistantClasses = [];

  List<Class> get ownerClasses => _ownerClasses;
  List<Class> get assistantClasses => _assistantClasses;

  Instructor? _classOwner;
  Instructor? get classOwner => _classOwner;

  StreamSubscription? _ownerSubscription;
  final Map<String, StreamSubscription> _ownerClassListeners = {};

  StreamSubscription? _assistantSubscription;
  final Map<String, StreamSubscription> _assistantClassListeners = {};

  void listenToOwnerClasses(String userId) {
    _ownerSubscription?.cancel();
    _cancelAllOwnerClassListeners();

    _ownerSubscription = _firestore
        .collection('classes')
        .where('owner_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final classIds = snapshot.docs.map((doc) => doc.id).toList();

      if (classIds.isEmpty) {
        _ownerClasses = [];
        notifyListeners();
        return;
      }

      final currentIds = _ownerClasses.map((c) => c.id).toSet();
      final newIds = classIds.toSet();

      if (! setEquals(currentIds, newIds)) {
        _setupOwnerClassListeners(classIds);
      }
    });
  }

  void _setupOwnerClassListeners(List<String> classIds) {
    _ownerClassListeners.keys
        .where((id) => !classIds.contains(id))
        .toList()
        .forEach((id) {
      _ownerClassListeners[id]?.cancel();
      _ownerClassListeners.remove(id);
      _ownerClasses.removeWhere((c) => c.id == id);
    });

    for (var classId in classIds) {
      _ownerClassListeners[classId]?.cancel(); // Cancel previous if any

      final subscription = _firestore
          .collection('classes')
          .doc(classId)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          final updated = Class.fromFirestore(doc.id, doc.data()!);
          final index = _ownerClasses.indexWhere((c) => c.id == classId);
          if (index != -1) {
            _ownerClasses[index] = updated;
          } else {
            _ownerClasses.add(updated);
          }
          notifyListeners();
        }
      });

      _ownerClassListeners[classId] = subscription;
    }
  }

  void _cancelAllOwnerClassListeners() {
    for (var sub in _ownerClassListeners.values) {
      sub.cancel();
    }
    _ownerClassListeners.clear();
    _ownerClasses.clear();
  }

  void cancelOwnerListener() {
    _ownerSubscription?.cancel();
    _cancelAllOwnerClassListeners();
  }

  // ✅ Real-time listener for assistant classes
  void listenToAssistantClasses(String userId) {
    _assistantSubscription?.cancel();
    _cancelAllAssistantClassListeners();

    _assistantSubscription = _firestore
        .collection('class_assistant')
        .where('assistant_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final classIds = snapshot.docs
          .map((doc) => doc['class_id'] as String)
          .toList();

      if (classIds.isEmpty) {
        _assistantClasses = [];
        notifyListeners();
        return;
      }

      _setupAssistantClassListeners(classIds);
    }, onError: (e) {
      print("🔥 Error listening to assistant classes: $e");
    });
  }

  void _setupAssistantClassListeners(List<String> classIds) {
    // Cancel listeners for removed classes
    _assistantClassListeners.keys
        .where((id) => !classIds.contains(id))
        .toList()
        .forEach((id) {
      _assistantClassListeners[id]?.cancel();
      _assistantClassListeners.remove(id);
      _assistantClasses.removeWhere((c) => c.id == id);
    });

    for (var classId in classIds) {
      // Always cancel and re-add to ensure fresh listener
      _assistantClassListeners[classId]?.cancel();

      final subscription = _firestore
          .collection('classes')
          .doc(classId)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          final updated = Class.fromFirestore(doc.id, doc.data()!);
          final index = _assistantClasses.indexWhere((c) => c.id == classId);
          if (index != -1) {
            _assistantClasses[index] = updated;
          } else {
            if (!_assistantClasses.any((c) => c.id == classId)) {
              _assistantClasses.add(updated);
            }
          }
          notifyListeners();
        }
      });

      _assistantClassListeners[classId] = subscription;
    }
  }

  void _cancelAllAssistantClassListeners() {
    for (var sub in _assistantClassListeners.values) {
      sub.cancel();
    }
    _assistantClassListeners.clear();
    _assistantClasses.clear();
  }

  void cancelAssistantListener() {
    _assistantSubscription?.cancel();
    _cancelAllAssistantClassListeners();
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

  Future<String?> createClass(Class cl) async {
    try {
      final docRef = _firestore.collection('classes').doc();
      final classId = docRef.id;
      cl.id = classId;
      cl.qrCode = 'join:$classId';

      await docRef.set(cl.toMap());

      return classId;
    } catch (e) {
      print("🔥 Failed to create class: $e");
      return null;
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

  Future<bool> deleteClass(String classId) async {
    final batch = _firestore.batch();

    try {
      // 1. Delete class document
      final classRef = _firestore.collection('classes').doc(classId);
      batch.delete(classRef);

      // 2. Delete from class_student
      final studentSnapshot = await _firestore
          .collection('class_student')
          .where('class_id', isEqualTo: classId)
          .get();
      for (var doc in studentSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 3. Delete from class_assistant
      final assistantSnapshot = await _firestore
          .collection('class_assistant')
          .where('class_id', isEqualTo: classId)
          .get();
      for (var doc in assistantSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 4. Delete from class_belt
      final beltSnapshot = await _firestore
          .collection('class_belt')
          .where('class_id', isEqualTo: classId)
          .get();
      for (var doc in beltSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 4. Commit
      await batch.commit();

      // 5. Remove from local list and notify
      _ownerClasses.removeWhere((c) => c.id == classId);
      notifyListeners();

      return true;
    } catch (e) {
      print("🔥 Failed to delete class: $e");
      return false;
    }
  }
}
