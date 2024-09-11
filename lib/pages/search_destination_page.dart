import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_app_clone/app_info/app_info.dart';
import 'package:uber_app_clone/global/global_variables.dart';
import 'package:uber_app_clone/methods/common_methods.dart';
import 'package:uber_app_clone/models/prediction_model.dart';
import 'package:uber_app_clone/widgets/prediction_place_ui.dart';


class searchDestinationPage extends StatefulWidget {
  const searchDestinationPage({super.key});

  @override
  State<searchDestinationPage> createState() => _searchDestinationPageState();
}

class _searchDestinationPageState extends State<searchDestinationPage> {

  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();
  List<PredictionModel> dropOffPredictionPlacesList = [];

  /// Autocomplete Places Api
  searchLocation(String locationName) async {

    if(locationName.length > 1) {


      String apiPlaceUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&key=$googleMapKey&components=country:ng";

      var responseFromPlacesApi = await CommonMethods.sendRequestToApi(apiPlaceUrl);


      if(responseFromPlacesApi == 'error') {
        return;
      }

      if(responseFromPlacesApi["status"] == "OK") {

        var predictionResultInJson = responseFromPlacesApi["predictions"];

        var predictionList = (predictionResultInJson as List).map((eachPlacePrediction) => PredictionModel.fromJson(eachPlacePrediction)).toList();

        setState(() {
          dropOffPredictionPlacesList = predictionList;
        });
      }

    }
  }


  @override
  Widget build(BuildContext context) {

    // String userAddress = "meeee";
    String userAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation!.humanReadableAddress ?? "";

    pickUpTextEditingController.text = userAddress;


    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [

            Card(
              elevation: 10,
              margin: EdgeInsets.zero,
              child: Container(
                height: 230,
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 6,),

                      Stack(
                        children: [
                          GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back)),
                          const Center(
                            child: Text(
                              "Set Dropoff Location",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18,),

                      /// pickup text field
                      Row(
                        children: [
                          /// image
                          Image.asset(
                            "assets/location.png",
                            width: 16,
                            height: 16,
                          ),

                          const SizedBox(width: 18,),

                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: pickUpTextEditingController,
                                  decoration: const InputDecoration(
                                    hintText: "Pickup Address",
                                    fillColor: Colors.grey,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9)
                                  ),
                                ),

                              ),
                            ),
                          ),

                          const SizedBox(width: 18,),

                        ],
                      ),

                      const SizedBox(height: 9,),

                      /// destination text field
                      Row(
                        children: [
                          /// image
                          Image.asset(
                            "assets/mapDot.png",
                            width: 16,
                            height: 16,
                          ),

                          const SizedBox(width: 18,),

                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: destinationTextEditingController,
                                  onChanged: (inputText) {
                                    searchLocation(inputText);
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "Destination Address",
                                      fillColor: Colors.grey,
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9)
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 18,),

                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// display prediction result from Places API
            (dropOffPredictionPlacesList.isNotEmpty)
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        child: predictionPlaceUi(predictionPlaceData: dropOffPredictionPlacesList[index],),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 2,),
                    itemCount: dropOffPredictionPlacesList.length,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                  ),
            )
                : Container()
          ],
        ),
      ),
    );
  }
}
