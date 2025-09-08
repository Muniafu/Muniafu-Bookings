import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muniafu/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  // Fetch notifications for a specific user
  Stream<List<NotificationModel>> listenToUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Listen to a global count for unread notifications(for admin)
  Stream<int> listenToUnreadNotificationCount() {
    return _firestore
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}