import 'package:uber_app_clone/models/online_nearby_drivers_model.dart';

class manageDriverMethods {

  static List<OnlineNearbyDriversModel> nearbyOnlineDriversList = [];

  static void removeDriverFromList(String driverId) {
    int index = nearbyOnlineDriversList.indexWhere((driver) => driver.uidDriver == driverId);

    if(nearbyOnlineDriversList.length > 0) {
      nearbyOnlineDriversList.removeAt(index);
    }
  }


  static void updateOnlineNearbyDriversLocation(OnlineNearbyDriversModel nearbyOnlineDriverInformation) {
    int index = nearbyOnlineDriversList.indexWhere((driver) => driver.uidDriver == nearbyOnlineDriverInformation.uidDriver);


    nearbyOnlineDriversList[index].latDriver = nearbyOnlineDriverInformation.latDriver;
    nearbyOnlineDriversList[index].lngDriver = nearbyOnlineDriverInformation.lngDriver;
  }

}