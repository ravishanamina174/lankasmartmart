import 'package:flutter/material.dart';

Future<void> showNotificationPopup(BuildContext context) {
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
                // Notification items
                _notificationCard('Weekend special! Save 20% on personal care and stationery essentials.'),
                const SizedBox(height: 12),
                _notificationCard('Enjoy 15% off on daily essentials with our special New Year offers!'),
                const SizedBox(height: 12),
                _notificationCard('Save up to 25% on groceries, household, and personal care items this weekend!'),
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
