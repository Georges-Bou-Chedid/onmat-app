import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../utils/helpers/helper_functions.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          // Clear All Button
          TextButton(
            onPressed: () => _markAllAsRead(uid),
            child: const Text("Mark all as read", style: TextStyle(color: Color(0xFFDF1E42))),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiver_id', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.notification_status, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("All caught up!", style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final bool isRead = data['is_read'] ?? false;

              return Container(
                decoration: BoxDecoration(
                  color: isRead ? Colors.transparent : (dark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(12),
                  border: isRead ? Border.all(color: Colors.grey.withOpacity(0.2)) : null,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isRead ? Colors.grey[300] : const Color(0xFFDF1E42),
                    child: Icon(
                        _getIconForType(data['type']),
                        color: Colors.white,
                        size: 20
                    ),
                  ),
                  title: Text(
                      data['title'],
                      style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 14
                      )
                  ),
                  subtitle: Text(data['message'], style: const TextStyle(fontSize: 12)),
                  onTap: () async {
                    await docs[index].reference.update({'is_read': true});
                    _handleTap(data);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper to change icon based on why they were notified
  IconData _getIconForType(String? type) {
    switch (type) {
      case 'join_request': return Iconsax.user_add;
      case 'promotion': return Iconsax.award;
      default: return Iconsax.notification;
    }
  }

  // Handle Mark All as Read
  Future<void> _markAllAsRead(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    final unread = await FirebaseFirestore.instance
        .collection('notifications')
        .where('receiver_id', isEqualTo: uid)
        .where('is_read', isEqualTo: false)
        .get();

    for (var doc in unread.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  void _handleTap(Map<String, dynamic> data) {
    // If it's a join request, we could navigate to that class's student list
    if (data['type'] == 'join_request' && data['class_id'] != null) {
      // Get.to(() => ClassStudentListScreen(classId: data['class_id']));
    }
  }
}