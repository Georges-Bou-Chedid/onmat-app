import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/helper_functions.dart';

class Student {
  late String? userId;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? username;
  final String? dob;
  final int? weight;
  final int? height;
  late String? email;
  final String? phoneNumber;
  final bool? notifications;

  // --- NEW PROFILE FIELD ---
  String? profilePicture;

  // from class_student table
  final bool isActive;
  final bool hasAttendanceToday;
  final int classAttended;
  final Color belt1;
  final Color? belt2;
  final int stripes;

  Student({
    this.userId,
    this.firstName,
    this.lastName,
    this.gender,
    this.username,
    this.dob,
    this.weight,
    this.height,
    this.email,
    this.phoneNumber,
    this.notifications,
    this.profilePicture,
    this.isActive = false,
    this.hasAttendanceToday = false,
    this.classAttended = 0,
    this.belt1 = Colors.white,
    this.belt2,
    this.stripes = 0
  });

  // Factory method to convert data from Firebase to Account
  factory Student.fromFirestore(
      String id, Map<String,
      dynamic> map,
      {bool isActive = false, DateTime? attendanceAt, int classAttended = 0, Color belt1 = Colors.white, Color? belt2, int stripes = 0}
  ) {
    final now = DateTime.now();
    final attendanceToday = attendanceAt != null &&
        attendanceAt.year == now.year &&
        attendanceAt.month == now.month &&
        attendanceAt.day == now.day;

    return Student(
      userId: id,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      gender: map['gender'] ?? '',
      username: map['username'] ?? '',
      dob: map['dob'] ?? '',
      weight: THelperFunctions.parseInt(map['weight']),
      height: THelperFunctions.parseInt(map['height']),
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      notifications: map['notifications'] ?? false,
      // Mapping the Firestore field 'profile_picture' to the model
      profilePicture: map['profile_picture'],
      isActive: isActive,
      hasAttendanceToday: attendanceToday,
      classAttended: classAttended,
      belt1: belt1,
      belt2: belt2,
      stripes: stripes
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'username': username,
      'dob': dob,
      'weight': weight,
      'height': height,
      'email': email,
      'phone_number': phoneNumber,
      'notifications': notifications,
      // Save profile picture URL to Firestore
      'profile_picture': profilePicture,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp()
    };
  }

  Student copyWith(
      Map<String, dynamic> updateData,
      {bool? isActiveOverride, bool? hasAttendanceTodayOverride, int? classAttendedOverride}
  ) {
    return Student(
      userId: updateData['user_id'] ?? userId,
      firstName: updateData['first_name'] ?? firstName,
      lastName: updateData['last_name'] ?? lastName,
      gender: updateData['gender'] ?? gender,
      username: updateData['username'] ?? username,
      dob: updateData['dob'] ?? dob,
      weight: updateData['weight'] ?? weight,
      height: updateData['height'] ?? height,
      email: updateData['email'] ?? email,
      phoneNumber: updateData['phone_number'] ?? phoneNumber,
      notifications: updateData['notifications'] ?? notifications,
      profilePicture: updateData['profile_picture'] ?? profilePicture,
      isActive: isActiveOverride ?? isActive,
      hasAttendanceToday: hasAttendanceTodayOverride ?? hasAttendanceToday,
      classAttended: classAttendedOverride ?? classAttended,
    );
  }
}
