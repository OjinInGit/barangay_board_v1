import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/app_constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are shown by the OS when the payload includes
  // a notification block. Data-only messages need local handling here if required.
}

class MessagingService {
  MessagingService._();
  static final MessagingService instance = MessagingService._();

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );
    if (Platform.isAndroid) {
      final plugin = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await plugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          AppConstants.fcmChannelId,
          AppConstants.fcmChannelName,
          importance: Importance.high,
        ),
      );
    }
    _initialized = true;
  }

  Future<void> requestPermissionIfNeeded() async {
    await _messaging.requestPermission();
  }

  Future<void> subscribeResidentTopics() async {
    await _messaging.subscribeToTopic(AppConstants.fcmTopicResidents);
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> showResidentForegroundAnnouncement({
    required String title,
    required String body,
  }) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.fcmChannelId,
          AppConstants.fcmChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  void listenForegroundMessages(void Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }
}
