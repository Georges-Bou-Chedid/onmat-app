import 'package:cloud_firestore/cloud_firestore.dart';

class Class {
  final String? ownerId;
  final String? className;
  final String? classType;
  final String? country;
  final String? location;
  final String? qrCode;
  final List<Map<String, String>>? schedule;

  Class({
    this.ownerId,
    this.className,
    this.classType,
    this.country,
    this.location,
    this.qrCode,
    this.schedule
  });

  // Factory method to convert data from Firebase to Class
  factory Class.fromFirestore(String id, Map<String, dynamic> data) {
    List<Map<String, String>>? parsedSchedule;
    if (data['schedule'] != null) {
      parsedSchedule = (data['schedule'] as List<dynamic>)
          .map((item) => Map<String, String>.from(item as Map))
          .toList();
    }

    return Class(
      ownerId: id,
      className: data['class_name'] ?? '',
      classType: data['class_type'] ?? '',
      country: data['country'] ?? '',
      location: data['location'] ?? '',
      qrCode: data['qr_code'] ?? '',
      schedule: parsedSchedule
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
      'schedule': schedule,
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
      qrCode: updateData['qr_code'] ?? qrCode,
      schedule: updateData['schedule'] ?? schedule
    );
  }
}
