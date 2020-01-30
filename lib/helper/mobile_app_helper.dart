import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/view/setting_control/setting_mobile_app.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:hasskit/helper/general_data.dart';

class MobileAppHelper {
  String manufacturer = "manufacturer";
  String model = "model";
  String osName = "os_name";
  String osVersion = "os_version";

  check(String reason) async {
    print("MobileAppHelper register $reason");

    if (!gd.webSocketConnected) {
      print("MobileAppHelper gd.webSocketConnected");
      return;
    }
    if (gd.loginDataCurrent.url.contains('http://hasskit.duckdns.org:8123')) {
      print("MobileAppHelper contains http://hasskit.duckdns.org:8123");
      return;
    }

    //Make sure new refresh data
    if (gd.configVersion == "") {
      print("MobileAppHelper gd.configVersion ==");
      return;
    }

    if (!gd.configComponent.contains("mobile_app")) {
      print("MobileAppHelper contains !mobile_app");
      return;
    }

    if (gd.settingMobileApp.webHookId == "") {
      print("MobileAppHelper check webHookId empty");
      await register("webHookId empty");
    } else {
      print("MobileAppHelper check webHookId not empty");
      var validMobileApp = await checkValidMobileApp();
      if (!validMobileApp) {
        await register("!validMobileApp");
      }
    }
  }

  register(String reason) async {
    String deviceName = await generateDeviceName();
    print("register generateDeviceName $deviceName");

    var jsonBody = {
      "app_id": "hasskit",
      "app_name": "HassKit",
      "app_version": "4.0",
      "device_name": deviceName,
      "manufacturer": manufacturer,
      "model": model,
      "os_name": osName,
      "os_version": osVersion,
      "supports_encryption": false,
      "app_data": {
        "push_token": gd.firebaseMessagingToken,
        "push_url":
            "https://us-central1-hasskit-a81c7.cloudfunctions.net/sendPushNotification",
      }
    };

    String body = jsonEncode(jsonBody);
    String url = gd.currentUrl + "/api/mobile_app/registrations";
    Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ${gd.loginDataCurrent.longToken}',
    };

    http.post(url, headers: headers, body: body).then((response) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("register response from server with code ${response.statusCode}");
        var bodyDecode = json.decode(response.body);
        print("register bodyDecode $bodyDecode");
        gd.settingMobileApp = SettingMobileApp.fromJson(bodyDecode);
        gd.settingMobileApp.deviceName = deviceName;
        print(
            "gd.deviceIntegration.deviceName ${gd.settingMobileApp.deviceName}");
        print(
            "gd.deviceIntegration.cloudHookUrl ${gd.settingMobileApp.cloudHookUrl}");
        print(
            "gd.deviceIntegration.remoteUiUrl ${gd.settingMobileApp.remoteUiUrl}");
        print("gd.deviceIntegration.secret ${gd.settingMobileApp.secret}");
        print(
            "gd.deviceIntegration.webHookId ${gd.settingMobileApp.webHookId}");
        gd.settingMobileAppSave();

        showDialog(
          context: gd.mediaQueryContext,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text("Register Mobile App Success"),
              content: new Text("Restart Home Assistant Now?"),
              backgroundColor: ThemeInfo.colorBottomSheet,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                RaisedButton(
                  child: new Text("Later"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                RaisedButton(
                  child: new Text("Restart"),
                  onPressed: () {
                    var outMsg = {
                      "id": gd.socketId,
                      "type": "call_service",
                      "domain": "homeassistant",
                      "service": "restart",
                    };

                    var outMsgEncoded = json.encode(outMsg);
                    gd.sendSocketMessage(outMsgEncoded);

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        print(
            "Register Mobile App Response From Server With Code ${response.statusCode}");
      }
    }).catchError((e) {
      print("Register error $e");
    });
  }

  Future<String> generateDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var deviceName = "";
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.name.trim().length > 0) {
        deviceName = iosInfo.name;
      } else {
        deviceName = iosInfo.utsname.machine;
      }
      manufacturer = "Apple";
      model = iosInfo.utsname.machine;
      osName = iosInfo.utsname.sysname;
      osVersion = iosInfo.utsname.version;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model;
      manufacturer = androidInfo.manufacturer;
      model = androidInfo.model;
      osName = androidInfo.version.baseOS;
      osVersion = androidInfo.version.release;
    }
    deviceName = 'hasskit_' +
        deviceName +
        "_" +
        random.nextInt(9999).toString().padLeft(4, '0');
    deviceName = deviceName.replaceAll(RegExp(r'[^0-9a-zA-Z]'), "_");
    deviceName = deviceName.toLowerCase();
    return deviceName;
  }

  Future<bool> checkValidMobileApp() async {
    bool retVal = false;

    if (gd.mobileAppState != "...") {
      print("checkValidMobileApp gd.mobileAppState != ...");
      retVal = true;
      return retVal;
    }

    var checkData = {
      "type": "get_zones",
    };

    String url =
        gd.currentUrl + "/api/webhook/${gd.settingMobileApp.webHookId}";
    print("checkValidMobileApp.url $url");
    String body = jsonEncode(checkData);
    print("checkValidMobileApp.body $body");
    var response = await http.post(url, body: body);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.body == null || response.body.isEmpty) {
      print("checkValidMobileApp response.body empty ${response.body}");
      retVal = false;
      return retVal;
    } else {
      print("checkValidMobileApp response.body not empty ${response.body}");
      retVal = true;
      return retVal;
    }
  }
}
