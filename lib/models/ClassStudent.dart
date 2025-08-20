import 'package:cloud_firestore/cloud_firestore.dart';

class ClassStudent {
  final String? id;
  final String? classId;
  final String? studentId;
  final bool? isActive;
  final int? classAttended;
  final DateTime? attendanceAt;

  ClassStudent({
    this.id,
    this.classId,
    this.studentId,
    this.isActive,
    this.classAttended,
    this.attendanceAt,
  });

  factory ClassStudent.fromFirestore(String id, Map<String, dynamic> map) {
    return ClassStudent(
      id: id,
      classId: map['class_id'],
      studentId: map['student_id'],
      isActive: map['is_active'] ?? false,
      classAttended: map['class_attended'] ?? 0,
      attendanceAt: map['attendance_at'] != null
          ? (map['attendance_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'class_id': classId,
      'student_id': studentId,
      'is_active': isActive ?? false,
      'class_attended': classAttended ?? 0,
      'attendance_at': attendanceAt != null
          ? Timestamp.fromDate(attendanceAt!)
          : null,
      'assigned_at': FieldValue.serverTimestamp(),
    };
  }
}
