import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this import
import 'package:vouch_tour_mobile/firebase_options.dart';
import 'package:vouch_tour_mobile/routes/routes.dart';
import 'package:vouch_tour_mobile/themes/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
 

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}); // Fix the syntax for the constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: customLightTheme,
      darkTheme: customDarkTheme,
      initialRoute: "/",
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
    );
  }
}
