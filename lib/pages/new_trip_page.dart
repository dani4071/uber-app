import 'package:flutter/material.dart';
import 'package:uber_app_drivers_app/models/trip_details_model.dart';


class newTripPage extends StatefulWidget {
  tripDetailsModel? tripDetails;

  newTripPage({super.key, this.tripDetails});

  @override
  State<newTripPage> createState() => _newTripPageState();
}

class _newTripPageState extends State<newTripPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New trip page"),
        centerTitle: true,
      ),
    );
  }
}
