import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:helpflutter/data/repositories/titbit_repository.dart';
import 'package:helpflutter/presentation/screens/extra/titbits_screen.dart';

/// Wraps all Firebase Cloud Messaging + local-notification setup for the
/// Titbit push feature.
///
/// The Firebase project for this app is still being provisioned — there is
/// no `google-services.json` / `GoogleService-Info.plist` yet, so
/// [Firebase.initializeApp] WILL fail on this device. Every method here is
/// written so that failure degrades gracefully: it's caught, logged, and
/// [isAvailable] simply stays false. Nothing in this class may ever throw
/// out to a caller — the Titbit inbox itself (backed by the REST endpoints)
/// works with zero push/Firebase setup; push is purely additive.
class PushService {
  PushService._();

  static bool _initialized = false;
  static bool _available = false;
  static GlobalKey<NavigatorState>? _navigatorKey;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'titbits_channel',
        'Updates & Alerts',
        description: 'Weather tips, hazard warnings and other Titbit updates.',
        importance: Importance.high,
      );

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// True once Firebase has successfully initialized on this device. Every
  /// other push-related call in the app should check this first.
  static bool get isAvailable => _available;

  /// Sets up Firebase + FCM + local notifications. Call this once at app
  /// startup (e.g. from `main()`), before `runApp`. Safe to call even if
  /// there's no Firebase project configured yet — it will simply leave
  /// [isAvailable] false and every other method a no-op.
  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) return;
    _initialized = true;
    _navigatorKey = navigatorKey;

    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (e) {
      _available = false;
      debugPrint(
        'PushService: Firebase.initializeApp() failed — push notifications '
        'disabled, rest of the app continues normally. ($e)',
      );
      return;
    }

    try {
      await _setupLocalNotifications();

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen((_) => _openInbox());

      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) _openInbox();
    } catch (e) {
      debugPrint('PushService: post-init FCM setup failed: $e');
    }
  }

  static Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (_) => _openInbox(),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  static void _openInbox() {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;
    navigator.push(MaterialPageRoute(builder: (_) => const TitbitsScreen()));
  }

  /// Requests notification permission, fetches this device's FCM token and
  /// registers it with the backend. Call once after a successful login, and
  /// on app start if the user is already logged in. Never throws — a
  /// failure here must never block login or normal app usage.
  static Future<void> registerDeviceToken(TitbitRepository repository) async {
    if (!_available) return;
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      final platform = Platform.isIOS ? 'ios' : 'android';
      await repository.registerDevice(token, platform);
    } catch (e) {
      debugPrint('PushService: device token registration failed: $e');
    }
  }
}
