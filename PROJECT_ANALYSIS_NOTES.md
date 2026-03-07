# LankaSmartMart - Project Analysis Notes

This document provides a thorough analysis of the `lankasmartmart` Flutter application. It is intended to support university-level project reporting and technical understanding.

---

## 1. System Overview

LankaSmartMart is a mobile shopping application built with Flutter. It targets grocery and household buyers in Sri Lanka, offering features such as browsing products, managing a shopping cart, placing orders, and tracking delivery. The application integrates with Firebase for authentication, cloud data storage, and notifications while using a local SQLite database to support offline cart operations and synchronization.

The user interface follows a simple multi-page structure with home, category browsing, product details, cart, delivery details, payment, profile, and location tracking screens. State management is handled via the `provider` package, with a single `CartProvider` responsible for cart state and synchronization logic.

Offline capability is a key design consideration: the cart persists locally, keeps track of unsynced changes, and automatically synchronizes with Firestore when connectivity is restored.

The application uses device features such as the camera (for profile picture capture) and geolocation (for map display and branch selection). Notifications are implemented both locally and via Firebase Cloud Messaging (FCM) with message content stored in Firestore.

---

## 2. Main Features

- **User Authentication**: Firebase Authentication with email/password login and signup flows. Minimal validation and error handling are implemented.
- **Product Catalog**: Hard‑coded lists of groceries and vegetables displayed on home and category pages. Product details include name, price, weight, and description with images stored as assets.
- **Shopping Cart**: Add/update/remove cart items, view totals, and confirm orders. Cart operates offline via SQLite and synchronizes with Firestore.
- **Offline Support**: Local SQLite database (`cart.db`) stores cart entries with `isSynced` flags. Connectivity is monitored and automatic synchronization occurs when online. Cart provider loads from Firestore when connected or from SQLite when offline.
- **Notifications**: Firestore-backed message collection seeded at startup. FCM initialization and local notifications are set up; a random message is shown on payment success. Firestore document defaults ensure messages exist.
- **Device Integration**:
  - **Camera**: Profile page allows taking a photo which is saved to the app's documents directory.
  - **Geolocation & Maps**: `LocationSection` widget displays a map (using `flutter_map` with OpenStreetMap tiles), current user location, selectable branch markers, and a polyline between user and branch. Handles permission requests and service availability.
- **Navigation Flow**: Linear and tab-like navigation using `Navigator.push`/`pushReplacement`. Bottom navigation bars provide quick access to home, categories, cart, and profile.
- **Payment Flow**: Dummy UI collects payment details, displays charges computed from cart, and triggers a local notification with randomized success message. Payment success screen shows a static transaction receipt and resets navigation to home.

---

## 3. Application Architecture

The architecture is an example of a simple Flutter application with:

- **Presentation Layer**: All UI lives in `lib/screens` and `lib/widgets`. Each screen is a `StatelessWidget` or `StatefulWidget` containing layout code, input fields, and navigation triggers.
- **State Management**: `provider` package, with `CartProvider` extending `ChangeNotifier` to broadcast cart changes. The provider is instantiated once at app root (`MyApp`) and injected via `ChangeNotifierProvider`.
- **Services**: Reusable logic is encapsulated in `lib/services`:
  - `CartDbHelper` wraps SQLite operations with static methods.
  - `NotificationService` encapsulates FCM and local notification initialization and Firestore message handling.
- **Models**: `CartItem` class defines cart data. `CartProvider` encapsulates business logic around cart operations, connectivity monitoring, and synchronization.
- **Utilities**: Widgets like `LocationSection` and `showNotificationPopup` abstract map and notification UI pieces.
- **Data Sources**:
  - **Remote**: Firestore (collection `Users/{uid}/cart` for cart items; collection `notifications` for notification messages).
  - **Local**: SQLite (`cart_table`, versioned to support migration adding `userUID` column). Device features (camera, geolocation, file storage).

The flow for cart operations is orchestrated entirely within `CartProvider`. UI pages call methods like `addItem`, `removeUnit`, etc., which update provider state, notify listeners, and then persist changes either to Firestore or SQLite depending on connectivity.

---

## 4. Flutter Project Structure

```
lib/
├─ main.dart               # App entrypoint, Firebase init, provider setup
├─ models/
│   └─ cart_model.dart     # CartItem class and CartProvider logic
├─ services/
│   ├─ cart_database.dart  # SQLite helper (CartDbHelper)
│   └─ notification_service.dart # FCM/local notification logic
├─ widgets/
│   ├─ LocationSection.dart   # Map & location UI with geolocator
│   └─ notification_popup.dart # Dialog showing a notification message
└─ screens/                # UI screens for each page
   ├─ splash_screen.dart
   ├─ home_page.dart
   ├─ login_page.dart
   ├─ signup_page.dart
   ├─ categories_page.dart
   ├─ product_details_page.dart
   ├─ cart_page.dart
   ├─ delivery_details_page.dart
   ├─ payment_page.dart
   ├─ payment_success_page.dart
   ├─ profile_page.dart
   ├─ location_page.dart
```

The asset directory contains images used across the UI. The app uses standard Flutter plugins, e.g., `firebase_auth`, `cloud_firestore`, `firebase_messaging`, `sqflite`, `path_provider`, `image_picker`, `geolocator`, `permission_handler`, `flutter_map`, `provider`, and `connectivity_plus`.

---

## 5. State Management

- **Provider/ChangeNotifier**: Only `CartProvider` is used. It maintains a map of cart items and implements all logic for adding, updating, removing, and computing totals. It also handles initialization, listening for connectivity changes, reacting to authentication state changes, and synchronizing data.
- **Local UI State**: Individual screens manage transient UI state such as loading indicators, form inputs, and connectivity flags (e.g., `CartPage` tracks `_online`). These are simple `StatefulWidget` states.


---

## 6. Firebase Authentication Usage

- Initialization in `main.dart` ensures Firebase is ready before running the app.
- Authentication state determines navigation from the splash screen: if a user is logged in, navigate to `HomePage`; otherwise, go to `SignUpPage`.
- `LoginPage` and `SignUpPage` perform email/password sign-in and registration via `FirebaseAuth.instance`. They handle basic validation and display SnackBar messages on errors.
- The `HomePage` app bar includes a logout button which calls `FirebaseAuth.instance.signOut()` and navigates back to the `LoginPage`.

No further user data (e.g., profile information) is stored in Firebase; the provider listens to `authStateChanges()` to clear/load cart data accordingly.

---

## 7. Firestore Database Structure

The Firestore layout is lightweight and pragmatic:

- **notifications** (collection)
  - Document IDs: `msg1`, `msg2`, etc.
  - Each document contains a `message` field (string).
  - The app seeds defaults on startup with `NotificationService.ensureDefaults()`.

- **Users** (collection)
  - Each user document ID equals the Firebase `uid`.
  - **cart** (subcollection under each user)
    - Documents keyed by product name (e.g., "Fresh Strawberry").
    - Fields:
      - `productName` (string)
      - `price` (number)
      - `units` (integer)
      - `imagePath` (string) [legacy documents may hold `image` instead]

The cart provider writes to and reads from this path when online. Real-time updates are consumed using `snapshots()` in `CartPage`.

No other Firestore collections (e.g., orders) are present. The main focus is cart synchronization and notification messages.

---

## 8. SQLite Offline Database Usage

- `CartDbHelper` is a static utility that initializes a local SQLite database (`cart.db`) with a single table: `cart_table`.
- **Schema (version 2)**:
  - `id` INTEGER PRIMARY KEY AUTOINCREMENT
  - `userUID` TEXT NOT NULL
  - `productName` TEXT NOT NULL
  - `price` REAL
  - `units` INTEGER
  - `isSynced` INTEGER
  - `image` TEXT
  - UNIQUE(userUID, productName)
- The helper provides methods to insert/update rows, query all rows for a user, fetch unsynced rows, mark rows as synced, delete items, update units, and clear a user's cart.
- On upgrade from version <2, the helper drops and recreates the table to add the `userUID` column.

The data stored locally mirror the Firestore cart entries, with `isSynced` indicating whether a row has been propagated to the cloud. Deleted items are represented by `units` set to 0.

---

## 9. Offline→Online Synchronization Logic

Implementation resides entirely within `CartProvider`.

1. **Initialization**:
   - `CartDbHelper.init()` is called to prepare the database.
   - `_listenConnectivity()` sets up a listener for connectivity changes using `connectivity_plus`.
   - `FirebaseAuth.instance.authStateChanges()` subscribes to authentication events to load or clear cart data based on the current user.

2. **Loading Cart**:
   - `_loadCartForUser(uid)` clears `_items` and chooses source based on `_isOnline()`.
   - When online: call `_loadFromFirebase(uid)` which fetches cart documents, repopulates `_items`, and updates local cache (`insertOrUpdate` with `isSynced:1`), first clearing previous local entries.
   - When offline: call `_loadLocalItems(uid)` to read rows from SQLite and populate `_items`.

3. **Item Operations (add/update/remove)**:
   - UI calls methods like `addItem`, `addUnit`, `removeUnit`, and `removeItem`.
   - These modify the in-memory `_items` map and call `_handleAddOrUpdate` or `_handleRemoval` with the current `uid` and connectivity status.
   - `_handleAddOrUpdate` writes directly to Firestore if online and also updates the local cache with `isSynced` flag accordingly. If offline, it writes solely to SQLite with `isSynced:0`.
   - `_handleRemoval` either deletes from Firestore and local DB (if online) or updates the SQLite row to `units=0` with `isSynced:0` (marking for later deletion).

4. **Connectivity Listener**:
   - When connectivity changes from none to anything else, `_listenConnectivity()` triggers `_syncUnsynced(uid)` followed by `_loadCartForUser(uid)`.
   - `_syncUnsynced` reads all local rows with `isSynced=0`. For each:
     - If `units<=0`, it interprets as deletion: deletes the document from Firestore and removes the row locally.
     - Otherwise, it writes/sets the document in Firestore and marks the local row as synced via `markSynced(id)`.

The approach ensures eventual consistency: local modifications are queued and propagated when a connection resumes, and any server-side changes refresh the local cache.

---

## 10. Cart Management

- **Data Model**: `CartItem` stores name, imagePath, price, and units. Cart content is held in a `Map<String, CartItem>` keyed by product name.
- **Provider Methods**:
  - `addItem`: increments units if item exists else adds new; then persists.
  - `addUnit`, `removeUnit`, `removeItem`: allow fine-grained unit control and removal.
  - `total`, `deliveryCharges`, and `subTotal` getters compute amounts for display.
  - `formatRs` utility to format currency with "RS" prefix.
- **Persistence**: See offline synchronization above. Firestore and SQLite operations keep the provider and UI in sync.
- **UI Binding**: UI screens (home, categories, product details, cart page) access the provider via `Provider.of<CartProvider>` and call methods to mutate state. They also read totals for display.
- **Cart UI**: `CartPage` displays either a Firestore stream or the cached provider list depending on connectivity. It prints debug output of SQLite items to console when offline.

---

## 11. Notification Flow (Firestore Based)

- At app startup `main()` performs:
  - `NotificationService.ensureDefaults()` to create default Firestore documents if missing.
  - `NotificationService.initialize()` to configure FCM and local notifications.
  - `FirebaseMessaging.onBackgroundMessage` is registered with `NotificationService.firebaseBackgroundHandler`.
- **Firestore**: collection `notifications` holds text messages. Defaults include order confirmation messages.
- **Random Message Selection**: `getRandomMessage()` fetches all documents and randomly selects one to display. Errors or empty collections return null.
- **Display**: `showNotificationPopup` widget fetches a random message and shows a modal dialog; used in various app bars via `IconButton`.
- **Local Notification On Payment**: `showPaymentSuccessNotification()` chooses from a static list of messages and calls `_showLocalNotification`. The payment page triggers this when the "Pay now" button is pressed.
- **FCM**: Standard initialization is performed with permission requests, foreground & background handlers that show local notifications when remote messages arrive. The actual remote messaging functionality is not exercised in existing code but the setup is present.

---

## 12. Device Features

- **Camera**: Used on the profile page. Tapping the camera icon calls `_pickImage()` which uses `image_picker` to open the camera. The chosen image is copied to the application's documents directory as `profile_pic.jpg`. The image is then loaded and displayed in a `CircleAvatar`.

- **Geolocation & Maps**: `LocationSection` handles location:
  - Requests permission via `geolocator`; opens app settings if permissions are denied permanently.
  - Subscribes to position stream to update location marker.
  - Displays a `flutter_map` map centered on the user's location or default coordinates. Branches are hard-coded with coordinates and drawn as markers. Selecting a branch draws a polyline between the user and branch.
  - Minimal zoom and control UI included.

- **File Storage**: `path_provider` used for profile image. SQLite database stored in the default databases directory.

- **Permissions**: `permission_handler` imported though geolocator uses its own permission flows; `permission_handler` is not used explicitly elsewhere but may be included for camera or location.

- **Connectivity**: `connectivity_plus` monitors network state for cart synchronization and adaptative UI.

---

## 13. Navigation Flow Between Screens

Navigation is managed via `Navigator` and `MaterialPageRoute`. Some flows:

1. **Splash** -> either `HomePage` or `SignUpPage` (based on auth state).
2. **HomePage**: from here users can go to `ProfilePage`, `CategoriesPage` or `CartPage` via bottom navigation or button taps. Clicking on a product navigates to `ProductDetailsPage`.
3. **CategoriesPage**: very similar to home but with category-specific lists; bottom nav allows jumping to other primary screens.
4. **ProductDetailsPage**: includes "Add to Cart"; can navigate back or to `CartPage`.
5. **CartPage**: scrollable list; "Confirm Order" navigates to `DeliveryDetailsPage`.
6. **DeliveryDetailsPage**: forms for details; "Proceed to Checkout" goes to `PaymentPage`; has a button to go to `LocationPage`.
7. **LocationPage**: map UI showing branch and user location; also displays static order status.
8. **PaymentPage**: dummy payment inputs; pressing "Pay now" triggers a notification and routes to `PaymentSuccessPage`.
9. **PaymentSuccessPage**: displays confirmation; back arrow resets stack to `HomePage`.
10. **Login/Signup** flows: you can navigate between them, and on success both go to `HomePage` using `pushReplacement`.

Most navigations rely on `push` and `pushReplacement`; no named routes are used. Bottom navigation is implemented uniformly by tapping icons that call `Navigator.push`.

---

## 14. User Data Storage

- **Authentication**: Only Firebase Auth stores credentials. Local `ProfilePage` uses hard-coded placeholder user info (name, email, mobile, NIC).
- **Profile Picture**: Stored locally in the application documents directory as `profile_pic.jpg` and loaded on startup.
- **Cart Data**: Stored in Firestore under the authenticated user and locally in SQLite.
- **Notifications Messages**: Stored in Firestore collection `notifications` with default documents seeded at startup. There is no user-specific notification storage.

Order and delivery details entered in forms are not persisted; they are part of the UI flow only and are lost if the user leaves the page.

---

## 15. Orders / Cart Management Summary

The app treats the cart as the primary data model for orders. When the user confirms an order, no backend order document is created; the process ends at the payment success screen. Delivery and payment details are purely visual and not stored anywhere. The cart continues to exist and could be cleared by user actions but there is no explicit "order placed" operation beyond navigation and notification.

Cart persistence across sessions is achieved by syncing with Firestore and caching locally. When a user signs out, the provider clears the `_items` map. When the same user signs back in (or another user), cart data is loaded appropriately.

---

## 16. Important Implementation Logic and Notes

- **Connectivity Awareness**: The cart provider listens to connectivity and triggers a sync when connection returns. CartPage also separately listens and toggles between Firestore stream and local cache.

- **Legacy Compatibility**: When loading Firestore documents, the provider looks for either `imagePath` or legacy `image` field. Similar logic exists in cart page builder.

- **Price Parsing**: Utility `parsePrice` strips non-digit characters from a strings like "RS 1300/500g" to extract numeric value, using regex, ensuring cart prices are numeric.

- **Firebase Initialization**: `main()` ensures background messaging handler is registered before `NotificationService.initialize()` is called, fulfilling FCM requirements.

- **Notification Randomization**: For payment success, both local static messages and Firestore messages are randomized to provide variety.

- **UI Consistency**: Many screens reuse similar card widgets and bottom navigation bars with the same icons and colors to maintain a consistent look.

- **Debug Logging**: `CartPage` prints local SQLite cart entries to console when offline to aid in debugging.

- **Map Interaction**: Map controls allow zoom and recenter to user location; branch selection recenters map between user and branch.

- **Profile Image Handling**: When capturing an image, the app handles potential exceptions gracefully by showing a SnackBar if camera usage fails.

---

## 17. Offline and Online State Handling

The application ensures that the shopping cart remains functional even with no network. When offline:

1. The UI continues using locally cached cart entries maintained by `CartProvider`.
2. Additions, updates, and deletions are recorded in SQLite with `isSynced=0`.
3. `CartPage` shows items from provider (pulled from local DB during initialization).
4. The user can still navigate and submit the cart to delivery details and payment; payment notifications are local (no network required).

When connectivity is restored:

1. `CartProvider` detects non-none connectivity in `_listenConnectivity`. It calls `_syncUnsynced` to flush local changes to Firestore and then reloads the cart from Firestore to refresh the local cache.
2. `CartPage` may rebuild using a Firestore stream if `_online` is true. It shows real-time updates.
3. Unsuccessful Firestore operations (network failure) during sync cause fallback to local data due to try/catch.

Connectivity is determined by `connectivity_plus` and checked using `Connectivity().checkConnectivity()`. There is no explicit network call to verify actual internet access; connectivity refers to the presence of an active network interface.

---

## 18. Firebase and SQLite Interaction

The two data sources are tightly coordinated via the cart provider:

- **Writes**: On any cart modification, the provider decides whether to write first to Firestore (if online) and always update local SQLite (either as synced or unsynced). Offline writes only affect SQLite.
- **Reads**: On initialization or connectivity change, the provider chooses the appropriate data source. When the app is online and the cart is loaded from Firestore, the local SQLite cache is cleared and repopulated to reflect the authoritative server data. When offline, local SQLite serves as the single source of truth.
- **Sync Mechanism**: Unsynced SQLite rows are examined during connectivity restoration; each is either added/updated or removed from Firestore, and the local row is either marked synced or deleted.

By using `userUID` in the SQLite schema, the app can support multiple users on the same device by isolating their carts.

---

## 19. UI Page Connections

The UI is organized in a hierarchical flow with consistent navigation elements:

- **Splash**: entry point -> auth decision -> home or signup.
- **Home**: central hub; features quick access to profile, notifications, categories, and search. Products can be added directly or opened in detail.
- **Categories**: branch from home showing categorized product lists; same navigation structure as home.
- **Product Details**: reached from home/categories; allows adding to cart and seeing more info.
- **Cart**: reached from icons in home/products/other screens; shows details and actions on cart.
- **Delivery Details**: step after cart confirmation; includes form for user information and buttons to track order or proceed to payment.
- **Location**: auxiliary page accessible from delivery details; shows map and order status.
- **Payment**: final step in the ordering workflow; triggers notifications.
- **Payment Success**: final confirmation; resets navigation back to home.
- **Profile, Login, Signup**: independent screens for user management and profile editing (limited to photo capture).

Each page uses standard Flutter widgets, and there is no global route configuration. Navigation is explicit with `MaterialPageRoute` for each transition. Bottom navigation is manually implemented with icons and `GestureDetector` wrapping each icon; selecting a tab uses `Navigator.push` rather than stateful tab management.

---

## 20. Conclusion

The LankaSmartMart app is a modest but complete example of a Flutter e-commerce-style application with real-world considerations such as offline support, synchronization, device integration, and backend services. The architecture is straightforward and relies on `provider` for state management and Firebase for backend services. The project code is cleanly separated into screens, services, and models, with implementation patterns that would be suitable for educational and prototyping purposes.

This analysis covers all relevant implementation details and should enable the generation of a comprehensive university project report.