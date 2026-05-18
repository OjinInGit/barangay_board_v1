import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/app_constants.dart';
import '../firebase_options.dart';

/// Handles FCM messages when the app is in the background or terminated.
/// Console campaigns must include a **Notification** title/body (not data-only).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final service = MessagingService.instance;
  await service.initialize();
  await service.displayRemoteMessage(message);
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

  /// Residents receive Console / topic pushes on this FCM topic.
  Future<void> subscribeResidentTopics() async {
    await _messaging.subscribeToTopic(AppConstants.fcmTopicResidents);
  }

  Future<String?> getToken() => _messaging.getToken();

  /// Title/body from FCM notification fields or custom data (Console optional data).
  ({String title, String body}) resolveMessageContent(RemoteMessage message) {
    final data = message.data;
    final title = message.notification?.title ??
        data['title'] ??
        AppConstants.appName;
    final body = message.notification?.body ??
        data['body'] ??
        data['message'] ??
        '';
    return (title: title, body: body);
  }

  /// Shows a tray notification for FCM (foreground helper and background/data-only).
  Future<void> displayRemoteMessage(RemoteMessage message) async {
    await initialize();
    final content = resolveMessageContent(message);
    if (content.body.trim().isEmpty) return;
    await showResidentForegroundAnnouncement(
      title: content.title,
      body: content.body,
    );
  }

  Future<void> showResidentForegroundAnnouncement({
    required String title,
    required String body,
  }) async {
    await initialize();
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
