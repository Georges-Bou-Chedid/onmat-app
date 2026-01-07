import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/Student.dart';
import '../../models/Belt.dart';

class GlobalStudentSearchService extends ChangeNotifier {
  List<Student> allStudents = [];
  List<Student> filtered = [];

  int page = 0;
  int pageSize = 10;

  bool isLoading = false;

  GlobalStudentSearchService() {
    loadStudents();
  }

  Future<void> loadStudents() async {
    isLoading = true;
    notifyListeners();

    final snapshot = await FirebaseFirestore.instance.collection('students').get();

    allStudents = snapshot.docs.map((d) => Student.fromFirestore(d.id, d.data())).toList();

    filtered = allStudents;
    isLoading = false;
    notifyListeners();
  }

  /// Calculate age from DOB string (format: dd/MM/yyyy)
  int calculateAge(String? dobString) {
    if (dobString == null || dobString.isEmpty) return 0;

    try {
      final parts = dobString.split('/');
      if (parts.length != 3) return 0;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();

      int age = today.year - birthDate.year;

      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age;
    } catch (e) {
      return 0;
    }
  }

  void applyFilters({
    String? query,
    String? gender,
    String? classType,
    Color? belt1Color,
    Color? belt2Color,
    RangeValues? ageRange,
  }) {
    filtered = allStudents.where((s) {
      // Text search (name or email)
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final firstName = s.firstName?.toLowerCase() ?? '';
        final lastName = s.lastName?.toLowerCase() ?? '';
        final email = s.email?.toLowerCase() ?? '';

        if (!(firstName.contains(q) || lastName.contains(q) || email.contains(q))) {
          return false;
        }
      }

      // Gender filter
      if (gender != null && gender.isNotEmpty) {
        if (s.gender?.toLowerCase() != gender.toLowerCase()) return false;
      }

      // Class type filter (assuming student has classTypes field)
      // Adjust this based on your actual Student model structure
      if (classType != null && classType.isNotEmpty) {
        // If your Student has a classType field (string):
        // if (s.classType?.toLowerCase() != classType.toLowerCase()) return false;

        // If your Student has a classTypes field (list):
        // if (s.classTypes == null || !s.classTypes!.any((ct) => ct.toLowerCase() == classType.toLowerCase())) return false;
      }

      // Belt 1 filter (primary belt color)
      if (belt1Color != null) {
        if (s.belt1 == null || s.belt1!.value != belt1Color.value) return false;
      }

      // Belt 2 filter (secondary belt color)
      if (belt2Color != null) {
        if (s.belt2 == null || s.belt2!.value != belt2Color.value) return false;
      }

      // Age range filter
      if (ageRange != null) {
        final studentAge = calculateAge(s.dob);
        if (studentAge < ageRange.start.round() || studentAge > ageRange.end.round()) {
          return false;
        }
      }

      return true;
    }).toList();

    page = 0;
    notifyListeners();
  }

  /// Pagination logic
  List<Student> get paginatedResults {
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

  void nextPage() {
    if (canGoNext) {
      page++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (canGoPrevious) {
      page--;
      notifyListeners();
    }
  }

  void resetFilters() {
    filtered = allStudents;
    page = 0;
    notifyListeners();
  }
}
