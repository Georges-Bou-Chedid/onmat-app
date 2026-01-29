import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/Belt.dart';

class GlobalStudentSearchService extends ChangeNotifier {
// Now we store Maps to hold the joined data (Student + Enrollment + Class)
  List<Map<String, dynamic>> allEnrollments = [];
  List<Map<String, dynamic>> filtered = [];

  int page = 0;
  int pageSize = 10;
  bool isLoading = false;

  GlobalStudentSearchService() {
    loadStudents();
  }

  Future<void> loadStudents() async {
    isLoading = true;
    notifyListeners();

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Fetch all relevant collections in parallel
      final results = await Future.wait([
        firestore.collection('class_student').get(),
        firestore.collection('students').get(),
        firestore.collection('classes').get(),
      ]);

      final enrollmentDocs = results[0] as QuerySnapshot;
      final studentDocs = results[1] as QuerySnapshot;
      final classDocs = results[2] as QuerySnapshot;

      // 2. Map data for quick O(1) lookup
      final Map<String, dynamic> studentMap = {
        for (var d in studentDocs.docs) d.id: d.data()
      };
      final Map<String, dynamic> classMap = {
        for (var d in classDocs.docs) d.id: d.data()
      };

      // 3. Create a combined list (The "Join")
      allEnrollments = enrollmentDocs.docs.map((doc) {
        final enrollment = doc.data() as Map<String, dynamic>;
        final sId = enrollment['student_id'];
        final cId = enrollment['class_id'];
        final sData = studentMap[sId] ?? {};
        final cData = classMap[cId] ?? {};

        return {
          'enrollment_id': doc.id,
          'student_id': sId,
          'class_id': cId,
          'class_name': cData['class_name'] ?? 'Unknown Class',
          'class_type': cData['class_type'] ?? '',
          'first_name': sData['first_name'] ?? '',
          'last_name': sData['last_name'] ?? '',
          'email': sData['email'] ?? '',
          'gender': sData['gender'] ?? '',
          'dob': sData['dob'] ?? '',
          'profile_picture': sData['profile_picture'] ?? '',
          // Rank details are SPECIFIC to this enrollment/class
          'belt1': Belt.getColorFromName(enrollment['belt1']),
          'belt2': enrollment['belt2'] != null ? Belt.getColorFromName(enrollment['belt2']) : null,
          'stripes': enrollment['stripes'] ?? 0,
        };
      }).toList();

      filtered = allEnrollments;
    } catch (e) {
      debugPrint("Error loading global search: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Calculate age from DOB string (format: dd/MM/yyyy)
  int calculateAge(String? dobString) {
    if (dobString == null || dobString.isEmpty) return 0;
    try {
      final parts = dobString.split('/');
      if (parts.length != 3) return 0;
      final birthDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) age--;
      return age;
    } catch (e) { return 0; }
  }

  void applyFilters({
    String? query,
    String? gender,
    String? classType,
    Color? belt1Color,
    Color? belt2Color,
    RangeValues? ageRange,
  }) {
    filtered = allEnrollments.where((s) {
      // 1. Text search
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!("${s['first_name']} ${s['last_name']} ${s['email']}".toLowerCase().contains(q))) return false;
      }

      // 2. Gender filter
      if (gender != null && gender.isNotEmpty) {
        if (s['gender'].toString().toLowerCase() != gender.toLowerCase()) return false;
      }

      // 3. Class type filter (Now filtering by the actual class type)
      if (classType != null && classType.isNotEmpty) {
        if (s['class_type'].toString().toLowerCase() != classType.toLowerCase()) return false;
      }

      // 4. Belt filters (Specific to this class enrollment)
      if (belt1Color != null) {
        if ((s['belt1'] as Color).value != belt1Color.value) return false;
      }
      if (belt2Color != null) {
        if (s['belt2'] == null || (s['belt2'] as Color).value != belt2Color.value) return false;
      }

      // 5. Age range filter
      if (ageRange != null) {
        final studentAge = calculateAge(s['dob']);
        if (studentAge < ageRange.start.round() || studentAge > ageRange.end.round()) return false;
      }

      return true;
    }).toList();

    page = 0;
    notifyListeners();
  }

  /// Pagination logic
  List<Map<String, dynamic>> get paginatedResults {
    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  int get total => filtered.length;
  int get pageStart => filtered.isEmpty ? 0 : (page * pageSize) + 1;
  int get pageEnd => ((page + 1) * pageSize).clamp(0, total);
  bool get canGoNext => (page + 1) * pageSize < filtered.length;
  bool get canGoPrevious => page > 0;

  void nextPage() { if (canGoNext) { page++; notifyListeners(); } }
  void previousPage() { if (canGoPrevious) { page--; notifyListeners(); } }

  void resetFilters() {
    filtered = allEnrollments;
    page = 0;
    notifyListeners();
  }
}
