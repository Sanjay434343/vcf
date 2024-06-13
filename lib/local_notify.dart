import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotifyPage extends StatefulWidget {
  const LocalNotifyPage({Key? key}) : super(key: key);

  @override
  _LocalNotifyPageState createState() => _LocalNotifyPageState();
}

class _LocalNotifyPageState extends State<LocalNotifyPage> {
  late Query dbRef;
  Map<dynamic, dynamic>? userMap;
  late String currentUserId; // To store the ID of the logged-in user

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late FirebaseMessaging firebaseMessaging;

  @override
  void initState() {
    super.initState();

    // Initialize Firebase query
    dbRef = FirebaseDatabase.instance.reference().child('Users');

    // Initialize Flutter Local Notifications Plugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize Firebase Messaging
    firebaseMessaging = FirebaseMessaging.instance;

    // Retrieve current user ID from input_page.dart
    retrieveCurrentUserId();

    // Start monitoring database changes
    monitorDatabaseChanges();

    // Configure Firebase Messaging
    configureFirebaseMessaging();
  }

  // Function to retrieve current user ID
  void retrieveCurrentUserId() {
    // Replace with your logic to get current user ID from input_page.dart
    // Here, assuming you have a method to retrieve it
    currentUserId = getCurrentUserIdFromInputPage(); // Replace with actual method
  }

  // Method to fetch current user ID from input_page.dart
  String getCurrentUserIdFromInputPage() {
    // Implement logic to fetch current user ID from input_page.dart
    // This could involve Navigator to pass data or accessing shared state
    // Example:
    // return InputPage.currentUser.userId;
    // This assumes you have a static/current instance of InputPage class
    // where you store or access the logged-in user details.
    return 'user123'; // Placeholder; replace with actual logic
  }

  void monitorDatabaseChanges() {
    // Listen for changes in the database
    dbRef.onChildChanged.listen((event) {
      print('Database change detected');
      final dynamic oldValue = userMap![event.snapshot.key];
      final dynamic newValue = event.snapshot.value;

      // Check if the modified value is due amount, paid amount, or balance amount
      if (event.snapshot.key == 'dueAmount' ||
          event.snapshot.key == 'paidAmount' ||
          event.snapshot.key == 'balanceAmount') {
        final double oldValueDouble = double.tryParse(oldValue.toString()) ?? 0.0;
        final double newValueDouble = double.tryParse(newValue.toString()) ?? 0.0;

        // Check for a significant change
        if ((oldValueDouble - newValueDouble).abs() > 1) {
          // Check if the change is related to the current user
          if (event.snapshot.key == 'userId' &&
              newValue.toString() != currentUserId) {
            return; // Skip notification if not related to current user
          }

          String notificationMessage = '';
          if (event.snapshot.key == 'dueAmount') {
            notificationMessage = 'Due amount changed to $newValueDouble';
          } else if (event.snapshot.key == 'paidAmount') {
            notificationMessage = 'Paid amount changed to $newValueDouble';
          } else if (event.snapshot.key == 'balanceAmount') {
            notificationMessage = 'Balance amount changed to $newValueDouble';
          }
          print('Sending local notification: $notificationMessage');
          sendLocalNotification(notificationMessage);
          sendFCMNotification(notificationMessage); // Send FCM notification
        }
      }

      // Update the userMap with new values
      setState(() {
        userMap![event.snapshot.key] = newValue;
      });
      print('User map updated: $userMap');
    });
  }

  void sendLocalNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Database Modification',
      message,
      platformChannelSpecifics,
    );
  }

  void configureFirebaseMessaging() {
    // Request permission for iOS devices
    FirebaseMessaging.instance.requestPermission();

    // Configure FCM message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      // Handle your message data here based on your app's requirements
    });

    // Handle messages when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      // Handle your message data here based on your app's requirements
    });

    // Handle messages when the app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('Message data: ${message.data}');

        // Handle your message data here based on your app's requirements
      }
    });

    // Subscribe to a topic for FCM notifications
    firebaseMessaging.subscribeToTopic('dueAmountChanges');
  }

  void sendFCMNotification(String message) async {
    try {
      // Create the payload for FCM message
      final payload = {
        'notification': {
          'title': 'Database Modification',
          'body': message,
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'sound': 'default',
          'status': 'done',
        },
        'to': '/topics/dueAmountChanges', // Target topic
      };

      // Encode the payload as JSON
      final String fcmPayload = jsonEncode(payload);

      // Normally, you would send this payload to your server or Firebase Function
      // for sending FCM messages to the topic 'dueAmountChanges'.
      // Example: Send this payload via HTTP POST to Firebase FCM endpoint or Cloud Function.

      print('FCM notification payload: $fcmPayload');
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Notification Page'),
      ),
      body: FirebaseAnimatedList(
        query: dbRef,
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> animation, int index) {
          userMap = snapshot.value as Map<dynamic, dynamic>?;
          return ListTile(
            title: Text(snapshot.key ?? ''),
            subtitle: Text(snapshot.value.toString()),
          );
        },
      ),
    );
  }
}
