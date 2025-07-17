import 'package:cloud_firestore/cloud_firestore.dart';

class Class {
  final String? ownerId;
  final String? className;
  final String? classType;
  final String? country;
  final String? location;
  final String? qrCode;

  Class({
    this.ownerId,
    this.className,
    this.classType,
    this.country,
    this.location,
    this.qrCode
  });

  // Factory method to convert data from Firebase to Class
  factory Class.fromFirestore(String id, Map<String, dynamic> map) {
    return Class(
      ownerId: id,
      className: map['class_name'] ?? '',
      classType: map['class_type'] ?? '',
      country: map['country'] ?? '',
      location: map['location'] ?? '',
      qrCode: map['qr_code'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'owner_id': ownerId,
      'class_name': className,
      'class_type': classType,
      'country': country,
      'location': location,
      'qr_code': qrCode,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp()
    };
  }

  Class copyWith(Map<String, dynamic> updateData) {
    return Class(
      ownerId: updateData['owner_id'] ?? ownerId,
      className: updateData['class_name'] ?? className,
      classType: updateData['class_type'] ?? classType,
      country: updateData['country'] ?? country,
      location: updateData['location'] ?? location,
      qrCode: updateData['qr_code'] ?? qrCode
    );
  }
}
