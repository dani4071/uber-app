import 'package:flutter/material.dart';
import 'package:uber_app_clone/authentication/login_screen.dart';
import 'package:uber_app_clone/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future <void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// remember to add the total 4 lines of code required in the android manifest respectively
  /// this means if the location is denied so we ask for the permisson that is why the if statement is there
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    /// if its true, then we now ask for the permission
    if(valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FirebaseAuth.instance.currentUser == null ? loginScreen() : homePage(),
    );
  }
}