import 'package:hasskit/helper/logger.dart';

class Sensor {
  String entityId;
  String lastChanged;
  String lastUpdated;
  String state;

  Sensor({this.entityId, this.lastChanged, this.lastUpdated, this.state});
  factory Sensor.fromJson(Map<String, dynamic> json) {
    try {
//      var lastChanged = json['last_changed'];
//      if (lastChanged == null) lastChanged = "1970-01-01 00:00:00";
//      var lastUpdated = json['last_updated'];
//      if (lastUpdated == null) lastUpdated = "1970-01-01 00:00:00";
//      var state = json['state'];
//      if (state == null) state = "0";

      return Sensor(
        lastChanged: json['last_changed'],
        lastUpdated: json['last_updated'],
        state: json['state'],
      );
    } catch (e) {
      log.e("EntiSensor.fromJson $e");
      return null;
    }
  }

  bool get isStateOn {
    //fuck that lock and unlocked have the same contain lol
    if (state.toLowerCase() == 'unlocked') return true;
    return !state.toLowerCase().contains('off') &&
        !state.toLowerCase().contains('locked') &&
        !state.toLowerCase().contains('idle') &&
        !state.toLowerCase().contains('unavailable') &&
        !state.toLowerCase().contains('docked') &&
        !state.toLowerCase().contains('closed');
  }
//  Map<String, dynamic> toJson() => {
//    'friendlyName': friendlyName,
//    'icon': icon,
//    'openRequireAttention': openRequireAttention,
//  };
}
