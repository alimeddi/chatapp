import 'package:ff/widgets/chat_message.dart';
import 'package:ff/widgets/new_messga.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() {
    return _ChatscreenState();
  }
}

class _ChatscreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    setUpPushNotifications();
  }

  void setUpPushNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission (for iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the FCM token
    String? token = await messaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
    }

    // Listen for messages in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message in foreground: ${message.notification?.title}');
    });

    // Handle background message
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from background: ${message.notification?.title}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterChat'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(
            child: ChatMessage(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
