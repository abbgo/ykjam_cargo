import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ykjam_cargo/pages/statute_page.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    // Notification android ucin ulanyljak bolsa asakdakyny ulanmaly --------
    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInitializationSettings = DarwinInitializationSettings();

    var initializationSettings = const InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print("-------------------- init firebase message");
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
      }

      if (Platform.isIOS) {
        foregroundMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(message);
      } /* else {
        showNotification(message);
      }*/
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      "High Important Notification",
      importance: Importance.high,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidNotificationChannel.id.toString(),
      androidNotificationChannel.name,
      channelDescription: 'Your Channel Description',
    );

    DarwinNotificationDetails iosNotificationDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getAPNSToken();
    return token ?? "token not found";
  }

  void isRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // ignore: use_build_context_synchronously
      handleMessage(context, initialMessage);
    }

    // when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'msl') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const StatutePage()));
    }
  }

  Future foregroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
