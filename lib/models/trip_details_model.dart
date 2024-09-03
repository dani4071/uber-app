import 'package:google_maps_flutter/google_maps_flutter.dart';

class tripDetailsModel{

  String? tripID;

  LatLng? pickUpLatLng;
  String? pickUpAddress;

  LatLng? dropOffLatLng;
  String? dropOffAddress;

  String? userName;
  String? userPhone;

  tripDetailsModel({
    this.tripID,
    this.pickUpLatLng,
    this.pickUpAddress,
    this.dropOffLatLng,
    this.dropOffAddress,
    this.userName,
    this.userPhone,
});
}