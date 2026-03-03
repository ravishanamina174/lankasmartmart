import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper for managing in-app notifications stored in Firestore.
///
/// The application uses a single collection called `notifications`. Documents
/// can have arbitrary ids ("msg1", "msg5", etc) and must include a
/// `message` field with a non-empty string. The service will automatically
/// ensure four default entries exist the first time the app starts.
///
/// Usage:
/// ```dart
/// await NotificationService.ensureDefaults();
/// final msg = await NotificationService.getRandomMessage();
/// ```
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
}
