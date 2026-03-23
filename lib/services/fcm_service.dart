import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

///  REQUIRED: Background handler must be TOP-LEVEL
@pragma('vm:entry-point')
Future<void> riderBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FCMService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1️ Request permission (iOS + Android 13+)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2⃣ Initialize local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 13+ runtime permission - Updated method name
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 3️ Register background handler
    FirebaseMessaging.onBackgroundMessage(riderBackgroundMessageHandler);

    // 4️ Foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 5 Notification tap (background)
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);

    // 6️ App terminated
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _onNotificationOpened(initialMessage);
    }

    // String? token = await _fcm.getToken();
    // print('RIDER FCM TOKEN: $token');
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  static Future<void> initializeRiderFCM({required String riderId}) async {
    await initialize();
    await subscribeToTopic('rider_assignments_$riderId');
    await subscribeToTopic('rider_delivery_updates_$riderId');
  }

  static void _onForegroundMessage(RemoteMessage message) {
    _showLocalNotification(
      message.notification?.title ?? 'New Delivery',
      message.notification?.body ?? '',
      message.data,
    );
  }

  static void _onNotificationOpened(RemoteMessage message) {
    // Logic for notification opening
  }

  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      // payload handling can be added here when needed
    }
  }

  static void _showLocalNotification(
      String title,
      String body,
      Map<String, dynamic> data,
      ) {
    const androidDetails = AndroidNotificationDetails(
      'rider_channel',
      'Rider Notifications',
      channelDescription: 'Delivery alerts for riders',
      importance: Importance.max,
      priority: Priority.high,
    );

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(data),
    );
  }

  static Future<String?> getToken() async => _fcm.getToken();

  static Future<void> unsubscribeAll(String riderId) async {
    await _fcm.unsubscribeFromTopic('rider_assignments_$riderId');
    await _fcm.unsubscribeFromTopic('rider_delivery_updates_$riderId');
  }
}
