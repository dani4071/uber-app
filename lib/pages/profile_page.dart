import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uber_app_drivers_app/authentication/login_screen.dart';
import 'package:uber_app_drivers_app/global/global_var.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameEditingTextController = TextEditingController();
  TextEditingController phoneEditingTextController = TextEditingController();
  TextEditingController emailEditingTextController = TextEditingController();
  TextEditingController carEditingTextController = TextEditingController();

  setDriverInfo() {
    nameEditingTextController.text = driverName;
    phoneEditingTextController.text = driverPhone;
    emailEditingTextController.text =
        FirebaseAuth.instance.currentUser!.email.toString();
    carEditingTextController.text = "$carNumber-$carColor-$carModel";
  }

  @override
  void initState() {
    super.initState();
    setDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // image
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                    image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: NetworkImage(
                          driverPhoto,
                        ))),
              ),

              const SizedBox(
                height: 16,
              ),

              // driver name
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 4),
                child: TextField(
                  controller: nameEditingTextController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      )),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.white,
                      )),
                ),
              ),

              // driver phone
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 4),
                child: TextField(
                  controller: phoneEditingTextController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      )),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.white,
                      )),
                ),
              ),

              // driver email
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 4),
                child: TextField(
                  controller: emailEditingTextController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      )),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.white,
                      )),
                ),
              ),

              // driver carInfo
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 4),
                child: TextField(
                  controller: carEditingTextController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      )),
                      prefixIcon: Icon(
                        Icons.drive_eta_rounded,
                        color: Colors.white,
                      )),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // logout
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text("Logout"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
