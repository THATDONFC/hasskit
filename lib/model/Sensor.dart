import 'package:hasskit/helper/Logger.dart';

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
      log.e("EntityOverride.fromJson $e");
      return null;
    }
  }

  bool get isStateOn {
    return !state.toLowerCase().contains('off') &&
        !state.toLowerCase().contains('unavailable') &&
        !state.toLowerCase().contains('closed');
  }
//  Map<String, dynamic> toJson() => {
//    'friendlyName': friendlyName,
//    'icon': icon,
//    'openRequireAttention': openRequireAttention,
//  };
}
