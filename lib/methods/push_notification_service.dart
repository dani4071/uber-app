import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:provider/provider.dart';
import 'package:uber_app_clone/app_info/app_info.dart';
import 'package:uber_app_clone/global/global_variables.dart';

class PushNotificationService {

  static Future<String> getAccessToken() async
  {
    final serviceAccountJson =
    {
      "type": "service_account",
      "project_id": projectId,
      "private_key_id": privateKeyId,
      "private_key": privateKey,
      "client_email": clientEmail,
      "client_id": clientId,
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-uber-app-clone-daniel%40uber-app-b9023.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };


    List<String> scopes =
    [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );


    // get access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client
    );

    client.close();

    return credentials.accessToken.data;
  }


  static sendNotificationToSelectedDriver(String deviceToken, BuildContext context, String tripID) async
  {
    String dropOffDestinationAddress = Provider.of<AppInfo>(context, listen: false).dropOffLocation!.placeName.toString();
    String pickUpAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName.toString();


    final String serverAccessTokenKey = await getAccessToken(); // your FCM server access token key
    String endpointFirebaseCloudMessaging = "https://fcm.googleapis.com/v1/projects/uber-app-b9023/messages:send";


    final Map<String, dynamic> message =
        {
          'message':
              {
                'token': deviceToken, // token of the device you want to send message/notification to
                'notification':
                    {
                      'title': 'NET TRIP REQUEST from $userName',
                      'body': "pickUp location: $pickUpAddress \n DropOff location: $dropOffDestinationAddress"
                    },
                'data':
                    {
                      'tripID': tripID
                    }
              }
        };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(message),
    );

    if(response.statusCode == 200)
      {
        print("FCM message sent successfully.");
      }
    else {
      print("failed to send FCM message: ${response.statusCode}");
    }
  }
}