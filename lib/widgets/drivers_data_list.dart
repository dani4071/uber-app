import 'package:admin_uber_web_panel/methods/commom_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class driversDataList extends StatefulWidget {
  const driversDataList({super.key});

  @override
  State<driversDataList> createState() => _driversDataListState();
}

class _driversDataListState extends State<driversDataList> {
  final driversRecordsFromDatabase = FirebaseDatabase.instance.ref().child("drivers");
  commonMethod cMethod = commonMethod();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      ///stream builder allows it to automatically always refresh
      stream: driversRecordsFromDatabase.onValue,
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
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /// id
                cMethod.data(
                    2,
                    Text(itemList[index]["id"].toString())),

                /// image
                cMethod.data(
                    1,
                    Image.network(
                  itemList[index]["photo"].toString(),
                  width: 50,
                  height: 50,
                )),

                ///name
                cMethod.data(
                    1,
                    Text(itemList[index]["name"].toString())),

                /// car details
                cMethod.data(
                    1,
                    Text(itemList[index]["car_details"]["carModel"].toString()
                        + "-"
                        + itemList[index]["car_details"]["carNumber"].toString())),
                /// phone
                cMethod.data(
                    1,
                    Text(itemList[index]["phone"].toString())),

                /// earnings
                cMethod.data(
                    1,
                    itemList[index]["earnings"] != null
                        ? Text("\$ " + itemList[index]["earnings"].toString())
                        : const Text("\$0")),

                /// block / approve button
                cMethod.data(
                    1,
                  itemList[index]["blockStatus"] == "no"
                ? ElevatedButton(
                        onPressed: () {},
                        child: const Text(
                          "Block",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red
                    ),
                  )
                : ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        "Approve",
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
          }),
        );
      },
    );
  }
}
