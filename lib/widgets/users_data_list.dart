import 'package:admin_uber_web_panel/methods/commom_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class usersDataList extends StatefulWidget {
  const usersDataList({super.key});

  @override
  State<usersDataList> createState() => _usersDataListState();
}

class _usersDataListState extends State<usersDataList> {
  final usersRecordsFromDatabase = FirebaseDatabase.instance.ref().child("users");
  commonMethod cMethod = commonMethod();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      ///stream builder allows it to automatically always refresh
      stream: usersRecordsFromDatabase.onValue,
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

                ///name
                cMethod.data(
                    1,
                    Text(itemList[index]["name"].toString())),

                /// email
                cMethod.data(
                    1,
                    Text(itemList[index]["email"].toString())),

                /// phone
                cMethod.data(
                    1,
                    Text(itemList[index]["phone"].toString())),

                /// block / approve button
                cMethod.data(
                    1,
                    itemList[index]["blockStatus"] == "no"
                        ? ElevatedButton(
                      onPressed: () async {

                        await FirebaseDatabase.instance.ref()
                            .child("users")
                            .child(itemList[index]["id"])
                            .update({
                          "blockStatus": "yes"
                        });

                      },
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
                      onPressed: () async {
                        await FirebaseDatabase.instance.ref()
                            .child("users")
                            .child(itemList[index]["id"])
                            .update({
                          "blockStatus": "no"
                        });
                      },
                      child: const Text(
                        "Approve",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
