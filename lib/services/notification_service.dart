import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Inisialisasi untuk Android
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings: initSettings);

    _initialized = true;
    debugPrint('✅ NotificationService initialized');
  }

  Future<bool> requestPermission() async {
    // Untuk Android 13+ (API 33+)
    final android = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      debugPrint('Notification permission granted: $granted');
      return granted ?? false;
    }

    debugPrint('Notification permission: already granted or not needed');
    return true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Detail notifikasi untuk Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'findkost_channel',
          'FindKost Notifikasi',
          channelDescription: 'Notifikasi untuk booking kost',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );

    debugPrint('🔔 Notification shown: $title');
  }
}
