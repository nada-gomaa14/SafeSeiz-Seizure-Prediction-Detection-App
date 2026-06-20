import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance =
  NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final bool? granted = await androidPlugin?.requestNotificationsPermission();
    debugPrint('Notification permission granted: $granted');
    _initialized = true;
  }

  Future<void> showSeizureNotification({
    required bool isSeizure,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'seizure_alerts',
      'Seizure Alerts',
      channelDescription: 'Notifications for seizure and pre-seizure detection',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF25148E),
      enableVibration: true,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    final String title = isSeizure
        ? 'Seizure Detected'
        : 'Pre-Seizure Warning';

    final String body = isSeizure
        ? 'A seizure has been detected. Your caregivers have been alerted.'
        : 'Pre-seizure signs detected. Your caregivers have been notified.';

    await _plugin.show(
      isSeizure ? 1 : 2,
      title,
      body,
      details,
    );
  }
}