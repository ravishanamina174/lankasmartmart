import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'models/cart_model.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required
  await Firebase.initializeApp(); // Initialize Firebase
  // configure Firebase Messaging background handler before calling
  // NotificationService.initialize so that it can be used if messages
  // arrive before the UI is built.
  FirebaseMessaging.onBackgroundMessage(
      NotificationService.firebaseBackgroundHandler);
  // make sure our Firestore notification collection contains the
  // default documents; this is lightweight and idempotent.
  await NotificationService.ensureDefaults();
  // initialize FCM & local notifications (creates channel, asks
  // permission, etc.).
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'Clean Flutter App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}