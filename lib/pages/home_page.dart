import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:uber_app_clone/app_info/app_info.dart';
import 'package:uber_app_clone/authentication/login_screen.dart';
import 'package:uber_app_clone/global/global_variables.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_app_clone/global/trip_var.dart';
import 'package:uber_app_clone/methods/push_notification_service.dart';
import 'package:uber_app_clone/models/direction_details_model.dart';
import 'package:uber_app_clone/models/online_nearby_drivers_model.dart';
import 'package:uber_app_clone/pages/about_page.dart';
import 'package:uber_app_clone/pages/search_destination_page.dart';
import 'package:uber_app_clone/pages/trips_history_page.dart';
import 'package:uber_app_clone/widgets/info_dialog.dart';
import 'package:uber_app_clone/widgets/loading_dialog.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:uber_app_clone/widgets/payment_dialog.dart';
import '../methods/common_methods.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import '../methods/manage_drivers_methods.dart';
import 'package:url_launcher/url_launcher.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  DirectionDetailsModel? tripDirectionDetailsinfo;
  List<LatLng> polylineCoOrdinates = [];

  /// a set is an unordered collection of unique items
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  bool isDrawerOpen = true;
  String stateOfApp = "normal";
  bool nearbyOnlineDriversKeysLoaded = false;
  BitmapDescriptor? carIconNearbyDriver;
  DatabaseReference? tripReferenceRef;
  List<OnlineNearbyDriversModel>? availableNearbyOnlineDriversList;
  StreamSubscription<DatabaseEvent>? tripStreamSubscription;
  bool requestingDirectionDetailsInfo = false;

  /// check the audio and check the time out

  /// driver icon on map
  /// this was called in the widget build so the icons load
  makeDriverNearbyCarIcon() {
    if (carIconNearbyDriver == null) {
      ImageConfiguration configuration =
          createLocalImageConfiguration(context, size: const Size(0.5, 0.5));
      BitmapDescriptor.fromAssetImage(configuration, "assets/tracking.png")
          .then((iconImage) {
        carIconNearbyDriver = iconImage;
      });
    }
  }

  /// styling map design
  void updateMapTheme(GoogleMapController controller) {
    getJsonFromTheme("theme/map/night_style.json")
        .then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFromTheme(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }

  /// ///////////////////////////////////////

  /// Getting user current Location
  getCurrentUserLocationOfUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    /// human readable address
    await CommonMethods.convertGeoGraphicsCoordinatesIntoHumanReadableAddress(
        currentPositionOfUser!, context);

    await getUserInfoAndCheckBlockStatus();

    await initializeGeoFireListener();
  }

  /// checking if the user is blocked by the admin
  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
          });
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => const loginScreen()));
          cMethods.displaySnackBar(
              "you are blocked. Contact admin: alizeb875@gmail.com", context);
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const loginScreen()));
        cMethods.displaySnackBar(
            "your record do not exists as a User.", context);
      }
    });
  }

  /// this displays the ride details after user inputs his drop location from the search screen
  displayUserRideDetailsContainer() async {
    await retrieveDirectionDetails();

    setState(() {
      searchContainerHeight = 0;
      bottomMapPadding = 240;
      rideDetailsContainerHeight = 242;
      isDrawerOpen = false;
    });
  }

  /// this is called above
  ///  responsible for retrieving directions to drop off location and also the polylines and circles on the map
  retrieveDirectionDetails() async {
    var pickUpLocation =
        Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation =
        Provider.of<AppInfo>(context, listen: false).dropOffLocation;

    var pickUpGeographicCoOrdinate = LatLng(
        pickUpLocation!.latitudePosition!, pickUpLocation.longitudePosition!);
    var dropOffGeographicCoOrdinate = LatLng(
        dropOffDestinationLocation!.latitudePosition!,
        dropOffDestinationLocation.longitudePosition!);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => loadingDialog(
              messageText: "Getting details...",
            ));

    var detailsFromDirectionAPI = await CommonMethods.getDirectionsFromApi(
        pickUpGeographicCoOrdinate, dropOffGeographicCoOrdinate);

    setState(() {
      tripDirectionDetailsinfo = detailsFromDirectionAPI;
    });

    Navigator.pop(context);

    /// this below is very easy, dont get overwhelmed, the comments explains it all

    /// this is responsible for drawing lines on the map, polylines
    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPointsFromPickToDestination =
        pointsPolyline.decodePolyline(tripDirectionDetailsinfo!.encodedPoints!);

    // draw route from pickUp to drop off Destination
    /// making sure theres nothing on it at the moment
    polylineCoOrdinates.clear();

    /// this polyline points is a like a lot of latlng coordinates, so that the map would trace along those line
    /// over here we get the latlngs' and add it to our list of polylineCoOrdinate one by one.
    /// video 75 -1:03 would explain more on polylines
    if (latLngPointsFromPickToDestination.isNotEmpty) {
      for (var latlngPoint in latLngPointsFromPickToDestination) {
        polylineCoOrdinates
            .add(LatLng(latlngPoint.latitude, latlngPoint.longitude));
      }
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("polylineID"),
        color: Colors.pink,
        points: polylineCoOrdinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });

    // fit polyline into map
    /// make the polyline fit into the map ie those lines to fit in the roads and not become too large when you zoom
    LatLngBounds boundsLatlng;
    if (pickUpGeographicCoOrdinate.latitude >
            dropOffGeographicCoOrdinate.latitude &&
        pickUpGeographicCoOrdinate.longitude >
            dropOffGeographicCoOrdinate.longitude) {
      boundsLatlng = LatLngBounds(
          southwest: dropOffGeographicCoOrdinate,
          northeast: pickUpGeographicCoOrdinate);
    } else if (pickUpGeographicCoOrdinate.longitude >
        dropOffGeographicCoOrdinate.longitude) {
      boundsLatlng = LatLngBounds(
          southwest: LatLng(pickUpGeographicCoOrdinate.latitude,
              dropOffGeographicCoOrdinate.longitude),
          northeast: LatLng(dropOffGeographicCoOrdinate.latitude,
              pickUpGeographicCoOrdinate.longitude));
    } else if (pickUpGeographicCoOrdinate.latitude >
        dropOffGeographicCoOrdinate.latitude) {
      boundsLatlng = LatLngBounds(
        southwest: LatLng(dropOffGeographicCoOrdinate.latitude,
            pickUpGeographicCoOrdinate.longitude),
        northeast: LatLng(pickUpGeographicCoOrdinate.latitude,
            dropOffGeographicCoOrdinate.longitude),
      );
    } else {
      boundsLatlng = LatLngBounds(
        southwest: pickUpGeographicCoOrdinate,
        northeast: dropOffGeographicCoOrdinate,
      );
    }

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatlng, 72));

    /// add marker to pickup and dropOffdestination
    Marker pickUpPointMaker = Marker(
      markerId: const MarkerId("pickUpPointMakerID"),
      position: pickUpGeographicCoOrdinate,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
          title: pickUpLocation.placeName, snippet: "Pickup Location"),
    );

    Marker dropOffDestinationPointMaker = Marker(
      markerId: const MarkerId("dropOffDestinationPointMakerID"),
      position: dropOffGeographicCoOrdinate,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
          title: dropOffDestinationLocation.placeName,
          snippet: "Destination Location"),
    );

    setState(() {
      markerSet.add(pickUpPointMaker);
      markerSet.add(dropOffDestinationPointMaker);
    });

    /// add circle to pickup and dropOffdestination
    Circle pickUpPointCircle = Circle(
        circleId: const CircleId("pickUpPointCircleID"),
        strokeColor: Colors.blue,
        strokeWidth: 4,
        radius: 14,
        center: pickUpGeographicCoOrdinate,
        fillColor: Colors.pink);

    Circle dropOffDestinationPointCircle = Circle(
        circleId: const CircleId("dropOffDestinationPointCircleID"),
        strokeColor: Colors.blue,
        strokeWidth: 4,
        radius: 14,
        center: dropOffGeographicCoOrdinate,
        fillColor: Colors.green);

    setState(() {
      circleSet.add(pickUpPointCircle);
      circleSet.add(dropOffDestinationPointCircle);
    });
  }

  /// ///////////////////

  /// i believe this just means to clear all polylines and start again
  resetApp()
  {
    setState(() {
      polylineCoOrdinates.clear();
      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      tripContainerHeight = 0;
      requestContainerHeight = 0;
      searchContainerHeight = 276;
      bottomMapPadding = 300;
      isDrawerOpen = true;

      status = "";
      nameDriver = "";
      photoDriver = "";
      phoneNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDisplay = "Driver is Arriving";
    });
    cMethods.displaySnackBar("No driver found", context);
  }

  displayRequestContainer()
  {
    setState(() {
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 242;
      bottomMapPadding = 200;
      isDrawerOpen = true;
    });

    // send ride request
    makeTripRequest();
  }

  cancelRideRequest()
  {
    // remove ride request from database
    tripReferenceRef!.remove();

    setState(() {
      stateOfApp = "normal";
    });
  }

  updateAvailableNearbyOnlineDriverOnMap()
  {
    setState(() {
      markerSet.clear();
    });

    Set<Marker> markersTempSet = <Marker>{};

    for (OnlineNearbyDriversModel eachOnlineNearbyDriver
        in manageDriverMethods.nearbyOnlineDriversList) {
      LatLng driverCurrentPosition = LatLng(
          eachOnlineNearbyDriver.latDriver!, eachOnlineNearbyDriver.lngDriver!);

      Marker driverMarker = Marker(
        // here
        markerId: MarkerId("driver ID = ${eachOnlineNearbyDriver.uidDriver}"),
        position: driverCurrentPosition,
        icon: carIconNearbyDriver!,
      );

      markersTempSet.add(driverMarker);
    }

    setState(() {
      markerSet = markersTempSet;
    });
  }

  /// SECTION[26] video 90,91,92
  initializeGeoFireListener()
  {
    Geofire.initialize("onlineDrivers");
    Geofire.queryAtLocation(currentPositionOfUser!.latitude,
            currentPositionOfUser!.longitude, 22)!
        .listen((driverEvent) {
      if (driverEvent != null) {
        var onlineDriverChild = driverEvent["callBack"];

        switch (onlineDriverChild) {
          /// when a driver enters within the radius of the user, remember we specified the user
          case Geofire.onKeyEntered:
            OnlineNearbyDriversModel onlineNearbyDrivers =
                OnlineNearbyDriversModel();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
            manageDriverMethods.nearbyOnlineDriversList
                .add(onlineNearbyDrivers);

            if (nearbyOnlineDriversKeysLoaded == true) {
              // update driver location on map
              updateAvailableNearbyOnlineDriverOnMap();
            }
            break;

          /// when the driver leaves the radius of the user, we remove the driver from the list
          case Geofire.onKeyExited:
            // the driver key is the driver id
            manageDriverMethods.removeDriverFromList(driverEvent["key"]);

            updateAvailableNearbyOnlineDriverOnMap();
            break;

          /// when the driver moves WITHIN the radius, this event is fired
          case Geofire.onKeyMoved:
            OnlineNearbyDriversModel onlineNearbyDrivers =
                OnlineNearbyDriversModel();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
            manageDriverMethods
                .updateOnlineNearbyDriversLocation(onlineNearbyDrivers);

            updateAvailableNearbyOnlineDriverOnMap();
            break;

          /// the first time the user open the app, this displays the oline drivers
          case Geofire.onGeoQueryReady:
            nearbyOnlineDriversKeysLoaded = true;

            // update driver on google map
            updateAvailableNearbyOnlineDriverOnMap();
            break;
        }
      }
    });
  }

  makeTripRequest() {
    /// created a reference in the database by using push, also push makes it give unique id
    tripReferenceRef =
        FirebaseDatabase.instance.ref().child("tripRequests").push();

    var pickUpLocation =
        Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var dropOffLocation =
        Provider.of<AppInfo>(context, listen: false).dropOffLocation;

    /// user pickup lat lng
    Map pickUpCordinatesMap = {
      "latitude": pickUpLocation!.latitudePosition.toString(),
      "longitude": pickUpLocation.longitudePosition.toString(),
    };

    /// user dropOff lat lng
    Map dropOffDestinationCoordinatesMap = {
      "latitude": dropOffLocation!.latitudePosition.toString(),
      "longitude": dropOffLocation.longitudePosition.toString(),
    };

    Map driverCoordinates = {
      "latitude": "",
      "longitude": "",
    };

    Map dataMap = {
      "tripID": tripReferenceRef!.key,
      "publishedDateTime": DateTime.now().toString(),
      "userName": userName,
      "userPhone": userPhone,
      "userID": userID,
      "pickUpLatLng": pickUpCordinatesMap,
      "dropOffLatLng": dropOffDestinationCoordinatesMap,
      "pickUpAddress": pickUpLocation.placeName,
      "dropOffAddress": dropOffLocation.placeName,
      "driverID": "waiting",
      "carDetails": "",
      "driverLocation": driverCoordinates,
      "driverName": "",
      "driverPhone": "",
      "driverPhoto": "",
      "fareAmount": "",
      "status": "new",
    };

    tripReferenceRef!.set(dataMap);

    /// vidoe 136 - section 38
    /// this below listens when a driver accepts a trip request,
    /// now after the driver
    /// accepts it, it checks if its not empty, if
    /// its not then we proceed to get the details and display to the user
    tripStreamSubscription =
        tripReferenceRef!.onValue.listen((eventSnapShot) async {
      if (eventSnapShot.snapshot.value == null) {
        return;
      }
      if ((eventSnapShot.snapshot.value as Map)["driverName"] != null) {
        nameDriver = (eventSnapShot.snapshot.value as Map)["driverName"];
      }
      if ((eventSnapShot.snapshot.value as Map)["driverPhone"] != null) {
        phoneNumberDriver =
            (eventSnapShot.snapshot.value as Map)["driverPhone"];
      }
      if ((eventSnapShot.snapshot.value as Map)["driverPhoto"] != null) {
        photoDriver = (eventSnapShot.snapshot.value as Map)["driverPhoto"];
      }
      if ((eventSnapShot.snapshot.value as Map)["car_details"] != null) {
        nameDriver = (eventSnapShot.snapshot.value as Map)["car_details"];
      }
      if ((eventSnapShot.snapshot.value as Map)["status"] != null) {
        status = (eventSnapShot.snapshot.value as Map)["status"];
      }
      if ((eventSnapShot.snapshot.value as Map)["driverLocation"] != null) {
        double driverLatitude = double.parse(
            (eventSnapShot.snapshot.value as Map)["driverLocation"]["latitude"]
                .toString());
        double driverlongitude = double.parse(
            (eventSnapShot.snapshot.value as Map)["driverLocation"]["longitude"]
                .toString());
        LatLng driverCurrentLocation = LatLng(driverLatitude, driverlongitude);

        if (status == "accepted") {
          // update infor for pickup to user on UI
          //info from driver current location to user pickUp location
          updateFromDriverCurrentLocationToPickUp(driverCurrentLocation);
        } else if (status == "arrived") {
          // update infor for arrived - when driver reah at the pickup point of user
          setState(() {
            tripStatusDisplay = "Driver has Arrived";
          });
        } else if (status == "ontrip") {
          // update info for dropOff to user on UI
          //
          updateFromDriverCurrentLocationToDropOffDestination(
              driverCurrentLocation);
        }
      }

      if (status == "accepted") {
        displayTripDetailsContainer();

        Geofire.stopListener();

        setState(() {
          // removing the marker ID using by using if it contains a keyword driver in its ID, check where you set the market vidoe 139
          markerSet.removeWhere(
              (element) => element.markerId.value.contains("driver"));
        });
      }

      if (status == "ended") {
        if ((eventSnapShot.snapshot.value as Map)["fareAmount"] != null) {
          double fareAmount = double.parse(
              (eventSnapShot.snapshot.value as Map)["fareAmount"].toString());

          /// this over here is waiting for the user to click paid then it executes
          /// video 142 6:00
          var responseFromDialog = await showDialog(
            context: context,
            builder: (BuildContext context) =>
                PaymentDialog(fareAmount: fareAmount.toString()),
          );

          if (responseFromDialog == "paid") {
            tripReferenceRef!.onDisconnect();
            tripReferenceRef = null;

            tripStreamSubscription!.cancel();
            tripStreamSubscription = null;

            resetApp();

            Restart.restartApp();
          }
        }
      }
    });
  }

  displayTripDetailsContainer()
  {
    setState(() {
      requestContainerHeight = 0;
      tripContainerHeight = 291;
      bottomMapPadding = 281;
    });
  }

  updateFromDriverCurrentLocationToPickUp(driverCurrentLocation) async
  {
    // this means once its false, and by default when we initialized it we made it false.. so the statement executes
    if (!requestingDirectionDetailsInfo) {
      requestingDirectionDetailsInfo = true;

      var userPickUpLocationLatLng = LatLng(
          currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

      var directionDetailsPickUp = await CommonMethods.getDirectionsFromApi(
          driverCurrentLocation, userPickUpLocationLatLng);

      // if its equals to null we dont proceed further thats what this line is responsible for
      if (directionDetailsPickUp == null) {
        return;
      }

      setState(() {
        tripStatusDisplay =
            "Driver is Coming in ${directionDetailsPickUp.durationTextString}";
      });

      requestingDirectionDetailsInfo = false;

      /// this whole here is like a loop, cause we execute its
      /// false, then we set it to true, the the lase last
      /// line sets it to false again so we go again, till the
      /// driver arrives and ends the trip, this allows us to
      /// continually get the duration video 137 8:00
    }
  }

  updateFromDriverCurrentLocationToDropOffDestination(driverCurrentLocation) async
  {
    if (!requestingDirectionDetailsInfo) {
      requestingDirectionDetailsInfo = true;

      var dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).dropOffLocation;
      var userDropOffLocationLatLng = LatLng(dropOffLocation!.latitudePosition!,
          dropOffLocation.longitudePosition!);

      var directionDetailsPickUp = await CommonMethods.getDirectionsFromApi(
          driverCurrentLocation, userDropOffLocationLatLng);

      // if its equals to null we don't proceed further thats what this line is responsible for
      if (directionDetailsPickUp == null) {
        return;
      }

      setState(() {
        tripStatusDisplay =
            "Driving to Drop-Off Location ${directionDetailsPickUp.durationTextString}";
      });

      requestingDirectionDetailsInfo = false;
    }
  }

  noDriverAvailable()
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => infoDialog(
              title: "No Driver Available",
              description:
                  "No driver found in the nearby location. Please try again shortly",
            ));
  }

  searchDriver()
  {
    /// what this does is, it takes all the available drivers and put in a list, -
    /// now it sends notification to the first driver -
    /// which has the index of of 0, then if the driver -
    /// didnt respond it removes the driver from the list -
    /// and sends a new notification to the next one which has an index of 0 now -
    /// video 116 - 5:50
    if (availableNearbyOnlineDriversList!.isEmpty) {
      cancelRideRequest();
      resetApp();
      noDriverAvailable();
      return;
    }

    var currentDriver = availableNearbyOnlineDriversList![0];

    // send notification to this current driver - current driver simply means selected driver
    sendNotificationToDriver(currentDriver);

    availableNearbyOnlineDriversList!.removeAt(0);
  }

  sendNotificationToDriver(OnlineNearbyDriversModel currentDriver)
  {
    /// update driver's newTripStatus - assign tripID to current driver
    DatabaseReference currentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("newTripStatus");

    currentDriverRef.set(tripReferenceRef!.key);

    /// get current driver device recognition token, its this token that we can use to send notification
    DatabaseReference tokenOfCurrentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("deviceToken");

    /// once we get the token, i think this "once" here means that once we get it
    tokenOfCurrentDriverRef.once().then((dataSnapshot) {
      if (dataSnapshot.snapshot.value != null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();

        /// send notification
        PushNotificationService.sendNotificationToSelectedDriver(
            deviceToken, context, tripReferenceRef!.key.toString());
      } else {
        return;
      }

      const oneTickPerSecond = Duration(seconds: 1);

      var itemCountDown = Timer.periodic(oneTickPerSecond, (timer) {
        requestTimeOutDriver = requestTimeOutDriver - 1;

        //when trip request is not requesting means trip request cancelled - stop timer
        if (stateOfApp != "requesting") {
          timer.cancel();
          currentDriverRef.set("cancelled");
          currentDriverRef.onDisconnect();
          requestTimeOutDriver = 20;
        }

        // when trip request is accepted by online nearest available driver
        currentDriverRef.onValue.listen((dataSnapshot) {
          if (dataSnapshot.snapshot.value.toString() == "accepted") {
            timer.cancel();
            currentDriverRef.onDisconnect();
            requestTimeOutDriver = 20;
          }
        });

        // if 20 seconds passed - send notification to the next nearest online available driver
        if (requestTimeOutDriver == 0) {
          currentDriverRef.set("timeout");
          timer.cancel();
          currentDriverRef.onDisconnect();
          requestTimeOutDriver == 20;

          // send notification to the next nearest online available driver
          searchDriver();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    makeDriverNearbyCarIcon();

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

                      const SizedBox(
                        width: 16,
                      ),

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
                          Text(
                            googleMapKey,
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
              GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const AboutPage()));
                },
                child: const ListTile(
                  leading: Icon(Icons.info),
                  title: Text(
                    "About App",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),

              GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const TripsHistoryPage()));
                },
                child: const ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    "History",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),

              ListTile(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const loginScreen()));
                  cMethods.displaySnackBar(
                      "you have logged out successfully", context);
                },
                leading: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.logout),
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.green),
                ),
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
            polylines: polylineSet,
            markers: markerSet,
            circles: circleSet,
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
              onTap: () {
                if (isDrawerOpen == true) {
                  sKey.currentState!.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: isDrawerOpen ? Colors.grey : Colors.red,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: isDrawerOpen ? Colors.white : Colors.red,
                        blurRadius: 2,
                        spreadRadius: 0.5,
                      )
                    ]),
                child: Icon(
                  isDrawerOpen ? Icons.menu : Icons.close,
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
                      var responseFromSearchPage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const searchDestinationPage()));
                      //  Navigator.push(context, MaterialPageRoute(builder: (c)=> const searchDestinationPage()));

                      if (responseFromSearchPage == "placeSelected") {
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
                    onPressed: () {},
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
                    onPressed: () {},
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
              height: rideDetailsContainerHeight,
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
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (tripDirectionDetailsinfo != null)
                                              ? tripDirectionDetailsinfo!
                                                  .distanceTextString!
                                              : "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          (tripDirectionDetailsinfo != null)
                                              ? tripDirectionDetailsinfo!
                                                  .durationTextString!
                                              : "",
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
                                    onTap: () {
                                      setState(() {
                                        stateOfApp = "requesting";
                                      });

                                      displayRequestContainer();

                                      // get nearest available online driver
                                      availableNearbyOnlineDriversList =
                                          manageDriverMethods
                                              .nearbyOnlineDriversList;

                                      // search driver
                                      searchDriver();
                                    },
                                    child: Image.asset(
                                      "assets/uberexec.png",
                                      height: 122,
                                      width: 122,
                                    ),
                                  ),

                                  /// called cMethod and passed the model into it here to calculate price
                                  Text(
                                    (tripDirectionDetailsinfo != null)
                                        ? "\$ ${(cMethods.calculateFareAmount(tripDirectionDetailsinfo!)).toString()}"
                                        : "",
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
          ),

          /// request container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: requestContainerHeight,
              decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ]),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: 200,
                      child: LoadingAnimationWidget.flickr(
                        leftDotColor: Colors.greenAccent,
                        rightDotColor: Colors.pinkAccent,
                        size: 50,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        resetApp();
                        cancelRideRequest();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 1.5, color: Colors.grey),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          /// trip details container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: tripContainerHeight,
              decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white24,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tripStatusDisplay,
                          style:
                              const TextStyle(fontSize: 19, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 19,
                    ),

                    const Divider(
                      height: 1,
                      color: Colors.white70,
                      thickness: 1,
                    ),

                    const SizedBox(
                      height: 19,
                    ),

                    // Image -  driver name and driver car details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.network(
                            photoDriver == ''
                                ? "https://firebasestorage.googleapis.com/v0/b/uber-app-b9023.appspot.com/o/Images%2Favatarman.png?alt=media&token=5892a33b-32df-4551-ac97-efad00934587"
                                : photoDriver,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameDriver,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              carDetailsDriver,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    const Divider(
                      height: 1,
                      color: Colors.white70,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 19,
                    ),

                    // call driver btn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse("tel://$phoneNumberDriver"));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    )),
                                child: const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 11,
                              ),
                              const Text(
                                "Call",
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        )
                      ],
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
