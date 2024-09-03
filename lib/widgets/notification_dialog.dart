import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uber_app_drivers_app/models/trip_details_model.dart';
import '../global/global_var.dart';
import 'loading_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_app_drivers_app/methods/common_methods.dart';
import 'package:uber_app_drivers_app/pages/new_trip_page.dart';

class notificationDialog extends StatefulWidget {
  notificationDialog({super.key, this.tripDetailsInfo});

  tripDetailsModel? tripDetailsInfo;

  @override
  State<notificationDialog> createState() => _notificationDialogState();
}

class _notificationDialogState extends State<notificationDialog> {
  String tripRequestStatus = "";
  CommonMethods cMethods = CommonMethods();

  cancelNotificationAfter20Secs() {
    const oneTrickPerSecond = Duration(seconds: 1);

    var timerCountDown = Timer.periodic(oneTrickPerSecond, (timer) {
      driverTripRequestTimeout = driverTripRequestTimeout - 1;

      if (tripRequestStatus == "accepted") {
        timer.cancel();
        driverTripRequestTimeout = 20;
        // checkAvailabilityOfTripRequest(context);
      }

      if (driverTripRequestTimeout == 0) {
        Navigator.pop(context);
        timer.cancel();
        driverTripRequestTimeout = 20;
        audioPlayer.stop();
      }
    });
  }


  @override
  void initState() {
    super.initState();
    cancelNotificationAfter20Secs();
  }

  ///[section 33] video 119
  checkAvailabilityOfTripRequest(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(
        messageText: 'Please wait...',
      ),
    );

    DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    await driverTripStatusRef.once().then((snap)
    {
      /// first context here was for popping of the dialog box that the driver clickeed, the second was to pop the loading dialog here in this function(up)
      Navigator.pop(context);
      Navigator.pop(context);

      /// so after the driver clicks it, we initialized a variable and stored the value from the snap to it
      String newTripStatusValue = "";
      if (snap.snapshot.value != null) {
        newTripStatusValue = snap.snapshot.value.toString();
      } else {
        cMethods.displaySnackBar("Trip Request Not Found.", context);
      }

      /// this is when the user clicks accept
      if (newTripStatusValue == widget.tripDetailsInfo!.tripID) {
        driverTripStatusRef.set("accepted");
        // tripRequestStatus == driverTripStatusRef.set("accepted");

        /// over here we set the trip status as accepted and we disable home page location on the driver ie the driver is no longer on the map, we paused his location
        /// and then we passed the trip-info ferom the top top[Widget.tripDegtailsInfo] to the new trip page
        // disable homepage location update
        print("this is meeeeeeeeeeeeeeeeeeeeeeee");
        cMethods.turnOffLocationUpdateForHomePage();
        cMethods.displaySnackBar("i worked hereeeeee", context);

        Navigator.push(context, MaterialPageRoute(builder: (c)=> newTripPage(tripDetails: widget.tripDetailsInfo)));

      } else if (newTripStatusValue == 'cancelled') {
        cMethods.displaySnackBar(
            "Trip Has Been Cancelled By The User.", context);
      } else if (newTripStatusValue == 'timeout') {
        cMethods.displaySnackBar("Trip Request Timed Out", context);
      }
      else
      {
        cMethods.displaySnackBar("Trip request removed, Not Found.", context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black54,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.black54, borderRadius: BorderRadius.circular(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 30.0,
            ),

            Image.asset(
              "assets/images/uberexec.png",
              width: 140,
            ),

            const SizedBox(
              height: 16.0,
            ),

            // title
            const Text(
              "NEW TRIP REQUEST",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 16.0,
            ),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            const SizedBox(
              height: 10.0,
            ),

            // pick - dropOff
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // pickup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/initial.png",
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Text(
                          widget.tripDetailsInfo!.pickUpAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // dropOff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/initial.png",
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Text(
                          widget.tripDetailsInfo!.pickUpAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20.0,
            ),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            // decline btn - accept btn
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        audioPlayer.stop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: const Text(
                        'DECLINE',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        audioPlayer.stop();
                        setState(() {
                          tripRequestStatus = "accepted";
                        });
                        checkAvailabilityOfTripRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: const Text(
                        'ACCEPT',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}
