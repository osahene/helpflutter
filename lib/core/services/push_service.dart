import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:helpflutter/data/repositories/titbit_repository.dart';
import 'package:helpflutter/presentation/screens/extra/incoming_alert_screen.dart';
import 'package:helpflutter/presentation/screens/extra/titbits_screen.dart';

/// Payload prefix used for locally-shown "incoming alert" notifications, so
/// [PushService._routeForPayload] can tell them apart from a plain Titbit
/// notification (which carries no payload at all) when tapped.
const String _incomingAlertPayloadPrefix = 'incoming_alert:';

const AndroidNotificationChannel _incomingAlertAndroidChannel =
    AndroidNotificationChannel(
      'incoming_alert_channel',
      'Incoming Emergency Alerts',
      description:
          "Urgent, full-screen alerts when one of your emergency contacts "
          'triggers an emergency — shown like an incoming call.',
      importance: Importance.max,
    );

/// FCM background message handler. Required to be a top-level (or static)
/// function annotated with `@pragma('vm:entry-point')` — the Firebase Android
/// SDK spins this up on its own background isolate when a data message
/// arrives while the app is backgrounded OR fully killed, so it can't reuse
/// any state from [PushService] (statics/const values are fine; anything
/// stateful, e.g. the navigator, is not — there is no UI to navigate here).
///
/// Only acts on `type: incoming_alert` messages: it shows a local
/// notification on a maximum-urgency channel with `fullScreenIntent: true`,
/// which is what lets Android launch [IncomingAlertScreen] straight over the
/// lock screen even when the app process wasn't running at all. Every other
/// push type (e.g. Titbits) is left alone here — those already rely on FCM
/// auto-displaying their own `notification` payload block when the app isn't
/// in the foreground, which this handler must not interfere with.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] != 'incoming_alert') return;

  final emergencyId = message.data['emergency_id'] as String?;
  if (emergencyId == null || emergencyId.isEmpty) return;

  try {
    await Firebase.initializeApp();

    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    await localNotifications.initialize(
      settings: const InitializationSettings(android: androidInit),
    );
    await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_incomingAlertAndroidChannel);

    await localNotifications.show(
      id: emergencyId.hashCode,
      title: 'Incoming emergency alert',
      body: 'One of your emergency contacts needs help. Tap to view.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _incomingAlertAndroidChannel.id,
          _incomingAlertAndroidChannel.name,
          channelDescription: _incomingAlertAndroidChannel.description,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.call,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
        ),
      ),
      payload: '$_incomingAlertPayloadPrefix$emergencyId',
    );
  } catch (e) {
    debugPrint(
      'PushService: background incoming-alert notification failed: $e',
    );
  }
}

/// Wraps all Firebase Cloud Messaging + local-notification setup for the
/// Titbit push feature, and the "incoming call"-style emergency alert push.
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

  /// Maximum-urgency channel for `type: incoming_alert` pushes — distinct
  /// from [_androidChannel] so it can't be silenced/downgraded by a user who
  /// muted the calmer Titbit channel, and so it can carry `fullScreenIntent`.
  static const AndroidNotificationChannel _incomingAlertChannel =
      _incomingAlertAndroidChannel;

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

      // Background/terminated delivery for `type: incoming_alert` pushes —
      // this is what lets the full-screen intent fire even when the app
      // process wasn't running at all. Must be a top-level function; see its
      // doc comment above.
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_routeForMessage);

      // Cold start via FCM's own auto-displayed notification (the path
      // Titbit pushes — which carry a `notification` block — use today).
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) _routeForMessage(initialMessage);

      // Cold start via OUR OWN full-screen-intent local notification (the
      // path incoming-alert pushes use, since they're shown by
      // [firebaseMessagingBackgroundHandler] via flutter_local_notifications,
      // not by FCM's auto-display — so `getInitialMessage()` above never
      // sees them).
      final launchDetails = await _localNotifications
          .getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        _routeForPayload(launchDetails!.notificationResponse?.payload);
      }
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
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (response) =>
          _routeForPayload(response.payload),
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_androidChannel);
    await androidPlugin?.createNotificationChannel(_incomingAlertChannel);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'incoming_alert') {
      _handleIncomingAlertForeground(message);
      return;
    }

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

  /// Foreground delivery of a `type: incoming_alert` push. Unlike the
  /// generic Titbit path, this must interrupt immediately — like a real
  /// incoming call — rather than wait for the user to notice/tap a banner,
  /// so it navigates straight to [IncomingAlertScreen]. It also still fires
  /// an urgent local notification (max-importance channel) alongside that,
  /// so there's an audible/vibration signal too.
  static void _handleIncomingAlertForeground(RemoteMessage message) {
    final emergencyId = message.data['emergency_id'] as String?;
    if (emergencyId == null || emergencyId.isEmpty) return;

    _openIncomingAlert(emergencyId);

    _localNotifications.show(
      id: emergencyId.hashCode,
      title: 'Incoming emergency alert',
      body: 'One of your emergency contacts needs help.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _incomingAlertChannel.id,
          _incomingAlertChannel.name,
          channelDescription: _incomingAlertChannel.description,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.call,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: '$_incomingAlertPayloadPrefix$emergencyId',
    );
  }

  /// Routes a tapped/opened [RemoteMessage] — used by both
  /// `onMessageOpenedApp` (tapped while backgrounded) and the cold-start
  /// `getInitialMessage()` check. Opens [IncomingAlertScreen] for
  /// `type: incoming_alert`; otherwise falls back to the Titbit inbox,
  /// exactly as before this feature existed.
  static void _routeForMessage(RemoteMessage message) {
    if (message.data['type'] == 'incoming_alert') {
      final emergencyId = message.data['emergency_id'] as String?;
      if (emergencyId != null && emergencyId.isNotEmpty) {
        _openIncomingAlert(emergencyId);
        return;
      }
    }
    _openInbox();
  }

  /// Routes a tapped/launched local notification by its payload — used by
  /// both a warm tap (`onDidReceiveNotificationResponse`) and a cold start
  /// via our own full-screen-intent notification
  /// (`getNotificationAppLaunchDetails()`). A plain Titbit local
  /// notification carries no payload, so it always falls through to
  /// [_openInbox], unchanged from before this feature existed.
  static void _routeForPayload(String? payload) {
    if (payload != null && payload.startsWith(_incomingAlertPayloadPrefix)) {
      final emergencyId = payload.substring(_incomingAlertPayloadPrefix.length);
      if (emergencyId.isNotEmpty) {
        _openIncomingAlert(emergencyId);
        return;
      }
    }
    _openInbox();
  }

  static void _openInbox() {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;
    navigator.push(MaterialPageRoute(builder: (_) => const TitbitsScreen()));
  }

  static void _openIncomingAlert(String emergencyId) {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;
    navigator.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => IncomingAlertScreen(emergencyId: emergencyId),
      ),
    );
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
