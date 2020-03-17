import 'package:hasskit/helper/logger.dart';

class Location {
  String entityId;
  int gpsAccuracy;
  double latitude;
  double longitude;
  String source;
  DateTime lastChanged;
  String state;

  Location({
    this.entityId,
    this.gpsAccuracy,
    this.latitude,
    this.longitude,
    this.source,
    this.lastChanged,
    this.state,
  });
  factory Location.fromJson(Map<String, dynamic> json) {
    try {
      return Location(
        entityId: json['entity_id'].toString(),
        gpsAccuracy:
            int.tryParse(json['attributes']['gps_accuracy'].toString()) != null
                ? int.parse(json['attributes']['gps_accuracy'].toString())
                : null,
        latitude:
            double.tryParse(json['attributes']['latitude'].toString()) != null
                ? double.parse(json['attributes']['latitude'].toString())
                : null,
        longitude:
            double.tryParse(json['attributes']['longitude'].toString()) != null
                ? double.parse(json['attributes']['longitude'].toString())
                : null,
        source: json['attributes']['source'].toString(),
        lastChanged: DateTime.tryParse(json['last_changed'].toString()) != null
            ? DateTime.parse(json['last_changed'].toString())
            : null,
        state: json['state'].toString(),
      );
    } catch (e) {
      log.e("Location.fromJson $e");
      return null;
    }
  }
}
