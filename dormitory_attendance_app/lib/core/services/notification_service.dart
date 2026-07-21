import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Initialize Firebase messaging
    await _initializeFirebaseMessaging();
  }

  static Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();
    
    // Request Firebase messaging permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Handle notification tap when app is terminated
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    // Handle local notification tap
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message: ${message.notification?.title}');
    }
    
    // Show local notification for foreground messages
    showNotification(
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.data}');
    }
    // Handle navigation based on notification data
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'dormitory_attendance',
      'Dormitory Attendance',
      channelDescription: 'Notifications for dormitory attendance app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'dormitory_attendance',
      'Dormitory Attendance',
      channelDescription: 'Scheduled notifications for dormitory attendance',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert DateTime to TZDateTime
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Predefined notification types
  static Future<void> showAttendanceReminder() async {
    await showNotification(
      title: 'Attendance Reminder',
      body: 'Don\'t forget to mark your attendance today!',
      id: 1,
    );
  }

  static Future<void> showLateWarning() async {
    await showNotification(
      title: 'Late Warning',
      body: 'You are running late! Mark your attendance now.',
      id: 2,
    );
  }

  static Future<void> showAttendanceConfirmation() async {
    await showNotification(
      title: 'Attendance Confirmed',
      body: 'Your attendance has been successfully marked.',
      id: 3,
    );
  }

  static Future<void> scheduleCurfewReminder(DateTime curfewTime) async {
    final reminderTime = curfewTime.subtract(const Duration(minutes: 30));
    
    await scheduleNotification(
      title: 'Curfew Reminder',
      body: 'Curfew is in 30 minutes. Please return to the dormitory.',
      scheduledTime: reminderTime,
      id: 4,
    );
  }
}