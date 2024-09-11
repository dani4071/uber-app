import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:uber_app_drivers_app/global/global_var.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/direction_details_model.dart';


class CommonMethods
{
  checkConnectivity(BuildContext context) async
  {
    var connectionResult = await Connectivity().checkConnectivity();

    if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi)
    {
      if(!context.mounted) return;
      displaySnackBar("your Internet is not Available. Check your connection. Try Again.", context);
    }
  }

  displaySnackBar(String messageText, BuildContext context)
  {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  turnOffLocationUpdateForHomePage() {
    positionStreamHomePage!.pause();
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }

  turnOnLocationUpdateForHomePage() {
    positionStreamHomePage!.resume();
    Geofire.setLocation(
        FirebaseAuth.instance.currentUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );
  }

  static sendRequestToApi(String apiUrl) async {
    http.Response responseFromApi = await http.get(Uri.parse(apiUrl));

    try {

      if (responseFromApi.statusCode == 200){
        String dataFromApi = responseFromApi.body;
        var dataDeCoded = jsonDecode(dataFromApi);
        return dataDeCoded;

      } else {
        return 'error';
      }

    } catch (errorMsg) {
      return 'error';
    }
  }

  static Future<DirectionDetailsModel?> getDirectionsFromApi(LatLng source, LatLng direction) async {

    String urlDirectionsApi = "https://maps.googleapis.com/maps/api/directions/json?destination=${direction.latitude},${direction.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    var responseFromDirectionApi = await sendRequestToApi(urlDirectionsApi);

    if(responseFromDirectionApi == "error") {
      return null;
    }

    DirectionDetailsModel directionModel = DirectionDetailsModel();

    directionModel.distanceTextString = responseFromDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionModel.distanceValueDigit = responseFromDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionModel.durationTextString = responseFromDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionModel.distanceValueDigit = responseFromDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    directionModel.encodedPoints = responseFromDirectionApi["routes"][0]["overview_polyline"]["points"];

    return directionModel;
  }

  /// this calculates fare amount when the details model is passed
  calculateFareAmount(DirectionDetailsModel directionDetails) {

    double distancePerKmAmount = 0.4;
    double durationPerMinuteAmount = 0.3;
    double baseFareAmount = 2;

    double totalDistanceTravelFareAmount = (directionDetails.distanceValueDigit! / 1000) * distancePerKmAmount;
    /// how many minutes you spent on the ride
    double totalDurationSpendFareAmount = (directionDetails.distanceValueDigit! / 60) * durationPerMinuteAmount;

    double overAllTotalFareAmount = baseFareAmount + totalDistanceTravelFareAmount + totalDurationSpendFareAmount;

    return overAllTotalFareAmount.toStringAsFixed(2);


  }
}