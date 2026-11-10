import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmEvent {
  final String handlerName;
  final Map<String, dynamic> data;
  FcmEvent(this.handlerName, this.data);
}

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final _eventStreamController = StreamController<FcmEvent>.broadcast();
  Stream<FcmEvent> get eventStream => _eventStreamController.stream;

  Map<String, dynamic>? initialMessageData; // FIX: Store this for the UI

  Future<void> initialize() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');

    String? token = await _fcm.getToken();
    debugPrint("FCM TOKEN: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      _eventStreamController.add(FcmEvent('onMessage', message.data));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      _eventStreamController.add(FcmEvent('onMessageOpenedApp', message.data));
    });

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App launched via notification tap!');
      initialMessageData = initialMessage.data; // FIX: Save instead of stream
    }
  }

  void dispose() {
    _eventStreamController.close();
  }
}
