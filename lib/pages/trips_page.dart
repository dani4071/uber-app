import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uber_app_drivers_app/pages/trips_history_page.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {

  String currentDriverTotalTripsCompleted = "";


  getCurrentDriverTotalNumberOfTripsComplete() async
  {
    DatabaseReference tripRequestRef = FirebaseDatabase.instance.ref().child("tripRequests");

    /// what we did here was monitor the trip request, if theres value then
    /// we assign it into a map, then we run a for loop on the map >line 32
    /// the loop goes like, if the status is not null then if then status is ended
    /// then if the status ID has the same id with the current driver then we add it into our
    /// list tripsCompletedByCurrentDriver. beautiful programming right here
    /// video 144 10:00

    tripRequestRef.once().then((snap) async {
      if(snap.snapshot.value != null)
        {
          Map<dynamic, dynamic> allTripsMap = snap.snapshot.value as Map;
          // int allTripsLength = allTripsMap.length;

          List<String> tripsCompletedByCurrentDriver = [];


          allTripsMap.forEach((key, value){

            if(value["status"] != null){
              if(value["status"] == "ended"){
                if(value["driverID"] == FirebaseAuth.instance.currentUser!.uid){
                  tripsCompletedByCurrentDriver.add(key);
                }
              }
            }
          });

          setState(() {
            currentDriverTotalTripsCompleted = tripsCompletedByCurrentDriver.length.toString();
          });

        }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [


          // Total trips
          Center(
            child: Container(
              color: Colors.indigo,
              width: 300,
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [

                    Image.asset("assets/images/totaltrips.png", width: 120,),

                    const SizedBox(
                      height: 10,
                    ),


                    const Text(
                      "Total Trips",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),


                    Text(
                    currentDriverTotalTripsCompleted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),


          const SizedBox(height: 20,),

          // check trip history
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (c)=> TripsHistoryPage()));
            },
            child: Center(
              child: Container(
                color: Colors.indigo,
                width: 300,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [

                      Image.asset("assets/images/tripscompleted.png", width: 120,),

                      const SizedBox(
                        height: 10,
                      ),


                      const Text(
                        "Check Trips History",
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
