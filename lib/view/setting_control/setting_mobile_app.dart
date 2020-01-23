import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/geolocator_helper.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:http/http.dart' as http;
import 'package:location_permissions/location_permissions.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingMobileApp {
  String deviceName = "";
  String cloudHookUrl = "";
  String remoteUiUrl = "";
  String secret = "";
  String webHookId = "";
  bool trackLocation = true;

  SettingMobileApp({
    @required this.deviceName,
    @required this.cloudHookUrl,
    @required this.remoteUiUrl,
    @required this.secret,
    @required this.webHookId,
    @required this.trackLocation,
  });

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'cloudhook_url': cloudHookUrl,
        'cloudhook_url': remoteUiUrl,
        'secret': secret,
        'webhook_id': webHookId,
        'trackLocation': trackLocation,
      };

  factory SettingMobileApp.fromJson(Map<String, dynamic> json) {
    return SettingMobileApp(
      deviceName: json['deviceName'] != null ? json['deviceName'] : "",
      cloudHookUrl: json['cloudhook_url'] != null ? json['cloudhook_url'] : "",
      remoteUiUrl: json['remote_ui_url'] != null ? json['remote_ui_url'] : "",
      secret: json['secret'] != null ? json['secret'] : "",
      webHookId: json['webhook_id'] != null ? json['webhook_id'] : "",
      trackLocation:
          json['trackLocation'] != null ? json['trackLocation'] : true,
    );
  }

  String manufacturer = "manufacturer";
  String model = "model";
  String osName = "os_name";
  String osVersion = "os_version";

  getOsInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    manufacturer = "manufacturer";
    model = "model";
    osName = "os_name";
    osVersion = "os_version";

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      manufacturer = androidInfo.manufacturer;
      model = androidInfo.model;
      osName = androidInfo.version.baseOS;
      osVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      manufacturer = "Apple";
      model = iosInfo.utsname.machine;
      osName = iosInfo.utsname.sysname;
      osVersion = iosInfo.utsname.version;
    }
  }

  register(String deviceName) async {
    print("\n\nDeviceIntegrationn.register($deviceName)\n\n");
    if (deviceName.trim().length < 1) {
      print("deviceName.trim().length<1");
      return;
    }
    await getOsInfo();

    var registerData = {
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

    String body = jsonEncode(registerData);
    String url = gd.currentUrl + "/api/mobile_app/registrations";
    print("registerDataEncoded $body");
    print("url $url");

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

//        Fluttertoast.showToast(
//            msg: "Register Mobile App Success\n"
//                "- Device Name: ${gd.deviceIntegration.deviceName}\n"
//                "- Cloudhook Url: ${gd.deviceIntegration.cloudHookUrl}\n"
//                "- Remote UI Url: ${gd.deviceIntegration.remoteUiUrl}\n"
//                "- Secret: ${gd.deviceIntegration.secret}\n"
//                "- Webhook Id: ${gd.deviceIntegration.webHookId}",
//            toastLength: Toast.LENGTH_LONG,
//            gravity: ToastGravity.TOP,
//            backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
//            textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
//            fontSize: 14.0);

        showDialog(
          context: gd.mediaQueryContext,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Register Mobile App Success"),
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
        Fluttertoast.showToast(
            msg: "Register Mobile App Fail\n"
                "Server Response With Code ${response.statusCode}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
            textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
            fontSize: 14.0);
      }
    }).catchError((e) {
      print("Register error $e");
      Fluttertoast.showToast(
          msg: "Register Mobile App Fail\n"
              "Error $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
          textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
          fontSize: 14.0);
    });
  }

  updateRegistration(String deviceName) async {
    print("\n\nDeviceIntegrationn.updateRegistration($deviceName)\n\n");

    await getOsInfo();

    var registerUpdateData = {
      "type": "update_registration",
      "data": {
        "app_data": {
          "push_token": gd.firebaseMessagingToken,
          "push_url":
              "https://us-central1-hasskit-a81c7.cloudfunctions.net/sendPushNotification",
        },
        "app_version": "4.0",
        "device_name": deviceName,
        "manufacturer": manufacturer,
        "model": model,
        "os_version": osVersion,
      }
    };
    String body = jsonEncode(registerUpdateData);
    print("registerUpdateData.body $body");

    String url =
        gd.currentUrl + "/api/webhook/${gd.settingMobileApp.webHookId}";
    print("registerUpdateData.url $url");

    http.post(url, body: body).then((response) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(
            "updateRegistration response from server with code ${response.statusCode}");

        if (response == null || response.body.isEmpty) {
          print("updateRegistration response == null || response.body.isEmpty");
          print(
              "No registration data in response - MobileApp integration was removed");
          register(deviceName);
        } else {
          var bodyDecode = json.decode(response.body);
          print("updateRegistration bodyDecode $bodyDecode");
          print("bodyDecode[device_name] ${bodyDecode["device_name"]}");
          gd.settingMobileApp.deviceName = bodyDecode["device_name"];
          gd.settingMobileAppSave();

          showDialog(
            context: gd.mediaQueryContext,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("Update Mobile App Success"),
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
        }
      } else {
        print(
            "Update Mobile App Response From Server With Code ${response.statusCode}");
        Fluttertoast.showToast(
            msg: "Update Mobile App Fail\n"
                "Server Response With Code ${response.statusCode}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
            textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
            fontSize: 14.0);
      }
    }).catchError((e) {
      print("Update Mobile App Error $e");
      Fluttertoast.showToast(
          msg: "Update Mobile App Fail\n"
              "Error $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
          textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
          fontSize: 14.0);
    });
  }

//  Future<void> updateLocation(
//      double latitude, double longitude, double accuracy) async {
////    print("updateLocation called");
//
//    bool timeInterval = DateTime.now().isAfter(gd.locationUpdateTime);
//
//    if (!timeInterval) {
////      print(
////          "updateLocation timeInterval ${(gd.locationUpdateTime.difference(DateTime.now())).inSeconds} seconds left");
//      return;
//    }
//
//    //30 sec internal cooldown
//    gd.locationUpdateTime = DateTime.now().add(Duration(seconds: 30));
//
//    if (gd.mobileAppEntityId == "") {
//      var mobileAppEntity = gd.entities.values.toList().firstWhere(
//          (e) => e.friendlyName == gd.settingMobileApp.deviceName,
//          orElse: () => null);
//
//      if (mobileAppEntity == null) {
//        gd.mobileAppEntityId = "";
//      } else {
//        gd.mobileAppEntityId = mobileAppEntity.entityId;
//      }
//    }
//
//    if (gd.mobileAppEntityId == "") {
//      if (gd.webSocketConnectionStatus == "Connected") {
//        print("Case 7");
//        Fluttertoast.showToast(
//            msg: "Can not find ${gd.settingMobileApp.deviceName}",
//            toastLength: Toast.LENGTH_LONG,
//            gravity: ToastGravity.TOP,
//            backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
//            textColor: Theme.of(gd.mediaQueryContext).textTheme.title.color,
//            fontSize: 14.0);
//      }
//      return;
//    }
//
////    print(".");
////    print("latitude $latitude");
////    print("longitude $longitude");
////    print("accuracy $accuracy");
////    print(".");
//
//    String locationZoneName = "";
//    String locationGeoCoderName = "";
//    var shortestDistance = double.infinity;
//    var shortestName = "";
//    final coordinates = new Coordinates(latitude, longitude);
//
//    try {
//      for (LocationZone locationZone in gd.locationZones) {
//        var distance = gd.getDistanceFromLatLonInKm(
//            latitude, longitude, locationZone.latitude, locationZone.longitude);
////        print(
////            "distance ${locationZone.friendlyName} $distance locationZone.radius ${locationZone.radius} ${locationZone.radius * 0.001}");
//        if (distance < locationZone.radius * 0.001) {
//          if (shortestDistance > distance) {
//            shortestDistance = distance;
//            shortestName = locationZone.friendlyName;
////            print(
////                "shortestName $shortestName shortestDistance $shortestDistance radius ${locationZone.radius * 0.001}");
//          }
//        }
//      }
//
//      if (shortestName != "") {
//        locationZoneName = shortestName;
//      } else {
//        var addresses =
//            await Geocoder.local.findAddressesFromCoordinates(coordinates);
//        var first = addresses.first;
////        print(
////            "addressLine ${first.addressLine} adminArea ${first.adminArea} coordinates ${first.coordinates} countryCode ${first.countryCode} featureName ${first.featureName} locality ${first.locality} postalCode ${first.postalCode} subAdminArea ${first.subAdminArea} subLocality ${first.subLocality} subThoroughfare ${first.subThoroughfare} thoroughfare ${first.thoroughfare}");
//
//        if (first.subThoroughfare != null && first.thoroughfare != null) {
//          locationGeoCoderName =
//              "${first.subThoroughfare}, ${first.thoroughfare}";
//        } else if (first.addressLine != null) {
//          locationGeoCoderName = "${first.addressLine}";
//        } else {
//          locationGeoCoderName = "$latitude, $longitude";
//        }
//      }
//    } catch (e) {
//      print("Geocoder.local.findAddressesFromCoordinates Error $e");
//      locationGeoCoderName = "$latitude, $longitude";
//    }
//
//    var locationName = "";
//    //found a zone name
//    if (locationZoneName != "") {
//      if (locationZoneName.toLowerCase() == gd.mobileAppState.toLowerCase()) {
//        print("Case 1");
//        return;
//      } else {
//        locationName = locationZoneName;
//        print("Case 2");
//      }
//    } else {
//      if (gd.getDistanceFromLatLonInKm(
//              latitude, longitude, gd.locationLatitude, gd.locationLongitude) <
//          gd.locationUpdateMinDistance) {
//        print(
//            "Case 4 Distance ${gd.getDistanceFromLatLonInKm(latitude, longitude, gd.locationLatitude, gd.locationLongitude)} < ${gd.locationUpdateMinDistance}");
//        return;
//      } else {
//        if (locationGeoCoderName == gd.mobileAppState) {
//          locationName = locationGeoCoderName + ".";
//          print("Case 5");
//        } else {
//          locationName = locationGeoCoderName;
//          print("Case 6");
//        }
//      }
//    }
//
//    var getLocationUpdatesData = {
//      "type": "update_location",
//      "data": {
//        "location_name": locationName,
//        "gps": [latitude, longitude],
//        "gps_accuracy": accuracy,
//      }
//    };
//    String body = jsonEncode(getLocationUpdatesData);
//    print("getLocationUpdates.body $body");
//
//    String url =
//        gd.currentUrl + "/api/webhook/${gd.settingMobileApp.webHookId}";
//
//    print("getLocationUpdates.url $url");
//
//    http.post(url, body: body).then((response) {
//      if (response.statusCode >= 200 && response.statusCode < 300) {
//        print(
//            "updateLocation Response From Server With Code ${response.statusCode}");
//        gd.locationRecordTime = DateTime.now();
//        gd.locationLatitude = latitude;
//        gd.locationLongitude = longitude;
//        gd.locationUpdateTime =
//            DateTime.now().add(Duration(minutes: gd.locationUpdateInterval));
//      } else {
//        print("updateLocation Response Error Code ${response.statusCode}");
//      }
//    }).catchError((e) {
//      print("updateLocation Response Error $e");
//    });
//  }
}

class SettingMobileAppRegistration extends StatefulWidget {
  @override
  _SettingMobileAppRegistrationState createState() =>
      _SettingMobileAppRegistrationState();
}

class _SettingMobileAppRegistrationState
    extends State<SettingMobileAppRegistration> {
  TextEditingController _controller;

  @override
  void initState() {
    print("SettingRegistration initState ${gd.settingMobileApp.deviceName}");
    super.initState();
    _controller = TextEditingController();
    if (gd.settingMobileApp.deviceName != "") {
      _controller.text = gd.settingMobileApp.deviceName;
    } else {
      getDeviceInfo();
    }
  }

  void getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var deviceModel = "";
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');
      deviceModel = "-" + iosInfo.utsname.machine;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      deviceModel = "-" + androidInfo.model;
    }
    _controller.text = "HassKit$deviceModel";
  }

  @override
  Widget build(BuildContext context) {
    if (gd.settingMobileApp.deviceName != "") {
      _controller.text = gd.settingMobileApp.deviceName;
    } else {
      getDeviceInfo();
    }

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Add HassKit Mobile App component to Home Assistant to enable location tracking and push notification.",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.justify,
                  textScaleFactor: gd.textScaleFactorFix,
                ),
                TextField(
                  autofocus: false,
                  controller: _controller,
                  decoration: new InputDecoration(
                    labelText: gd.settingMobileApp.webHookId == ""
                        ? "Register Mobile App"
                        : "Update Mobile App",
                    hintText: gd.settingMobileApp.webHookId == ""
                        ? "Enter Mobile App Name"
                        : "Enter Mobile App Name",
                  ),
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: _controller.text.trim().length > 0 &&
                                gd.webSocketConnectionStatus == "Connected"
                            ? () {
                                if (gd.settingMobileApp.webHookId == "") {
                                  gd.settingMobileApp
                                      .register(_controller.text.trim());
                                } else {
                                  gd.settingMobileApp.updateRegistration(
                                      _controller.text.trim());
                                }
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              }
                            : null,
                        child: Text(
                          gd.settingMobileApp.webHookId == ""
                              ? "Register"
                              : "Update",
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: RaisedButton(
                        onPressed: _launchMobileAppGuide,
                        child: Text("Guide"),
                      ),
                    ),
                  ],
                ),
                gd.settingMobileApp.webHookId != ""
                    ? Row(
                        children: <Widget>[
                          Switch.adaptive(
                              value: gd.settingMobileApp.trackLocation,
                              onChanged: (val) {
                                setState(() {
                                  gd.settingMobileApp.trackLocation = val;
                                  print(
                                      "onChanged $val gd.deviceIntegration.trackLocation ${gd.settingMobileApp.trackLocation}");
                                  if (val == true) {
                                    if (gd.settingMobileApp.webHookId != "") {
                                      gd.locationUpdateTime = DateTime.now()
                                          .subtract(Duration(days: 1));
                                      GeoLocatorHelper.updateLocation(
                                          "Switch.adaptive");
                                    }
                                  } else {
                                    gd.locationLatitude = 51.48;
                                    gd.locationLongitude = 0.0;
                                  }
                                  gd.settingMobileAppSave();
                                });
                              }),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              gd.settingMobileApp.trackLocation
                                  ? "Location Tracking Enabled"
                                      "\n${gd.textToDisplay(gd.mobileAppState)}"
                                  : "Location Tracking Disabled",
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.justify,
                              textScaleFactor: gd.textScaleFactorFix,
                            ),
                          ),
                        ],
                      )
                    : Container(),
                ExpandableNotifier(
                  child: ScrollOnExpand(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Divider(
                          height: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Builder(
                              builder: (context) {
                                var controller =
                                    ExpandableController.of(context);
                                return FlatButton(
                                  child: Text(
                                    controller.expanded
                                        ? "  Hide Advance Settings  "
                                        : "  Show Advance Settings  ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        .copyWith(
                                            color: ThemeInfo.colorIconActive),
                                  ),
                                  onPressed: () {
                                    controller.toggle();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        Expandable(
                          collapsed: null,
                          expanded: Row(
                            children: <Widget>[
                              SizedBox(width: 24),
                              Text(
                                  "Update Interval: ${gd.locationUpdateInterval} minutes")
                            ],
                          ),
                        ),
                        Expandable(
                          collapsed: null,
                          expanded: Slider(
                            value: gd.locationUpdateInterval.toDouble(),
                            onChanged: (val) {
                              setState(() {
                                gd.locationUpdateInterval = val.toInt();
                              });
                            },
                            min: 1,
                            max: 30,
                          ),
                        ),
                        Expandable(
                          collapsed: null,
                          expanded: Row(
                            children: <Widget>[
                              SizedBox(width: 24),
                              Text(
                                  "Min Distance Change: ${(gd.locationUpdateMinDistance * 1000).toInt()} meters")
                            ],
                          ),
                        ),
                        Expandable(
                          collapsed: null,
                          expanded: Slider(
                            value: gd.locationUpdateMinDistance,
                            onChanged: (val) {
                              setState(() {
                                gd.locationUpdateMinDistance = val;
                              });
                            },
                            min: 0.05,
                            max: 0.5,
                            divisions: 45,
                          ),
                        ),
                        Expandable(
                          collapsed: null,
                          expanded: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Builder(
                                builder: (context) {
                                  return FlatButton(
                                    child: Text(
                                      "  Open App Settings",
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(
                                              color: ThemeInfo.colorIconActive),
                                    ),
                                    onPressed: () {
                                      LocationPermissions().openAppSettings();
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
//                Text(
//                    "Debug: trackLocation ${gd.settingMobileApp.trackLocation}\n"
//                    "deviceName ${gd.settingMobileApp.deviceName}\n"
//                    "webHookId ${gd.settingMobileApp.webHookId}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _launchMobileAppGuide() async {
    const url =
        'https://github.com/tuanha2000vn/hasskit/blob/master/mobile_app.md';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
