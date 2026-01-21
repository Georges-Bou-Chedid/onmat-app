class BeltTransaction {
  final String? id;
  final String instructorId;
  final String studentName;
  final String type; // 'belt_upgrade' or 'stripe_addition'
  final double amount;
  final String status; // 'pending', 'paid', 'failed'
  final DateTime timestamp;

  BeltTransaction({
    this.id,
    required this.instructorId,
    required this.studentName,
    required this.type,
    required this.amount,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'instructorId': instructorId,
    'studentName': studentName,
    'type': type,
    'amount': amount,
    'status': status,
    'timestamp': timestamp,
  };
}