import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


String userName = "";
String userPhone = "";
String userID = FirebaseAuth.instance.currentUser!.uid;
//// create a new api, go to console.google, api librabry, crendentials, on the top click +create credentials,Api then use that one
String googleMapKey = "AIzaSyBtKVLmxswZsJ9nIeTUvrL7j1z9XGUhzPA";

const CameraPosition googlePlexInitialPlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

