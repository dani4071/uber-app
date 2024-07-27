import 'package:admin_uber_web_panel/dashboard/side_navigation_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBtKVLmxswZsJ9nIeTUvrL7j1z9XGUhzPA",
      authDomain: "uber-app-b9023.firebaseapp.com",
      databaseURL: "https://uber-app-b9023-default-rtdb.firebaseio.com",
      projectId: "uber-app-b9023",
      storageBucket: "uber-app-b9023.appspot.com",
      messagingSenderId: "991500498355",
      appId: "1:991500498355:web:aa54cd51cebc5e523107c6",
      measurementId: "G-YZGZF314HY"
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Admin panel",
      theme: ThemeData(
        primarySwatch: Colors.cyan
      ),
      home: const sideNavigation(),
    );
  }
}
