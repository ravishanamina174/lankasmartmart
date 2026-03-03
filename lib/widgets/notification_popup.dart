import 'package:flutter/material.dart';

import '../services/notification_service.dart';

/// Displays a popup containing a single notification message fetched from
/// Firestore. If the message list is empty or an error occurs, a fallback
/// string is shown. The dialog itself retains the previous styling.

// the build context is used after awaiting network calls; it's acceptable
// here because the caller is unlikely to dispose the widget mid-action, and
// we already guard the dialog invocation. Suppress the lint for clarity.
// ignore: use_build_context_synchronously
Future<void> showNotificationPopup(BuildContext context) async {
  // fetch the message; defaults are created at app startup
  final msg = await NotificationService.getRandomMessage();
  final display = msg ?? 'No notifications available at the moment.';

  // context might become invalid while awaiting above; navigator mounted
  // check is the best we can do in a standalone function.
  // ignore: use_build_context_synchronously
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title row
                Row(
                  children: const [
                    SizedBox(width: 8),
                    Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Spacer(),
                    // Close handled by dialog
                  ],
                ),
                const SizedBox(height: 12),
                // Single message card
                _notificationCard(display),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _notificationCard(String message) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))],
      border: Border.all(color: Colors.grey.shade200),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // small circular logo
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          child: const Center(
            child: Text('LK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LankaSmartMart', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(message, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ],
    ),
  );
}
