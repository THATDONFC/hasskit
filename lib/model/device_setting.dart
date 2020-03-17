import 'package:flutter/material.dart';

class DeviceSetting {
  int launchIndex = 0;
  int phoneLayout = 3;
  int tabletLayout = 69;
  int shapeLayout = 1;
  int themeIndex = 1;
  String lastArmType = "arm_home";
  bool settingLocked = false;
  String settingPin = "0000";
  String lockOut = "";
  int failAttempt = 0;
  List<String> backgroundPhoto = [];

  DeviceSetting({
    @required this.launchIndex,
    @required this.phoneLayout,
    @required this.tabletLayout,
    @required this.shapeLayout,
    @required this.themeIndex,
    @required this.lastArmType,
    @required this.settingPin,
    @required this.settingLocked,
    @required this.lockOut,
    @required this.failAttempt,
    @required this.backgroundPhoto,
  });

  Map<String, dynamic> toJson() => {
        'launchIndex': launchIndex,
        'phoneLayout': phoneLayout,
        'tabletLayout': tabletLayout,
        'shapeLayout': shapeLayout,
        'themeIndex': themeIndex,
        'lastArmType': lastArmType,
        'settingLocked': settingLocked,
        'settingPin': settingPin,
        'lockOut': lockOut,
        'failAttempt': failAttempt,
        'backgroundPhoto': backgroundPhoto,
      };

  factory DeviceSetting.fromJson(Map<String, dynamic> json) {
    return DeviceSetting(
      launchIndex: json['launchIndex'] != null ? json['launchIndex'] : 0,
      phoneLayout: json['phoneLayout'] != null ? json['phoneLayout'] : 3,
      tabletLayout: json['tabletLayout'] != null ? json['tabletLayout'] : 69,
      shapeLayout: json['shapeLayout'] != null ? json['shapeLayout'] : 1,
      themeIndex: json['themeIndex'] != null ? json['themeIndex'] : 1,
      lastArmType:
          json['lastArmType'] != null ? json['lastArmType'] : "arm_home",
      settingLocked:
          json['settingLocked'] != null ? json['settingLocked'] : false,
      settingPin: json['settingPin'] != null ? json['settingPin'] : "0000",
      lockOut: json['lockOut'] != null ? json['lockOut'] : "",
      failAttempt: json['failAttempt'] != null ? json['failAttempt'] : 0,
      backgroundPhoto: json['backgroundPhoto'] != null
          ? List<String>.from(json['backgroundPhoto'])
          : [],
    );
  }
}
