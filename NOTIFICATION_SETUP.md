# FCM & Local Notification Setup

This document describes the steps you need to perform in the Firebase
console and on the Android emulator in order to test the messaging and
local-notification functionality added to the app.

---

## Firebase Console

1. **Enable Cloud Messaging**
   - Go to the [Firebase console](https://console.firebase.google.com/) and
     open your project (the one already used for auth/firestore).
   - In the left-hand menu select **Cloud Messaging**.
   - No additional configuration is required on the console side for basic
     usage, but you can optionally create a test message now to verify
     remote notifications work later.

2. **(Optional) Add a server key / FCM token**
   - In **Project settings → Cloud Messaging** you can copy the **Server key**
     if you plan to send messages from your own backend.
   - When you run the app on the emulator the FCM registration token will be
     printed to the debug console (see `initialize()` in
     `notification_service.dart`). Copy that token for manual testing or for
     sending messages from the console.

3. **Send a test message (optional)**
   - Click **Send your first message** (or **New notification**) and fill in a
     title/body of your choice. In the **Target** section choose **Single
     device** and paste the token obtained from the emulator.
   - Send the message.  If the app is running in the foreground or background
     you should see a local notification appear.

4. **(Optional) Notification channel id**
   - If you want Firebase's built-in notification handling to post to the same
     channel created by the app (`payment_channel`), add a metadata entry in
     the manifest as follows (already done in code but you may mirror it in
     the console):
     ```xml
     <meta-data
         android:name="com.google.firebase.messaging.default_notification_channel_id"
         android:value="payment_channel" />
     ```

---

## Testing on Android Emulator

1. **Install & configure**
   - Make sure you have an Android 13+ emulator (API level 33 or above) to see
     the new runtime permission prompt. Older emulators will still work but
     won't show the permission dialog.
   - Launch the emulator and verify it has network access.

2. **Run the app**
   - Execute `flutter run` (or use your IDE) while the emulator is running.
   - On first launch the app will:
     * Initialize Firebase.
     * Call `NotificationService.initialize()` which:
       * Requests notification permission on Android 13+
       * Creates the notification channel.
       * Subscribes to FCM message streams.
   - Watch the debug console for the FCM registration token printed by the
     initialization code.

3. **Trigger the in‑app notification**
   - Complete a purchase by tapping **Pay now** on the `PaymentPage`.
   - Immediately after navigation to the `PaymentSuccessPage` you should see a
     single system notification containing one of the four random messages.  A
     different message is chosen each time you tap the button.
   - If the app does not have permission yet the system prompt will appear
     before the notification is delivered; you may need to tap **Allow**.

4. **(Optional) Test receiving an FCM message**
   - Using the console or a server send a push message to the token shown in
     the debug log from step 2.
   - If the app is in the foreground the message is intercepted by
     `onMessage` and also displayed using the local notification plugin.
   - If the app is in the background/terminated you should still receive a
     notification (handled by `firebaseBackgroundHandler`).

5. **Cleanup**
   - If you grant the notification permission once, subsequent runs will not
     show the permission dialog again until you clear the app data or
     reinstall.

---

With the above steps you should be able to verify that the FCM integration
is functional and that local notifications are triggered correctly when the
user pays.  The code is production‑ready and properly handles channel
creation, permission requests, and message handling.
