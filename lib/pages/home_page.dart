import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_app_drivers_app/methods/map_theme_method.dart';
import 'package:uber_app_drivers_app/push_notification/push_notification_system.dart';
import '../global/global_var.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  Color colorToShow = Colors.green;
  String textToShow = "GO ONLINE NOW";
  bool isDriverAvailable = false;
  DatabaseReference? newTripRequestReference;
  MapThemeMethod mpMethod = MapThemeMethod();

  getCurrentLiveLocationOfDriver() async
  {
    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfUser;
    /// this is for the global variable || section33 video 119
    driverCurrentPosition = currentPositionOfDriver;

    LatLng positionOfUserInLatLng = LatLng(currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }


  goOfflineNow()
  {
    /// stop sharing driver live location, all you need is to use the id
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    //stop listening to the newTripStatus
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  ///SECTION[24 & 25] all videos
  /// go live as the driver to be able to recieve trip
  goOnlineNow()
  {
    /// geofire here allows you to get live location of the driver, thats what the package does
    /// its a package that allows you to get real time update

    // all drivers who are available for new trip request
    Geofire.initialize("onlineDrivers");

    /// gets driver unique id and live location
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      currentPositionOfDriver!.latitude,
      currentPositionOfDriver!.longitude,
    );

    /// make a reference to the drivers and add a new key newTripStatus
    newTripRequestReference = FirebaseDatabase.instance.ref()
    .child("drivers")
    .child(FirebaseAuth.instance.currentUser!.uid)
    .child("newTripStatus");
    /// set it to waiting
    newTripRequestReference!.set("waiting");

    /// now listen to it and check if any changes happen
    newTripRequestReference!.onValue.listen((event) {

    });
  }

  setAndGetLocationUpdate()
  {
    /// with the help of this streamSubscription we are getting the driver live location ||section 25 video 87
    positionStreamHomePage = Geolocator.getPositionStream()
        .listen((Position position){

          /// the update comes inside our position above then we assign it to our currentPositionOfUsers down here
          currentPositionOfDriver = position;

          /// once the driver location is true(meaning driver is online) then we set and start sharing the location
          if(isDriverAvailable == true){
            Geofire.setLocation(
              FirebaseAuth.instance.currentUser!.uid,
              currentPositionOfDriver!.latitude,
              currentPositionOfDriver!.longitude,
            );
          }

          /// we want to display the live new location on our google map, the code below
          LatLng positionLatLng = LatLng(
              currentPositionOfDriver!.latitude,
              currentPositionOfDriver!.longitude
          );
          /// we animate the camera to the new position
          controllerGoogleMap!.animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  initializePushNotification()
  {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification(context);
  }

  retrieveCurrentDriverInfo() async
  {
    await FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once().then((snap){

      driverName = (snap.snapshot.value as Map)["name"];
      driverPhone = (snap.snapshot.value as Map)["phone"];
      driverPhoto = (snap.snapshot.value as Map)["photo"];
      carColor = (snap.snapshot.value as Map)["car_details"]["carColor"];
      carModel = (snap.snapshot.value as Map)["car_details"]["carModel"];
      carNumber = (snap.snapshot.value as Map)["car_details"]["carNumber"];
    });



    initializePushNotification();
  }


  @override
  void initState() {
    super.initState();

    retrieveCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// Google map
          GoogleMap(
            padding: const EdgeInsets.only(top: 136),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController)
            {
              controllerGoogleMap = mapController;
              // updateMapTheme(controllerGoogleMap!);
              mpMethod.updateMapTheme(controllerGoogleMap!);

              googleMapCompleterController.complete(controllerGoogleMap);

              getCurrentLiveLocationOfDriver();
            },
          ),

          
          Container(
            height: 136,
            width: double.infinity,
            color: Colors.black54,
          ),

          /// go online/offline container
          Positioned(
            top: 61,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {

                    showModalBottomSheet(
                      context: context,
                      isDismissible: false,
                      builder: (BuildContext context){
                        return Container(
                          height: 220,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 0.5,
                                blurRadius: 5.0,
                                offset: Offset(0.7,0.7),
                              )
                            ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [

                                const SizedBox(height: 10,),

                                Text(
                                  (!isDriverAvailable) ? "GO ONLINE NOW" : "GO OFFLINE NOW",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20,),

                                Text(
                                  (!isDriverAvailable)
                                      ? "You are about to go online you will become available to receive trip requests from users"
                                      : "You are about to go offline you will stop receiving trip requests from users",
                                  style: const TextStyle(
                                    color: Colors.white30,
                                  ),
                                ),

                                const SizedBox(height: 21,),

                                Row(
                                  children: [

                                    /// back button
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          backgroundColor: Colors.blue
                                        ),
                                        child: const Text(
                                          "BACK",
                                          style: TextStyle(
                                            color: Colors.white
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10,),

                                    /// confirm button
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: (){

                                          if(!isDriverAvailable) {

                                            // go online
                                            goOnlineNow();

                                            // get driver location update
                                            setAndGetLocationUpdate();

                                            Navigator.pop(context);

                                            setState(() {
                                              textToShow = "GO OFFLINE NOW";
                                              isDriverAvailable = true;
                                              colorToShow = Colors.pink;
                                            });

                                          }
                                          else {

                                            // go offline now
                                            goOfflineNow();


                                            Navigator.pop(context);

                                            setState(() {
                                              textToShow = "GO ONLINE NOW";
                                              isDriverAvailable = false;
                                              colorToShow = Colors.green;
                                            });
                                          }

                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          backgroundColor: (textToShow == "GO ONLINE NOW") ? Colors.green : Colors.pink,
                                        ),
                                        child: const Text(
                                          "CONFIRM",
                                          style: TextStyle(
                                              color: Colors.white
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),



                              ],
                            ),
                          ),

                        );
                      }
                    );


                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorToShow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    )
                  ),
                  child: Text(
                    textToShow
                  ),
                )
              ],
            ),
          )

        ],
      ),
    );
  }
}
