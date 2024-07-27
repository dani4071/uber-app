import 'package:admin_uber_web_panel/methods/commom_methods.dart';
import 'package:admin_uber_web_panel/widgets/drivers_data_list.dart';
import 'package:flutter/material.dart';


class driversPage extends StatefulWidget {

  static const String id = "\webPageDrivers";

  const driversPage({super.key});

  @override
  State<driversPage> createState() => _driversPageState();
}

class _driversPageState extends State<driversPage> {

  commonMethod cMethod = commonMethod();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// title
            Container(
              alignment: Alignment.topRight,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  "Manage Drivers",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),

            /// table titles
            Row(
              children: [
                cMethod.header(2, 'Driver ID'),
                cMethod.header(1, 'PICTURE'),
                cMethod.header(1, 'NAME'),
                cMethod.header(1, 'CAR DETAILS'),
                cMethod.header(1, 'PHONE'),
                cMethod.header(1, 'TOTAL EARNING'),
                cMethod.header(1, 'ACTION'),
              ],
            ),

            /// drivers data list
            driversDataList()
          ],
        ),
      )
    );
  }
}
