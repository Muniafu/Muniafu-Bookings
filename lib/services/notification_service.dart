import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initFCM() async {
    await _fcm.requestPermission();
    final token = await _fcm.getToken();
    print("FCM Token: $token");
  }

  void onNotificationReceived(Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  void onNotificationOpened(Function(RemoteMessage) onOpen) {
    FirebaseMessaging.onMessageOpenedApp.listen(onOpen);
  }
}