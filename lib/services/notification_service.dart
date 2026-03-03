import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// A utility that bundles Firebase Cloud Messaging initialization with the
/// local notifications plugin.  It also still contains a small helper to
/// seed and read messages from Firestore, which was present in the original
/// project and is harmless to keep around.
///
/// The primary purpose for this file in the current task is to provide an
/// easy way to show a random system notification when the user completes a
/// payment.  That notification is generated locally (no network request) but
/// the FCM setup means the app is already ready to receive remote messages
/// in the future.
class NotificationService {
  /// Allows tests to supply a fake Firestore instance.  If null the real
  /// `FirebaseFirestore.instance` is used.
  static FirebaseFirestore? _testInstance;

  /// Override the Firestore instance used by the service (testing only).
  ///
  /// Pass `null` to clear the override and return to the real
  /// `FirebaseFirestore.instance`.
  static void overrideFirestore(FirebaseFirestore? instance) {
    _testInstance = instance;
  }

  static FirebaseFirestore get _firestore => _testInstance ?? FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications').withConverter(
            fromFirestore: (snap, _) => snap.data() ?? {},
            toFirestore: (data, _) => data,
          );

  /// Default documents that should be created if missing.
  static const List<Map<String, String>> _defaults = [
    {
      'id': 'msg1',
      'message':
          'Your order has been successfully placed at Lankasmartmart! 🛍️'
    },
    {
      'id': 'msg2',
      'message': 'Your groceries are being packed carefully at Lankasmartmart.'
    },
    {
      'id': 'msg3',
      'message':
          'Your payment was completed successfully ✅'
    },
    {
      'id': 'msg4',
      'message':
          'Thanks for choosing Lankasmartmart 🧡'
    },
  ];

  /// Creates the defaults in Firestore if they do not yet exist.
  ///
  /// The method is idempotent and can be safely called multiple times. It only
  /// writes documents that are missing; existing documents are left
  /// untouched (so editing the message field in the console will take effect
  /// immediately without being overwritten).
  static Future<void> ensureDefaults() async {
    for (var item in _defaults) {
      final docRef = _collection.doc(item['id']);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        await docRef.set({'message': item['message']});
      }
    }
  }

  /// Returns a random notification message, or `null` when the collection is
  /// empty or contains no valid text entries.
  static Future<String?> getRandomMessage() async {
    try {
      final snapshot = await _collection.get();
      if (snapshot.docs.isEmpty) return null;

      final List<String> candidates = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // converter guarantees a non-null map, so we can directly inspect it
        final msg = data['message'];
        if (msg is String && msg.trim().isNotEmpty) {
          candidates.add(msg.trim());
        }
      }

      if (candidates.isEmpty) return null;
      candidates.shuffle(Random());
      return candidates.first;
    } catch (_) {
      // In case of any error (network, permission) just return null so the UI
      // can show a default message instead of crashing.
      return null;
    }
  }

  // ------------------------------------------------------------------
  // Firebase Messaging / local notifications implementation
  // ------------------------------------------------------------------

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _paymentChannel =
      AndroidNotificationChannel(
    'payment_channel',
    'Payment notifications',
    description: 'Channel used for payment success messages',
    importance: Importance.high,
  );

  /// The texts that may appear in the one notification we fire after a
  /// successful payment.  This list is shuffled each time so that the user
  /// sees a different message occasionally.
  static final List<String> _paymentMessages = [
    'Your payment has been successfully completed. ✅',
    'Great news! Your payment was successful. 🥳',
    'Your payment has been successfully verified and confirmed. 🔐',
    'Your order at Lankasmartmart is confirmed.',
  ];

  /// Initialize Firebase Messaging and the local notifications plugin.  This
  /// should be called from `main()` after `WidgetsFlutterBinding.ensureInitialized()`
  /// and `Firebase.initializeApp()`.
  static Future<void> initialize() async {
    // local notification plugin setup
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(settings: initSettings);

    // create android channel (no-op on other platforms)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_paymentChannel);

    // request permission (Android 13+ and iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // foreground/background handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // for demonstration: print token
    try {
      final token = await _messaging.getToken();
      // ignore: avoid_print
      print('FCM token: $token');
    } catch (_) {}
  }

  /// Background message handler required by `firebase_messaging`.  Must be
  /// a top-level or static function.
  static Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    await _showLocalNotification(message.notification?.title,
        message.notification?.body);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage msg) async {
    await _showLocalNotification(msg.notification?.title, msg.notification?.body);
  }

  static Future<void> _handleMessageOpenedApp(RemoteMessage msg) async {
    // could perform navigation here if needed
  }

  static Future<void> _showLocalNotification(String? title, String? body) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _paymentChannel.id,
        _paymentChannel.name,
        channelDescription: _paymentChannel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _localNotifications.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Public helper that immediately shows a randomized payment success
  /// notification.  Call after the payment flow completes.
  static Future<void> showPaymentSuccessNotification() async {
    final message = (_paymentMessages..shuffle()).first;
    await _showLocalNotification('Payment Success', message);
  }
}
