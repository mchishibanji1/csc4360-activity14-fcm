import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'fcm_service.dart';
import 'home_screen.dart';
import 'firebase_options.dart';

// MUST be top-level and have this annotation
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final fcmService = FCMService();
  await fcmService.initialize();

  runApp(MyApp(fcmService: fcmService));
}

class MyApp extends StatelessWidget {
  final FCMService fcmService;
  const MyApp({super.key, required this.fcmService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Courier',
      home: HomeScreen(fcmService: fcmService),
    );
  }
}
