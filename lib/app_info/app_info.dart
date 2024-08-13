import 'package:flutter/material.dart';
import 'package:uber_app_clone/models/address_model.dart';

/// provider over here was used to share the model so we can use them else where in my understanding
/// Also used to manage our application -uber app section 18 video 60


class AppInfo extends ChangeNotifier {

  addressModel? pickUpLocation;
  addressModel? dropOffLocation;

///
  void updatePickUpLocation(addressModel pickUpModel) {
    pickUpLocation = pickUpModel;
    notifyListeners();
  }


  void updateDropOffLocation(addressModel dropOffModel) {
    dropOffLocation = dropOffModel;
    notifyListeners();
  }
}