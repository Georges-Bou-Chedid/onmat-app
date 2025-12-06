import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/Student.dart';

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

  void applyFilters({String? query, String? gender, String? classType, String? belt, RangeValues? ageRange}) {
    filtered = allStudents.where((s) {
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!(s.firstName!.toLowerCase().contains(q) || s.email!.toLowerCase().contains(q))) return false;
      }

      if (gender != null && s.gender != gender) return false;
      // if (classType != null && !s.classTypes.contains(classType)) return false;
      // if (belt != null && s.belt != belt) return false;

      if (ageRange != null) {
        // if (s.age < ageRange.start || s.age > ageRange.end) return false;
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
    return filtered.sublist(start, end);
  }

  int get total => filtered.length;

  int get pageStart => filtered.isEmpty ? 0 : (page * pageSize) + 1;
  int get pageEnd => ((page + 1) * pageSize).clamp(0, total);

  void nextPage() {
    if ((page + 1) * pageSize < filtered.length) {
      page++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (page > 0) {
      page--;
      notifyListeners();
    }
  }
}
