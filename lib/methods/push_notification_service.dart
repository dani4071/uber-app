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
      "project_id": "uber-app-b9023",
      "private_key_id": "081a978d934709fab5592990e6debd10c922f6db",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCtdS9mKECx3qNB\nUbWHQ0KKWsQTeslaCOb8Zq86nm82YED+MP/XdXzQ4Z5gX+fufUg/9xUgyw6/rYRF\nJy2H8KMP9duJkvnWVgpEAXke1qwHsahq/1HmFk3eH3a0WNBTqQyvVnY4VQhniUu8\nqk7V87hFs0rTD74eASerFvMP3fM7Xqk4hG4sqhwEMaWLROrMtHEDkOBfPR95zWSj\niV6Cmku/F2JHDLGsGDotSjdIwiZE8IOipzsTfVuIySrK5fPF2dHAvdAfhhJzfHBm\neayWd/CXaA6X0wwWhZaWBJQvRMwNZLXPhUCQqFBSxgThgOnhZL/OOMvqFAeqXqpJ\nk4oJBiZTAgMBAAECggEAD4xSB9uy1N7KjnfXCD1gsQsqyT4330CuB9DigyQhfuPI\n36Afxr3qxsR6kFP4c7m6KLWqqKpa85aHpTU6URWiYDNfDulkSLCksezZ4QhIGlZz\n7MdfHXtBVphGaSsO3XjpQKxE447HtpQpfEtdzrLOgTzth5bBKWpcFmtztSflfhw7\nzvcAjVjLH3/rAlKHhTLvvn3k2vJP56ylazcu7R71Fr4Wc8kpiPGzHiutItVtY+oL\naTz4ADYHUAO695xkkcXcQFRLCZEL6XSDfj3gfMkBkGN5foWo2w/ci/34/NudRQ4d\nVXmiZI625sw5XQS3205LUJstJLS7l5HKos20ZZ1hdQKBgQDYufWBSW3v68k04h8j\nTx/HZqtc4FRRE1rTRH1iRQaIotnLeq3VmqM9dXxE6ioGCOwRDB8yINQ4X3hivFSN\nRzVxsBPxl7HNQt1U5a+nS7ZYwV89cIlUhw5iq4T/k9MioVNh0LZ270s/ieVSRnEA\nWVGDR6Ai/NFfiKVVUM1aFzLaDwKBgQDM4/kUvxf7XLcIbtwuvTTsfJleEaxkPoyq\nyIuN4yhVMot/k6Bz3j4N3ySLhkqMCC8YshmNycLkGhVGuUqksgCFL3is4R4BZ2yf\n1sC07UJwRYyf0rfB22Qh8ka2PDMOYqjrbPP3LtXdteTaNSw+VWiwHwh+DQ5Zlzc9\n+uqcIqSDfQKBgHrBsgZ+EhBAbKJQpjR4v9ZRGCUuR3P404wxEhgUYuQH4fc4ULhZ\ns7a/EhlyzUTHzvbE9/KL18jqgqTiab3wJJx1kIZaVvKdugI5ayoGX42cUhbZ5F+F\ndCd9YYLmN0Q5PqJ79q4dUnD16XeVwLHi5aHHczP+IZXML2HIt9gcpcgPAoGAFGcH\nIJe+zZr35vETH9xbbskhhIqB/iF0ZHU/4EskcwdreLK8oY0Z5Mu5meMvfS47clwZ\ny1KyA4DNaZN96VSIVLrba2unT0B7Qpdh7SJLIV7rl+alwboVCIRVokPwWZhddcQN\nrymMxl0cgtYUp8hdelw8vkCSkz1JlPRtdErG0wkCgYEAnws7Z2vGZlKjH9Pz/gHh\nVKo/wThzcae+WFupI41QqYIRInhAfh2KjcyyTLoTLPRjGG3qKCGyRY2PSDn9voE/\ndafwLSem+L5ayzpY2CiQlEmo1DryxGu52PMtCAfNMJT0aMTrlm1OL9epgdYZzaqb\neK8icW7Cy0pjM8K5A5LbLak=\n-----END PRIVATE KEY-----\n",
      "client_email": "flutter-uber-app-clone-daniel@uber-app-b9023.iam.gserviceaccount.com",
      "client_id": "100137208616290069676",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-uber-app-clone-daniel%40uber-app-b9023.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    // final serviceAccountJson =
    // {
    //   "type": "service_account",
    //   "project_id": projectId,
    //   "private_key_id": privateKeyId,
    //   "private_key": privateKey,
    //   "client_email": clientEmail,
    //   "client_id": clientId,
    //   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    //   "token_uri": "https://oauth2.googleapis.com/token",
    //   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    //   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-uber-app-clone-daniel%40uber-app-b9023.iam.gserviceaccount.com",
    //   "universe_domain": "googleapis.com"
    // };


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