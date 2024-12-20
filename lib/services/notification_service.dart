import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'get_server_key.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('title: ${message.notification?.title}');
  print('body: ${message.notification?.body}');
  print('payload: ${message.data}');
}

class NotificationService
{
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    // navigate to the screen for the notification
    // to be implemented
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(
      settings,
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
      badge: true
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher'
            ),
          ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<void> initNotifications() async
  {
    await _firebaseMessaging.requestPermission();
    final FCMToken = await _firebaseMessaging.getToken();
    // should be saved in db with user
    print('fcm token = $FCMToken');
    initPushNotification();
    initLocalNotifications();
  }

  Future<String> getToken() async {
    final FCMToken = await _firebaseMessaging.getToken();
    return FCMToken!;
  }

Future<void> sendNotification({
  required String token,
  required String title,
  required String body,
}) async {
  final url = Uri.parse('https://fcm.googleapis.com/v1/projects/hedieaty-534ec/messages:send');
  final serverToken = await GetServerKey().getServerKeyToken();
  // print('server token $serverToken');
  final headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer $serverToken',
  };
  final payload = {
    "message":{
      "token": token,
      "notification":{
        "body": body,
        "title": title
      }
    }
  };

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully.');
    } else {
      print('Failed to send notification. Status: ${response.statusCode} + ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}
}