import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


String userName = "";
String userPhone = "";
String userID = FirebaseAuth.instance.currentUser!.uid;
//// create a new api, go to console.google, api librabry, crendentials, on the top click +create credentials,Api then use that one
// String googleMapKey = "AIzaSyBtKVLmxswZsJ9nIeTUvrL7j1z9XGUhzPA";
// String googleMapKey = googleMapKkey() as String;
String googleMapKey = "";
String projectId = '';
String privateKeyId = '';
String privateKey = '';
String clientEmail ='';
String clientId = '';


const CameraPosition googlePlexInitialPlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

// googleMapKey() async {
//   await dotenv.load(fileName: "lib/.env");
//
//   String? googleMapKey = dotenv.env['googleMapKey'];
//
//   return googleMapKey;
// }
// Future<String> googleMapKkey() async {
//   await dotenv.load(fileName: "lib/.env");
//
//   // Use a fallback value in case the environment variable is null.
//   String googleMapKey = dotenv.env['googleMapKey'] ?? '';
//
//   return googleMapKey;
// }