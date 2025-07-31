import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onmat/models/ClassAssistant.dart';
import 'package:onmat/models/Instructor.dart';

class ClassAssistantService with ChangeNotifier {
  List<Instructor> _myAssistants = [];
  List<Instructor> get myAssistants => _myAssistants;

  Future<void> fetchAssistantProfiles(String classId) async {
    try {
      final classAssistants = await FirebaseFirestore.instance
          .collection('class_assistant')
          .where('class_id', isEqualTo: classId)
          .get();

      final assistantIds = classAssistants.docs
          .map((doc) => doc.data()['assistant_id'] as String)
          .toList();

      if (assistantIds.isEmpty) {
        _myAssistants = [];
        notifyListeners();
        return;
      }

      final instructors = await FirebaseFirestore.instance
          .collection('instructors')
          .where(FieldPath.documentId, whereIn: assistantIds)
          .get();

      _myAssistants = instructors.docs.map((doc) => Instructor.fromFirestore(doc.id, doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print("🔥 Error: $e");
      _myAssistants = [];
      notifyListeners();
    }
  }

  Future<bool> assignAssistantToClass(String? classId, String assistant) async {
    if (classId == null || assistant.trim().isEmpty) return false;

    final firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Try finding by email
      final emailQuery = await firestore
          .collection('instructors')
          .where('email', isEqualTo: assistant.trim())
          .limit(1)
          .get();

      DocumentSnapshot? instructorDoc;

      // Step 2: If not found by email, try username
      if (emailQuery.docs.isNotEmpty) {
        instructorDoc = emailQuery.docs.first;
      } else {
        final usernameQuery = await firestore
            .collection('instructors')
            .where('username', isEqualTo: assistant.trim())
            .limit(1)
            .get();

        if (usernameQuery.docs.isNotEmpty) {
          instructorDoc = usernameQuery.docs.first;
        }
      }

      if (instructorDoc == null) {
        print("❌ Assistant not found by email or username");
        return false;
      }

      final assistantId = instructorDoc.id;

      if (assistantId == FirebaseAuth.instance.currentUser?.uid) {
        print("❌ Assistant can't be the owner");
        return false;
      }

      // Step 3: check if assistant already assigned**
      final existing = await firestore
          .collection('class_assistant')
          .where('class_id', isEqualTo: classId)
          .where('assistant_id', isEqualTo: assistantId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        print("ℹ️ Assistant already assigned to this class");
        return false; // Or handle differently if you want (e.g. show message)
      }

      ClassAssistant ca = ClassAssistant(
        classId: classId,
        assistantId: assistantId,
      );
      await firestore.collection('class_assistant').add(ca.toMap());

      final instructorData = instructorDoc.data() as Map<String, dynamic>;
      _myAssistants.add(Instructor.fromFirestore(instructorDoc.id, instructorData));
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Error assigning assistant: $e");
      return false;
    }
  }

  Future<bool> removeAssistantFromClass(String? classId, String? assistantId) async {
    if (classId == null || assistantId == null) return false;

    try {
      final query = await  FirebaseFirestore.instance
        .collection('class_assistant')
        .where('class_id', isEqualTo: classId)
        .where('assistant_id', isEqualTo: assistantId)
        .limit(1)
        .get();

      if (query.docs.isEmpty) {
        print("❌ No class_assistant record found to delete");
        return false;
      }

      // Step 2: Delete the document
      await query.docs.first.reference.delete();

      // Step 3: Remove from _myAssistants
      _myAssistants.removeWhere((instructor) => instructor.userId == assistantId);
      notifyListeners();
      return true;
    } catch (e) {
      print("🔥 Error assigning assistant: $e");
      return false;
    }
  }
}
