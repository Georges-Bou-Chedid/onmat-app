import 'package:intl/intl.dart';

class UserAccount {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? role;

  UserAccount({
    this.userId,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.phoneNumber,
    this.role,
  });

  // Factory method to convert data from Firebase to Account
  factory UserAccount.fromListMap(String id, Map<String, dynamic> map) {
    return UserAccount(
      userId: id,
      firstName: map['first_name'],
      lastName: map['last_name'],
      username: map['username'],
      email: map['email'],
      phoneNumber: map['phone_number'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'created_at': getTimestamp(),
      'updated_at': getTimestamp()
    };
  }

  UserAccount copyWith(Map<String, dynamic> updateData) {
    return UserAccount(
        userId: updateData['user_id'] ?? userId,
        firstName: updateData['first_name'] ?? firstName,
        lastName: updateData['last_name'] ?? lastName,
        username: updateData['username'] ?? username,
        email: updateData['email'] ?? email,
        phoneNumber: updateData['phone_number'] ?? phoneNumber,
        role: updateData['role'] ?? role,
    );
  }
}

String getTimestamp() {
  final now = DateTime.now();
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
}
