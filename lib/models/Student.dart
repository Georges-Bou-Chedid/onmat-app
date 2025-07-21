import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/helpers/helper_functions.dart';

class Student {
  late String? userId;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? dob;
  final int? weight;
  late String? email;
  final String? phoneNumber;
  final bool? notifications;

  Student({
    this.userId,
    this.firstName,
    this.lastName,
    this.username,
    this.dob,
    this.weight,
    this.email,
    this.phoneNumber,
    this.notifications
  });

  // Factory method to convert data from Firebase to Account
  factory Student.fromFirestore(String id, Map<String, dynamic> map) {
    return Student(
      userId: id,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      username: map['username'] ?? '',
      dob: map['dob'] ?? '',
      weight: THelperFunctions.parseInt(map['weight']),
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
      'username': username,
      'dob': dob,
      'weight': weight,
      'email': email,
      'phone_number': phoneNumber,
      'notifications': notifications,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp()
    };
  }

  Student copyWith(Map<String, dynamic> updateData) {
    return Student(
        userId: updateData['user_id'] ?? userId,
        firstName: updateData['first_name'] ?? firstName,
        lastName: updateData['last_name'] ?? lastName,
        username: updateData['username'] ?? username,
        dob: updateData['dob'] ?? dob,
        weight: updateData['weight'] ?? weight,
        email: updateData['email'] ?? email,
        phoneNumber: updateData['phone_number'] ?? phoneNumber,
        notifications: updateData['notifications'] ?? notifications,
    );
  }
}
