//import 'dart:convert';
//import 'package:http/http.dart' as http;
//import 'package:geolocator/geolocator.dart';
//import 'package:hasskit/helper/general_data.dart';
//import 'package:hasskit/model/location_zone.dart';
//import 'package:intl/intl.dart';
//import 'package:location_permissions/location_permissions.dart';
//
//class GeoLocatorHelper {
//  static Future<Position> get currentPosition async {
//    Position position = await Geolocator()
//        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
////    print("GeoLocatorHelper currentPosition $position");
//    return position;
//  }
//
//  static Future<Position> get lastKnownPosition async {
//    Position position = await Geolocator()
//        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.best);
//    print("GeoLocatorHelper lastKnownPosition $position");
//    return position;
//  }
//
//  static Future<GeolocationStatus> get status async {
//    GeolocationStatus geolocationStatus =
//        await Geolocator().checkGeolocationPermissionStatus();
//    print("GeoLocatorHelper status $geolocationStatus");
//    return geolocationStatus;
//  }
//
//  static Future<bool> get serviceEnabled async {
//    bool isLocationServiceEnabled =
//        await Geolocator().isLocationServiceEnabled();
//    print("GeoLocatorHelper serviceEnabled $isLocationServiceEnabled");
//    return isLocationServiceEnabled;
//  }
//
//  static Future<Placemark> placeMarks(Position position) async {
//    List<Placemark> placeMarks =
//        await Geolocator().placemarkFromPosition(position);
////    print("GeoLocatorHelper placeMarks ${placeMarks.first.name}");
//    return placeMarks.first;
//  }
//
//  static Future<void> updateLocation(String reason) async {
//    String prefix =
//        DateFormat("HH:mm:ss").format(DateTime.now()) + " " + reason;
//    if (!gd.settingMobileApp.trackLocation) {
//      print("$prefix FAIL: GeoLocatorHelper trackLocation");
//      gd.locationUpdateFail = "$prefix FAIL: GeoLocatorHelper trackLocation";
//      return;
//    }
//
//    if (gd.settingMobileApp.webHookId == "") {
//      print("$prefix FAIL: GeoLocatorHelper webHookId");
//      gd.locationUpdateFail = "$prefix FAIL: GeoLocatorHelper webHookId";
//      return;
//    }
//
//    if (gd.settingMobileApp.deviceName == "") {
//      print("$prefix FAIL: GeoLocatorHelper deviceName");
//      gd.locationUpdateFail = "$prefix FAIL: GeoLocatorHelper deviceName";
//      return;
//    }
//
//    if (gd.locationZones.length < 1) {
//      print("$prefix FAIL: GeoLocatorHelper gd.locationZones.length");
//      gd.locationUpdateFail =
//          "$prefix FAIL: GeoLocatorHelper gd.locationZones.length";
//      gd.httpApiStates();
//      return;
//    }
//
//    if (gd.mobileAppState == "...") {
//      print("$prefix FAIL: GeoLocatorHelper gd.mobileAppState == ...");
//      gd.locationUpdateFail =
//          "$prefix FAIL: GeoLocatorHelper gd.mobileAppState == ...";
//      return;
//    }
//
//    PermissionStatus permission =
//        await LocationPermissions().checkPermissionStatus();
////    print("GeoLocatorHelper permission $permission");
//
//    if (permission != PermissionStatus.granted) {
//      PermissionStatus permission =
//          await LocationPermissions().requestPermissions();
//      print("$prefix FAIL: GeoLocatorHelper permission 2 $permission");
//      gd.locationUpdateFail =
//          "$prefix FAIL: GeoLocatorHelper permission 2 $permission";
//    }
//
//    if (gd.locationUpdateTime
//        .add(Duration(minutes: gd.locationUpdateInterval))
//        .isAfter(DateTime.now())) {
//      var inSeconds = gd.locationUpdateTime
//          .add(Duration(minutes: gd.locationUpdateInterval))
//          .difference(DateTime.now())
//          .inSeconds;
//      print("$prefix FAIL: GeoLocatorHelper locationUpdateTime $inSeconds");
//      gd.locationUpdateFail =
//          "$prefix FAIL: GeoLocatorHelper locationUpdateTime $inSeconds";
//      return;
//    }
//    gd.locationUpdateTime = DateTime.now();
//
//    if (permission == PermissionStatus.granted) {
//      Position position = await currentPosition;
//      String zoneName = await getZoneName(position);
//      if (zoneName == gd.mobileAppState) {
//        print(
//            "$prefix FAIL: GeoLocatorHelper zoneName == gd.mobileAppState $zoneName");
//        gd.locationUpdateFail =
//            "$prefix FAIL: GeoLocatorHelper zoneName == gd.mobileAppState $zoneName";
//        return;
//      }
//      if (zoneName != null) {
//        print("$prefix SUCCESS: GeoLocatorHelper zoneName != null $zoneName");
//        gd.locationUpdateSuccess =
//            "$prefix SUCCESS: GeoLocatorHelper zoneName != null $zoneName";
//        writeLocation(position, zoneName);
//        return;
//      }
//
//      String locationName = await getLocationName(position);
//      if (locationName != null) {
//        print(
//            "$prefix SUCCESS: GeoLocatorHelper locationName != null $locationName");
//        gd.locationUpdateSuccess =
//            "$prefix SUCCESS: GeoLocatorHelper locationName != null $locationName";
//        writeLocation(position, locationName);
//        return;
//      }
//      print("$prefix FAIL: zoneName == null locationName == null");
//      gd.locationUpdateFail =
//          "$prefix FAIL: zoneName == null locationName == null";
//    }
//  }
//
//  static Future<String> getZoneName(Position position) async {
//    double shortestDistance = double.infinity;
//    String retVal;
//    for (LocationZone locationZone in gd.locationZones) {
////      if ((position.latitude - locationZone.latitude).abs() > 0.01 ||
////          (position.longitude - locationZone.longitude).abs() > 0.01) {
////        continue;
////      }
//      var distance = await Geolocator().distanceBetween(position.latitude,
//          position.longitude, locationZone.latitude, locationZone.longitude);
////      print(
////          "distance ${locationZone.friendlyName} $distance locationZone.radius ${locationZone.radius}");
//      if (distance < locationZone.radius) {
//        if (shortestDistance > distance) {
//          shortestDistance = distance;
//          retVal = locationZone.friendlyName;
////          print(
////              "shortestName $retVal shortestDistance $shortestDistance radius ${locationZone.radius}");
//        }
//      }
//    }
//
////    print("getZoneName retVal $retVal mobileAppState ${gd.mobileAppState}");
//    if (retVal != null) {
//      return retVal;
//    }
//    return null;
//  }
//
//  static Future<String> getLocationName(Position position) async {
//    String retVal;
//    Placemark placeMark = await placeMarks(position);
//
////    print("toJson ${placeMark.toJson()} ");
//
//    if (placeMark.subThoroughfare.trim().length > 0 &&
//        placeMark.thoroughfare.trim().length > 0) {
//      retVal = "${placeMark.subThoroughfare}, ${placeMark.thoroughfare}";
//    } else if (placeMark.subAdministrativeArea.trim().length > 0 &&
//        placeMark.administrativeArea.trim().length > 0) {
//      retVal =
//          "${placeMark.subAdministrativeArea}, ${placeMark.administrativeArea}";
//    } else {
//      retVal =
//          "${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
//    }
//
////    print("getLocationName retVal $retVal mobileAppState ${gd.mobileAppState}");
//    if (retVal != null) {
//      if (retVal == gd.mobileAppState) {
//        var distance = await Geolocator().distanceBetween(position.latitude,
//            position.longitude, gd.locationLatitude, gd.locationLongitude);
//        if (distance * 0.001 > gd.locationUpdateMinDistance) {
//          retVal = retVal + ".";
//        } else {
//          retVal = null;
//        }
//      }
//    }
//    return retVal;
//  }
//
//  static void writeLocation(Position position, String locationName) {
//    var getLocationUpdatesData = {
//      "type": "update_location",
//      "data": {
//        "location_name": locationName,
//        "gps": [position.latitude, position.longitude],
//        "gps_accuracy": 50,
//      }
//    };
//    String body = jsonEncode(getLocationUpdatesData);
//    print("getLocationUpdates.body $body");
//
//    String url =
//        gd.currentUrl + "/api/webhook/${gd.settingMobileApp.webHookId}";
//
//    print("getLocationUpdates.url $url");
//    http.post(url, body: body).then((response) {
//      if (response.statusCode >= 200 && response.statusCode < 300) {
//        print(
//            "updateLocation Response From Server With Code ${response.statusCode}");
//        gd.locationLatitude = position.latitude;
//        gd.locationLongitude = position.longitude;
//      } else {
//        print("updateLocation Response Error Code ${response.statusCode}");
//      }
//    }).catchError((e) {
//      print("updateLocation Response Error $e");
//    });
//  }
//}
