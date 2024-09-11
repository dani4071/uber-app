import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uber_app_drivers_app/pages/dashboard.dart';
import 'package:uber_app_drivers_app/pages/home_page.dart';
import 'authentication/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future <void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAKsv1MXQueJejxO7_7Fr6QzHY6G4mebSQ',
        appId: '1:991500498355:android:ab6d53d7c4a792e93107c6',
        messagingSenderId: '991500498355',
        projectId: 'uber-app-b9023',
        storageBucket: 'gs://uber-app-b9023.appspot.com'
      )
  );

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission)
  {
    if(valueOfPermission)
    {
      Permission.locationWhenInUse.request();
    }
  });

  await Permission.notification.isDenied.then((valueOfPermission)
  {
    if(valueOfPermission)
    {
      Permission.notification.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: FirebaseAuth.instance.currentUser == null ? const LoginScreen() :const Dashboard(),
    );
  }
}
