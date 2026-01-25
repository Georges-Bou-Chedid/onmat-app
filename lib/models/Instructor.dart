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

  // --- NEW PROFILE FIELD ---
  String? profilePicture;

  // --- NEW FINANCIAL FIELDS ---
  final double outstandingBalance;
  final bool hasPaymentMethod;
  final bool isAccountSuspended;

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
    this.notifications,
    this.profilePicture,
    // Default values for new instructors
    this.outstandingBalance = 0.0,
    this.hasPaymentMethod = false,
    this.isAccountSuspended = false,
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
      notifications: map['notifications'] ?? false,

      // Mapping the Firestore field 'profile_picture' to the model
      profilePicture: map['profile_picture'],

      // Handle potential nulls and force double type
      outstandingBalance: ((map['outstanding_balance'] as num?) ?? 0.0).toDouble(),
      hasPaymentMethod: map['has_payment_method'] ?? false,
      isAccountSuspended: map['is_account_suspended'] ?? false,
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

      // Financial fields for DB
      'outstanding_balance': outstandingBalance,
      'has_payment_method': hasPaymentMethod,
      'is_account_suspended': isAccountSuspended,

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
        profilePicture: updateData['profile_picture'] ?? profilePicture,
        outstandingBalance: updateData['outstanding_balance'] ?? outstandingBalance,
        hasPaymentMethod: updateData['has_payment_method'] ?? hasPaymentMethod,
        isAccountSuspended: updateData['is_account_suspended'] ?? isAccountSuspended,
    );
  }
}
