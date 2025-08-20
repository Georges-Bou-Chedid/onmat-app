import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/helper_functions.dart';

class Student {
  late String? userId;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? dob;
  final int? weight;
  final int? height;
  late String? email;
  final String? phoneNumber;
  final bool? notifications;

  // from class_student table
  final bool isActive;
  final bool hasAttendanceToday;

  Student({
    this.userId,
    this.firstName,
    this.lastName,
    this.username,
    this.dob,
    this.weight,
    this.height,
    this.email,
    this.phoneNumber,
    this.notifications,
    this.isActive = false,
    this.hasAttendanceToday = false,
  });

  // Factory method to convert data from Firebase to Account
  factory Student.fromFirestore(String id, Map<String, dynamic> map, {bool isActive = false, DateTime? attendanceAt}) {
    final now = DateTime.now();
    final attendanceToday = attendanceAt != null &&
        attendanceAt.year == now.year &&
        attendanceAt.month == now.month &&
        attendanceAt.day == now.day;

    return Student(
      userId: id,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      username: map['username'] ?? '',
      dob: map['dob'] ?? '',
      weight: THelperFunctions.parseInt(map['weight']),
      height: THelperFunctions.parseInt(map['height']),
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      notifications: map['notifications'] ?? false,
      isActive: isActive,
      hasAttendanceToday: attendanceToday,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'dob': dob,
      'weight': weight,
      'height': height,
      'email': email,
      'phone_number': phoneNumber,
      'notifications': notifications,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp()
    };
  }

  Student copyWith(Map<String, dynamic> updateData, {bool? isActiveOverride, bool? hasAttendanceTodayOverride}) {
    return Student(
      userId: updateData['user_id'] ?? userId,
      firstName: updateData['first_name'] ?? firstName,
      lastName: updateData['last_name'] ?? lastName,
      username: updateData['username'] ?? username,
      dob: updateData['dob'] ?? dob,
      weight: updateData['weight'] ?? weight,
      height: updateData['height'] ?? height,
      email: updateData['email'] ?? email,
      phoneNumber: updateData['phone_number'] ?? phoneNumber,
      notifications: updateData['notifications'] ?? notifications,
      isActive: isActiveOverride ?? isActive,
      hasAttendanceToday: hasAttendanceTodayOverride ?? hasAttendanceToday,
    );
  }
}
