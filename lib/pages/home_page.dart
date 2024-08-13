import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_app_clone/app_info/app_info.dart';
import 'package:uber_app_clone/authentication/login_screen.dart';
import 'package:uber_app_clone/global/global_variables.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_app_clone/models/direction_details_model.dart';
import 'package:uber_app_clone/pages/search_destination_page.dart';
import 'package:uber_app_clone/widgets/loading_dialog.dart';

import '../methods/common_methods.dart';



class homePage extends StatefulWidget
{
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}



class _homePageState extends State<homePage>
{

  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainer = 0;
  DirectionDetailsModel? tripDirectionDetailsinfo;

  /// styling map design
  void updateMapTheme(GoogleMapController controller) {
    getJsonFromTheme("theme/map/night_style.json").then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFromTheme(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }
  ///


  /// Getting user current Location
  getCurrentUserLocationOfUser() async {

    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    /// human readable address
    await CommonMethods.convertGeoGraphicsCoordinatesIntoHumanReadableAddress(currentPositionOfUser!, context);

    await getUserInfoAndCheckBlockStatus();
  }


  /// checking if the user is blocked by the admin
  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
      {
        if((snap.snapshot.value as Map)["blockStatus"] == "no")
        {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
          });
        }
        else
        {
          FirebaseAuth.instance.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const loginScreen()));
          cMethods.displaySnackBar("you are blocked. Contact admin: alizeb875@gmail.com", context);
        }
      }
      else
      {
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const loginScreen()));
        cMethods.displaySnackBar("your record do not exists as a User.", context);
      }
    });

  }


  /// this displays the ride details after user inputs his drop location from the search screen
  displayUserRideDetailsContainer() async{

    await retrieveDirectionDetails();

    setState(() {
      searchContainerHeight = 0;
      bottomMapPadding = 240;
      rideDetailsContainer = 242;
    });

  }

  retrieveDirectionDetails() async {

    var pickUpLocation = Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation = Provider.of<AppInfo>(context, listen: false).dropOffLocation;


    var pickUpGeographicCoOrdinate = LatLng(pickUpLocation!.latitudePosition!, pickUpLocation.longitudePosition!);
    var dropOffGeographicCoOrdinate = LatLng(dropOffDestinationLocation!.latitudePosition!, dropOffDestinationLocation.longitudePosition!);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => loadingDialog(messageText: "Getting details...",)
    );

    var detailsFromDirectionAPI = await CommonMethods.getDirectionsFromApi(pickUpGeographicCoOrdinate, dropOffGeographicCoOrdinate);

    setState(() {
      tripDirectionDetailsinfo = detailsFromDirectionAPI;
    });


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      /// drawer widget
      drawer: Container(
        width: 255,
        color: Colors.black,
        child: Drawer(
          backgroundColor: Colors.black,
          child: ListView(
            children: [

              /// header
              Container(
                color: Colors.white24,
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                  ),
                  child: Row(
                    children: [

                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            "assets/image1.png",
                          ),
                        ),
                      ),
                      // const Icon(
                      //   Icons.person,
                      //   size: 60,
                      // ),

                      const SizedBox(width: 16,),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text(
                              "$userName Nsofor",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                              "Profile",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),


              const Divider(
                height: 1,
                color: Colors.white,
                thickness: 1,
              ),

              /// body
              ListTile(
                leading: IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.info),
                ),
                title: const Text("About App", style: TextStyle(color: Colors.green),),
              ),

              ListTile(
                onTap: (){
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> const loginScreen()));
                  cMethods.displaySnackBar("you have logged out successfully", context);
                },
                leading: IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.logout),
                ),
                title: const Text("Logout", style: TextStyle(color: Colors.green),),
              ),

            ],
          ),
        ),
      ),

      body: Stack(
        children: [

          /// Map
          GoogleMap(
            padding: EdgeInsets.only(top: 30, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: googlePlexInitialPlex,
            onMapCreated: (GoogleMapController mapController) {

              controllerGoogleMap = mapController;

              updateMapTheme(mapController);

              googleMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                bottomMapPadding = 300;
              });

              getCurrentUserLocationOfUser();
            },
          ),

          /// drawer button
          Positioned(
            top: 40,
            left: 10,
            child: GestureDetector(
              onTap: (){
                sKey.currentState!.openDrawer();
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 2,
                      spreadRadius: 0.5,
                    )
                  ]
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          /// search/home/work button
          Positioned(
            left: 0,
            right: 0,
            bottom: -80,
            child: SizedBox(
              height: searchContainerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      /// waits for the response whenever the dropOff location is passed
                      var responseFromSearchPage = await Navigator.push(context, MaterialPageRoute(builder: (c)=> const searchDestinationPage()));

                      if(responseFromSearchPage == "placeSelected") {

                        /// prints the location out for us
                        // String dropOffLocation = Provider.of<AppInfo>(context, listen: false).dropOffLocation!.placeName ?? "";
                        // print(dropOffLocation + "This is your drop offff");

                        displayUserRideDetailsContainer();

                      }

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(
                      Icons.work,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),


          /// ride details container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: rideDetailsContainer,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.yellow,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(.7, .7),
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: SizedBox(
                        height: 200,
                        child: Card(
                          elevation: 10,
                          child: Container(
                            width: MediaQuery.of(context).size.width * .70,
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (tripDirectionDetailsinfo != null) ? tripDirectionDetailsinfo!.distanceTextString! : "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        Text(
                                          (tripDirectionDetailsinfo != null) ? tripDirectionDetailsinfo!.durationTextString! : "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: (){},
                                    child: Image.asset(
                                      "assets/uberexec.png",
                                      height: 122,
                                      width: 122,
                                    ),
                                  ),

                                  /// called cMethod and passed the model into it here to calculate price
                                  Text(
                                    (tripDirectionDetailsinfo != null) ? "\$ ${(cMethods.calculateFareAmount(tripDirectionDetailsinfo!)).toString()}" : "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ),

                        ),
                      ),
                    )
                  ],
                ),

              ),
            ),
          )

        ],
      ),
    );
  }
}
