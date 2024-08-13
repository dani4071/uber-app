import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_app_clone/app_info/app_info.dart';
import 'package:uber_app_clone/global/global_variables.dart';
import 'package:uber_app_clone/methods/common_methods.dart';
import 'package:uber_app_clone/models/address_model.dart';
import 'package:uber_app_clone/models/prediction_model.dart';
import 'package:uber_app_clone/widgets/loading_dialog.dart';

class predictionPlaceUi extends StatefulWidget {

  PredictionModel? predictionPlaceData;

  predictionPlaceUi({super.key, this.predictionPlaceData});

  @override
  State<predictionPlaceUi> createState() => _predictionPlaceUiState();
}

class _predictionPlaceUiState extends State<predictionPlaceUi> {

  /// Places Details - Places Api
  fetchClickedPlaceDetails(String placeId) async {

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => loadingDialog(messageText: "Getting details...."),
    );

    String urlPlaceDataApi = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleMapKey";

    var responseFromPlaceDetailsApi = await CommonMethods.sendRequestToApi(urlPlaceDataApi);

    Navigator.pop(context);

    if (responseFromPlaceDetailsApi == "error") {
      return;
    }

    if (responseFromPlaceDetailsApi["status"] == "OK") {

      addressModel dropOffLocation = addressModel();

      dropOffLocation.placeName = responseFromPlaceDetailsApi["result"]["name"];
      dropOffLocation.latitudePosition = responseFromPlaceDetailsApi["result"]["geometry"]["location"]["lat"];
      dropOffLocation.longitudePosition = responseFromPlaceDetailsApi["result"]["geometry"]["location"]["lng"];
      dropOffLocation.placeId = placeId;

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocation(dropOffLocation);

      Navigator.pop(context, "placeSelected");

    }

  }



  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){

        fetchClickedPlaceDetails(widget.predictionPlaceData!.places_id.toString());

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder()
      ),
      child: SizedBox(
        child: Column(
          children: [

            const SizedBox(height: 10,),

            Row(
              children: [
                const Icon(
                  Icons.share_location,
                  color: Colors.green,
                ),

                const SizedBox(width: 13,),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Text(
                        widget.predictionPlaceData!.main_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 3,),

                      Text(
                        widget.predictionPlaceData!.secondary_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),

                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 10,),

          ],
        ),
      ),
    );
  }
}
