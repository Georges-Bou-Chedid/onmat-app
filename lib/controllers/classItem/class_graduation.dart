import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/Belt.dart';

class ClassGraduationService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Belt> _myGradutationBelts = [];
  List<Belt> _originalBelts = [];
  List<Belt> get myGradutationBelts => _myGradutationBelts;

  StreamSubscription? _beltSubscription;

  void listenToClassBelts(String classId) {
    // cancel previous subscription if any
    _beltSubscription?.cancel();

    _beltSubscription = _firestore
        .collection('class_belt')
        .where('class_id', isEqualTo: classId)
        .orderBy('priority') // keep belts in order
        .snapshots()
        .listen((snapshot) {
      _myGradutationBelts = snapshot.docs.map((doc) {
        final data = doc.data();
        return Belt(
          id: data['id'] ?? doc.id,
          minAge: data['minAge'],
          maxAge: data['maxAge'],
          beltColor1: Belt.getColorFromName(data['beltColor1']),
          beltColor2: data['beltColor2'] != null ? Belt.getColorFromName(data['beltColor2']) : null,
          classesPerBeltOrStripe: data['classesPerStripe'],
          maxStripes: data['maxStripes'],
          priority: data['priority'] ?? 0,
        );
      }).toList();

      // Store a copy of the original belts
      _originalBelts = _myGradutationBelts.map((b) => b.copy()).toList();

      notifyListeners();
    }, onError: (e) {
      print("🔥 Error listening to belts: $e");
    });
  }

  void updateBeltOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final belt = _myGradutationBelts.removeAt(oldIndex);
    _myGradutationBelts.insert(newIndex, belt);

    // Reassign priorities
    for (var i = 0; i < _myGradutationBelts.length; i++) {
      _myGradutationBelts[i].priority = i + 1;
    }

    notifyListeners();
  }

  void removeBelt(int index) {
    _myGradutationBelts.removeAt(index);
    // Reassign priorities
    for (var i = 0; i < _myGradutationBelts.length; i++) {
      _myGradutationBelts[i].priority = i + 1;
    }
    notifyListeners();
  }

  void addBelt(Belt belt) {
    _myGradutationBelts.add(belt);
    notifyListeners();
  }

  void cancelChanges() {
    // Revert the list to the original stored copy
    _myGradutationBelts = _originalBelts.map((b) => b.copy()).toList();
    notifyListeners();
  }

  void cancelListener() {
    _beltSubscription?.cancel();
    _beltSubscription = null;
  }

  Future<bool> setBeltsForClass(String classId, List<Belt> belts) async {
    if (classId.isEmpty) return false;

    try {
      WriteBatch batch = _firestore.batch();

      // 1️⃣ Get existing belts for this class
      final existingBeltsSnapshot = await _firestore
          .collection('class_belt')
          .where('class_id', isEqualTo: classId)
          .get();

      // 2️⃣ Delete them
      for (var doc in existingBeltsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 3️⃣ Add new belts
      for (final belt in belts) {
        final docRef = _firestore.collection('class_belt').doc();
        batch.set(docRef, {
          "id": belt.id,
          "class_id": classId,
          "minAge": belt.minAge,
          "maxAge": belt.maxAge,
          "beltColor1": Belt.getColorName(belt.beltColor1),
          "beltColor2": belt.beltColor2 != null
              ? Belt.getColorName(belt.beltColor2!)
              : null,
          "classesPerStripe": belt.classesPerBeltOrStripe,
          "maxStripes": belt.maxStripes,
          "priority": belt.priority,
          "created_at": FieldValue.serverTimestamp(),
        });
      }

      // 4️⃣ Commit the batch
      await batch.commit();
      return true;
    } catch (e) {
      print("🔥 Error setting belts for class: $e");
      return false;
    }
  }
}
