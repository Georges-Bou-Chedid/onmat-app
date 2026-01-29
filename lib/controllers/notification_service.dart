import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  StreamSubscription? _subscription;

  /// Starts listening to real-time updates for unread notifications
  void listenToNotifications(String userId) {
    // Cancel any existing subscription before starting a new one
    _subscription?.cancel();

    _subscription = _firestore
        .collection('notifications')
        .where('receiver_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      _unreadCount = snapshot.docs.length;
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error listening to notifications: $error");
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}