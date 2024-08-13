// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
//
// class CommonMethods
// {
//   checkConnectivity(BuildContext context) async
//   {
//     //var connectionResult = await (Connectivity().checkConnectivity());
//
//     final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
//
//     if(connectivityResult.contains(ConnectivityResult.mobile) && connectivityResult.contains(ConnectivityResult.wifi))
//     // if(!connectionResult.contains(ConnectivityResult.mobile)  && !connectionResult.contains(ConnectivityResult.wifi))
//     //// this or you could downgrade the package
//     {
//       if(!context.mounted) return;
//       displaySnackBar("YOUR Internet is not Available. Check your connection. Try Again.", context);
//     }
//   }
//
//   displaySnackBar(String messageText, BuildContext context)
//   {
//     var snackBar = SnackBar(content: Text(messageText));
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }

import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_app_clone/app_info/app_info.dart';
import 'package:uber_app_clone/global/global_variables.dart';
import 'package:http/http.dart' as http;
import 'package:uber_app_clone/models/address_model.dart';
import 'package:provider/provider.dart';

import '../models/direction_details_model.dart';


class CommonMethods
{
  checkConnectivity(BuildContext context) async
  {
    var connectionResult = await Connectivity().checkConnectivity();

    //// this works with connectivity 6.0.0
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

  /// this helps us for reserve geo coding, to take lat and longs to convert them to human readable text
  static Future<String> convertGeoGraphicsCoordinatesIntoHumanReadableAddress(Position position, BuildContext context) async {
    String humanReadableAddress = "";
    String apiGeoCordingUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";

    var responseFromApi = await sendRequestToApi(apiGeoCordingUrl);

    if(responseFromApi != 'error') {
      humanReadableAddress = responseFromApi['results'][0]['formatted_address'];
      print("Human Readable Address Here: $humanReadableAddress");


      addressModel model = addressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      /// provider over here was used to share the model so we can use them else where in my understanding
      /// we shared this model with the help of our provider
      /// provider is used to manage state
      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(model);
    }

    return humanReadableAddress;
  }

  /// this gets the direction distance, time from the direction API
  /// Direction API
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