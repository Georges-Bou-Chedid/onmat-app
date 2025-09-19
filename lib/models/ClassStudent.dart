import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ClassStudent {
  final String? id;
  final String? classId;
  final String? studentId;
  final bool? isActive;
  final int? classAttended;
  final DateTime? attendanceAt;
  final Color? belt1;
  final Color? belt2;
  final int? stripes;

  ClassStudent({
    this.id,
    this.classId,
    this.studentId,
    this.isActive,
    this.classAttended,
    this.attendanceAt,
    this.belt1,
    this.belt2,
    this.stripes
  });

  Map<String, dynamic> toMap() {
    return {
      'class_id': classId,
      'student_id': studentId,
      'is_active': isActive ?? false,
      'class_attended': classAttended ?? 0,
      'attendance_at': attendanceAt != null
          ? Timestamp.fromDate(attendanceAt!)
          : null,
      'belt1': belt1 ?? "White",
      'belt2': belt2,
      'stripes': stripes ?? 0,
      'assigned_at': FieldValue.serverTimestamp(),
    };
  }
}
