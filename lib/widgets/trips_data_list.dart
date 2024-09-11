import 'package:admin_uber_web_panel/methods/commom_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TripsDataList extends StatefulWidget {
  const TripsDataList({super.key});

  @override
  State<TripsDataList> createState() => _TripsDataListState();
}



class _TripsDataListState extends State<TripsDataList> {
  final completeTripsRecordsFromDatabase = FirebaseDatabase.instance.ref().child("tripRequests");
  commonMethod cMethod = commonMethod();

  launchGoogleMapFromSourceToLocation(pickUpLat,pickUpLng,dropOffLat, dropOffLng) async {
    String directionAPIurl = "https://www.google.com/maps/dir/?api=1&origin=$pickUpLat,$pickUpLng&destination=$dropOffLat,$dropOffLng&dir_action=navigate";

    if(await canLaunchUrl(Uri.parse(directionAPIurl))){

      await launchUrl(Uri.parse(directionAPIurl));
    }
    else {
      throw "Cant Load the map";
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      ///stream builder allows it to automatically always refresh
      stream: completeTripsRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          return const Center(
            child: Text(
              "Erroor Occurred. Try Later.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.green,
              ),
            ),
          );
        }



        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()
          );
        }

        /// converting the data to to map from json,
        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List itemList = [];
        /// this loops each data and parse it to itemlist using key [uber app clone video 45, incase you dont get]
        dataMap.forEach((key, value) {
          itemList.add({"Key": key, ...value});
        });

        return ListView.builder(
          shrinkWrap: true,
          itemCount: itemList.length,
          itemBuilder: ((context, index) {


            if(itemList[index]["status"] != null && itemList[index]["status"] == "ended")
            {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// id
                  cMethod.data(
                      2,
                       Text(itemList[index]["tripID"].toString())),

                  ///name
                  cMethod.data(
                      1,
                      Text(itemList[index]["userName"].toString())),

                  /// email
                  cMethod.data(
                      1,
                      Text(itemList[index]["driverName"].toString())),

                  /// phone
                  cMethod.data(
                      1,
                      Text(itemList[index]["carDetails"].toString())),

                  cMethod.data(
                      1,
                      Text(itemList[index]["publishedDateTime"].toString())),

                  cMethod.data(
                      1,
                      Text("\$" + itemList[index]["fareAmount"].toString())),

                  /// view on google map
                  cMethod.data(
                      1,
                      ElevatedButton(
                        onPressed: () {

                          String pickUpLat = itemList[index]["pickUpLatLng"]["latitude"];
                          String pickUpLng = itemList[index]["pickUpLatLng"]["longitude"];



                          String dropOffLat = itemList[index]["dropOffLatLng"]["latitude"];
                          String dropOffLng = itemList[index]["dropOffLatLng"]["longitude"];



                          launchGoogleMapFromSourceToLocation(pickUpLat,pickUpLng,dropOffLat, dropOffLng);
                        },
                        child: const Text(
                          "View More",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      )
                  )
                ],
              );
            }
            else {
              return Container();
            }
          }),
        );
      },
    );
  }
}
