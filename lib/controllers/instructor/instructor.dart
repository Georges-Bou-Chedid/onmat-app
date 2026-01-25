import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../models/Instructor.dart';

class InstructorService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Instructor? _instructor;

  Instructor? get instructor => _instructor;

  InstructorService() {
    _listenToInstructor();
  }

  void _listenToInstructor() {
    final user = _auth.currentUser;
    if (user != null) {
      // This creates a permanent pipe between Firestore and your App
      _firestore.collection('instructors').doc(user.uid).snapshots().listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          _instructor = Instructor.fromFirestore(snapshot.id, snapshot.data()!);

          // This is the magic line that updates the Settings & Wallet screens instantly
          notifyListeners();
        }
      });
    }
  }

  Future<bool> fetchAndSetInstructor(String instructorId) async {
    try {
      final doc = await _firestore
          .collection('instructors')
          .doc(instructorId)
          .get();

      if (doc.exists) {
        _instructor = Instructor.fromFirestore(instructorId, doc.data()!);
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

  Future<bool> updateFields(String? instructorId, Map<String, dynamic> changes) async {
    try {
      if (instructorId == null) {
        return false;
      }
      changes.removeWhere((_, value) => value == null);
      changes['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('instructors')
          .doc(instructorId)
          .set(changes, SetOptions(merge: true));

      _instructor = _instructor?.copyWith(changes);
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Failed to update instructor: $e");
      return false;
    }
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('instructors/${instructor!.userId}/profile.jpg');

      // Upload
      await storageRef.putFile(imageFile);

      // Get URL
      String downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore
      await updateFields(instructor!.userId, {'profile_picture': downloadUrl});

      // Update local instructor object so UI refreshes
      instructor!.profilePicture = downloadUrl;
      notifyListeners();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePaymentMethodStatus(bool hasCard) async {
    final instructorId = _auth.currentUser!.uid;
    try {
      await _firestore.collection('instructors').doc(instructorId).update({
        'has_payment_method': hasCard,
      });
      // This will trigger the WalletScreen UI to change from "Add Card" to "Pay Now"
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to update payment method: $e");
    }
  }

  Future<bool> settleOutstandingBalance() async {
    final instructorId = _auth.currentUser!.uid;
    final batch = _firestore.batch();

    try {
      // 1. Get all pending transactions
      final snapshot = await _firestore.collection('transactions')
          .where('instructor_id', isEqualTo: instructorId)
          .where('status', isEqualTo: 'pending')
          .get();

      // 2. Mark each as paid
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'status': 'paid'});
      }

      // 3. Reset the instructor balance
      batch.update(_firestore.collection('instructors').doc(instructorId), {
        'outstanding_balance': 0.0,
        'is_account_suspended': false // Unlock account if it was locked
      });

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }
}
