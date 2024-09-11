import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {

  final completedTripRequestOfCurrentUser = FirebaseDatabase.instance.ref().child("tripRequests");
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trips History",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,),
        ),
      ),

      body: StreamBuilder(
        stream: completedTripRequestOfCurrentUser.onValue,
        builder: (BuildContext context, snapshot)
        {
          if(snapshot.hasError)
          {
            return const Center(
              child: Text(
                "Error Occured",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            );
          }

          if(!(snapshot.hasData))
          {
            return const Center(
              child: Text(
                "No record found",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            );
          }

          /// video 145
          Map dataTrips = snapshot.data!.snapshot.value as Map;
          List tripList = [];
          //// over here each record has its key and its data
          dataTrips.forEach((key, value) => tripList.add({"key": key, ...dataTrips}));


          return ListView.builder(
            shrinkWrap: true,
            itemCount: tripList.length,
            itemBuilder: ((context, index){
              if(tripList[index]["status"] != null
                  && tripList[index]["status"] == "ended"
                  && tripList[index]["userID"] == FirebaseAuth.instance.currentUser!.uid)
              {
                return Card(
                  color: Colors.white12,
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // pickup - fare amount
                        Row(
                          children: [
                            Image.asset("assets/images/initial.png", height: 16, width: 16,),
                            
                            
                            const SizedBox(width: 18,),
                            
                            
                            Expanded(
                              child: Text(
                                tripList[index]["pickUpAddress"].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white38,
                                ),
                              ),
                            ),

                            const SizedBox(width: 5,),

                            Text(
                              "\$${tripList[index]["fareAmount"].toString()}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 8,),

                        // drop off
                        Row(
                          children: [
                            Image.asset("assets/images/final.png", height: 16, width: 16,),


                            const SizedBox(width: 18,),


                            Expanded(
                              child: Text(
                                tripList[index]["pickUpAddress"].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white38,
                                ),
                              ),
                            ),

                            const SizedBox(width: 5,),

                            Text(
                              tripList[index]["dropOffAddress"].toString(),
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              else{
                return Container();
              }
            }),
          );
        },
      ),
    );
  }
}
