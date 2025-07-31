import 'package:cloud_firestore/cloud_firestore.dart';

class ClassAssistant {
  final String? id;
  final String? classId;
  final String? assistantId;

  ClassAssistant({
    this.id,
    this.classId,
    this.assistantId,
  });

  factory ClassAssistant.fromFirestore(String id, Map<String, dynamic> map) {
    return ClassAssistant(
      id: id,
      classId: map['class_id'],
      assistantId: map['assistant_id']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'class_id': classId,
      'assistant_id': assistantId,
      'assigned_at': FieldValue.serverTimestamp(),
    };
  }
}
