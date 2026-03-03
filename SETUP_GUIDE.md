# Setup Guide

This document explains how the two new features in the LankaSmartMart app work and how to set them up and test them in both emulators and real devices.

---

## Firestore Notifications

### Overview

The app now uses a Firestore collection named `notifications` to drive its in‑app pop‑up messages. When the user taps the bell icon on any page (home, categories, cart, delivery details, location), the app:

1. Ensures four default documents exist (msg1–msg4).
2. Retrieves *all* documents in the `notifications` collection.
3. Randomly selects one non‑empty `message` field and displays it in the existing popup UI.

Because the code fetches the collection every time the button is pressed, any changes you make in the Firebase Console take effect immediately. Adding new documents (msg5, msg6, etc.) also requires no code change – they will automatically enter the random rotation.

### Default Documents

If the collection is empty or missing expected documents, the following records are inserted automatically at startup (or on the first notification request):

```json
// document ID: msg1
{ "message": "New Year Offer! Enjoy up to 30% off on all soft drinks & snacks!" }

// document ID: msg2
{ "message": "Weekend Deals — Fresh fruits & veggies at 20% off!" }

// document ID: msg3
{ "message": "Midweek Madness! Get 15% off selected dairy & bakery items!" }

// document ID: msg4
{ "message": "Earn 2× loyalty points today on groceries above Rs. 2,000!" }
```

The service only creates missing documents; it will **not** overwrite existing ones. This makes it safe to update the `message` field for any ID via the console.

### Editing and Adding Messages

- To **edit** a message, open the document in the `notifications` collection and change the `message` field. Save – the next time a user taps the bell, the new text will be shown.
- To **add** a new message, create a new document in `notifications`. Use any unique ID (e.g. `msg5`, `msg6`); just include a `message` string. The app will automatically include it.
- If a document has a null or empty `message`, it is ignored during selection.

### Firestore Rules (optional)

If you have restrictive security rules, make sure the app can read the `notifications` collection.
A simple rule allowing any authenticated user to read is:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notifications/{doc} {
      allow read: if request.auth != null;
      // optionally disallow writes from clients if you prefer
      allow write: if false;
    }
  }
}
```

Adjust permissions according to your security requirements.

### Testing Notifications

1. **From emulator**
   - Run `flutter run` (Android) or `flutter run -d macos` (desktop).  Ensure the emulator is connected to the internet and signed in to Firebase if authentication is required.
   - Tap the notification icon; you should see one of the messages.
   - Edit a message or add a new one using the Firebase Console, then tap again – the change should appear immediately.
   - Remove all documents manually; tapping should show "No notifications available at the moment." without crashing.

2. **On a real device**
   - Build and install the app on an Android/iOS device with valid Firebase configuration.
   - Perform the same steps as above.

---

## Profile Page Camera Feature

### Overview

The profile page now displays a small camera icon overlaying the avatar. Tapping it launches the device camera. When a picture is taken, it is stored locally in the app's documents directory and immediately shown in place of the default avatar.

**Implementation details**:

- Image capture is handled by the `image_picker` package.
- The image file is copied to `${appDocumentsDirectory}/profile_pic.jpg`.
- On startup and after taking a photo, the UI checks for the file and uses `FileImage`.
- Permissions are requested transparently by the plugin; denied or canceled actions are handled gracefully with a SnackBar.

### Android Permissions

Add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to allow you to take a profile picture.</string>
```

### Testing Camera

1. **Emulator / Simulator**
   - Android emulator: use the extended controls (three dots) -> Camera -> select "Virtual scene" or use webcam.  The `image_picker` plugin will launch the camera UI.
   - iOS Simulator: camera capture is not available; you will need a real device for full testing.  However, tapping the icon on simulator should not crash and will simply return `null`.

2. **Real Device**
   - Run the app on a physical phone with camera hardware.
   - Tap the camera icon, allow permission when prompted.
   - Take a picture; confirm that the avatar updates immediately.
   - If you deny permission, the app will display a SnackBar and stay on the profile page.

---

## Additional Notes

- There are no structural UI changes beyond adding the camera icon and using dynamic notification content. The popup styling remains unchanged.
- The collected images are stored in the app's private storage and are removed when the app is uninstalled.
- No Firebase Cloud Messaging (FCM) is used; notifications are purely Firestore-based as requested.

---

With these instructions you should be able to manage, test, and extend the notification and profile-image features easily.
