// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
//
// class CommonMethods
// {
//   checkConnectivity(BuildContext context) async
//   {
//     //var connectionResult = await (Connectivity().checkConnectivity());
//
//     final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
//
//     if(connectivityResult.contains(ConnectivityResult.mobile) && connectivityResult.contains(ConnectivityResult.wifi))
//     // if(!connectionResult.contains(ConnectivityResult.mobile)  && !connectionResult.contains(ConnectivityResult.wifi))
//     //// this or you could downgrade the package
//     {
//       if(!context.mounted) return;
//       displaySnackBar("YOUR Internet is not Available. Check your connection. Try Again.", context);
//     }
//   }
//
//   displaySnackBar(String messageText, BuildContext context)
//   {
//     var snackBar = SnackBar(content: Text(messageText));
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CommonMethods
{
  checkConnectivity(BuildContext context) async
  {
    var connectionResult = await Connectivity().checkConnectivity();

    //// this works with connectivity 6.0.0
    if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi)
    {
      if(!context.mounted) return;
      displaySnackBar("your Internet is not Available. Check your connection. Try Again.", context);
    }
  }

  displaySnackBar(String messageText, BuildContext context)
  {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}