import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ykjam_cargo/datas/local_storadge.dart';
import 'package:http/http.dart' as http;
import 'package:ykjam_cargo/datas/static_data.dart';

showToastMethod(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Future<bool> checkNetwork() async {
  final internetConnection = await Connectivity().checkConnectivity();
  if (internetConnection != ConnectivityResult.none) {
    return true;
  }
  return false;
}

Future<String> getDeviceName() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    return androidInfo.model;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    return iosInfo.utsname.machine;
  }

  return "Unsupported platform";
}

Container errorHandleMethod(BuildContext context, Function() onTap) {
  return Container(
    width: 355,
    height: 100,
    color: Colors.black87,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text(
            softWrap: true,
            "Internet baglanyşygyňyzy barlaň we täzeden synanşyň",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              decoration: TextDecoration.none,
              fontFamily: 'Arial',
              letterSpacing: 1,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                "TÄZEDEN SYNANŞYŇ",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                  fontFamily: 'Arial',
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<FuncResult> getGuestToken(
  // bool intConnection,
  BuildContext context,
  // String guestToken,
  StaticData staticData,
  // bool isLoadingStartPage,
) async {
  final internetConnection = await checkNetwork();
  String guestToken = "";
  // intConnection = internetConnection;

  // if (intConnection) {
  if (internetConnection) {
    if (context.mounted) {
      final localStoragde = Provider.of<LocalStoradge>(context, listen: false);

      await localStoragde.getGuestTokenFromSharedPref();

      guestToken = localStoragde.getGuestToken();
    }

    if (guestToken == "") {
      final deviceName = await getDeviceName();

      var response = await http.get(
        Uri.parse(
            "${staticData.getUrl()}/get_token?guest=true&device=$deviceName"),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Credentials': 'true',
          'Access-Control-Allow-Headers': 'Content-Type',
          'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE'
        },
      );

      var jsonData = jsonDecode(response.body);

      if (jsonData.containsKey('token') && response.statusCode == 200) {
        guestToken = jsonData['token'];

        if (context.mounted) {
          Provider.of<LocalStoradge>(context, listen: false)
              .changeGuestToken(guestToken);
        }

        // isLoadingStartPage = false;
        // return (true, false);
        return FuncResult(true, false, guestToken);
      } /* else {
        showToastMethod("Maglumat çekilmedi");
      } */
      showToastMethod("Maglumat çekilmedi");
      // return (false, true);
      return FuncResult(false, true, guestToken);
    } /*else {
      isLoadingStartPage = false;
    }*/
    // return (true, false);
    return FuncResult(true, false, guestToken);
  } /* else {
    intConnection = false;
  } */

  // return (false, true);
  return FuncResult(false, true, guestToken);
}

class FuncResult {
  bool intConn, isload;
  String token;

  FuncResult(this.intConn, this.isload, this.token);
}

addFcmToken(String fcmToken, String userID, StaticData staticData, String token,
    BuildContext context) async {
  Map<String, dynamic> body;
  String fcmtoken = "";

  if (context.mounted) {
    final localStoragde = Provider.of<LocalStoradge>(context, listen: false);
    await localStoragde.getFcmTokenFromSharedPref();
    fcmtoken = localStoragde.getFcmToken();
  }

  if (fcmtoken == "") {
    final deviceName = await getDeviceName();

    body = {
      "token": fcmToken,
      "id": userID,
      "device": deviceName,
      "from": "cargo_ios_app"
    };

    http.post(
      Uri.parse("${staticData.getUrl()}/add_token?key=$token"),
      body: json.encode(body),
    );

    if (context.mounted) {
      Provider.of<LocalStoradge>(context, listen: false)
          .changeFcmToken(fcmtoken);
    }
  }
}
