import 'package:flutter/material.dart';

import 'fcm_service.dart';

class HomeScreen extends StatefulWidget {
  final FCMService fcmService;
  const HomeScreen({super.key, required this.fcmService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _lastHandler = "None";
  int _receiptCount = 0;
  String _currentAsset = 'assets/images/default.png';
  String _diagnostic = "No errors.";

  @override
  void initState() {
    super.initState();

    // Listen for future events
    widget.fcmService.eventStream.listen((event) {
      _processEvent(event);
    });

    // FIX: Check if the app was launched from a notification tap
    if (widget.fcmService.initialMessageData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processEvent(
          FcmEvent('getInitialMessage', widget.fcmService.initialMessageData!),
        );
      });
    }
  }

  void _processEvent(FcmEvent event) {
    setState(() {
      _lastHandler = event.handlerName;
      _receiptCount++;

      String? action = event.data['action'];
      String? asset = event.data['asset'];

      if (action == 'update_ui') {
        if (asset == 'promo') {
          _currentAsset = 'assets/images/promo.png';
          _diagnostic = "Success: Updated to promo.";
        } else if (asset == 'default') {
          _currentAsset = 'assets/images/default.png';
          _diagnostic = "Success: Updated to default.";
        } else {
          _diagnostic =
              "Error: Unsupported asset value '$asset'. Keeping previous UI.";
        }
      } else {
        _diagnostic =
            "Error: Unsupported action '$action'. Keeping previous UI.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Courier')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Handler: $_lastHandler',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Receipt Count: $_receiptCount',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              color: _diagnostic.startsWith("Error")
                  ? Colors.red[100]
                  : Colors.green[100],
              child: Text(_diagnostic, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),
            Image.asset(
              _currentAsset,
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
