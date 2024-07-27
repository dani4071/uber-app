import 'package:admin_uber_web_panel/dashboard/dashboard.dart';
import 'package:admin_uber_web_panel/pages/drivers_page.dart';
import 'package:admin_uber_web_panel/pages/trips_page.dart';
import 'package:admin_uber_web_panel/pages/users_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

class sideNavigation extends StatefulWidget {
  const sideNavigation({super.key});

  @override
  State<sideNavigation> createState() => _sideNavigationState();
}

class _sideNavigationState extends State<sideNavigation> {

  Widget chosenScreen = const dashboard();

  sendAdminTo(selectedPage){

    switch(selectedPage.route){

      case driversPage.id:
        setState(() {
          chosenScreen = const driversPage();
        });
        break;

      case tripsPage.id:
        setState(() {
          chosenScreen = const tripsPage();
        });
        break;

      case usersPage.id:
        setState(() {
          chosenScreen = const usersPage();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade200,
        title: const Text(
          'Admin Web Panel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: 'Drivers',
            route: driversPage.id,
            icon: CupertinoIcons.car_detailed
          ),
          AdminMenuItem(
            title: 'Users',
            route: usersPage.id,
            icon: CupertinoIcons.person_2_fill
          ),
          AdminMenuItem(
            title: 'Trips',
            route: tripsPage.id,
            icon: CupertinoIcons.location_fill,
          ),
        ],
        selectedRoute: driversPage.id,
        onSelected: (selectedPage) {
          sendAdminTo(selectedPage);
        },
        header: Container(
          height: 52,
          width: double.infinity,
          color: Colors.blue.shade500,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility,
                color: Colors.white,
              ),
              SizedBox(width: 10,),
              Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ],
          ),
        ),
        footer: Container(
          height: 52,
          width: double.infinity,
          color: Colors.blue.shade500,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 10,),
              Icon(
                Icons.laptop,
                color: Colors.white,
              ),
            ],
          ),
        ),


      ),
      body: chosenScreen,
    );
  }
}
