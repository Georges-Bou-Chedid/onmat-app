import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/helper_functions.dart';

class Instructor {
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

  Instructor({
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
    this.notifications
  });

  // Factory method to convert data from Firebase to Account
  factory Instructor.fromFirestore(String id, Map<String, dynamic> map) {
    return Instructor(
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
      notifications: map['notifications'] ?? false
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
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp()
    };
  }

  Instructor copyWith(Map<String, dynamic> updateData) {
    return Instructor(
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
    );
  }
}
