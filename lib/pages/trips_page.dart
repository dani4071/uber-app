import 'package:admin_uber_web_panel/widgets/trips_data_list.dart';
import 'package:flutter/material.dart';

import '../methods/commom_methods.dart';


class tripsPage extends StatefulWidget {

  static const String id = "\webPageTrips";

  const tripsPage({super.key});

  @override
  State<tripsPage> createState() => _tripsPageState();
}

class _tripsPageState extends State<tripsPage> {

  commonMethod cMethod = commonMethod();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topRight,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    "Manage Trips",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  cMethod.header(2, 'TRIP ID'),
                  cMethod.header(1, 'USER NAME'),
                  cMethod.header(1, 'DRIVER NAME'),
                  cMethod.header(1, 'CAR DETAILS'),
                  cMethod.header(1, 'TIMING'),
                  cMethod.header(1, 'FARE'),
                  cMethod.header(1, 'ACTION'),
                ],
              ),

              TripsDataList(),
            ],
          ),
        )
    );
  }
}
