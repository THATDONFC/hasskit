import 'package:flutter/material.dart';

class LocationZone {
  String friendlyName;
  String icon;
  double latitude;
  double longitude;
  double radius;
  String entityId;
  String state;

  LocationZone({
    @required this.friendlyName,
    @required this.icon,
    @required this.latitude,
    @required this.longitude,
    @required this.radius,
    @required this.entityId,
    @required this.state,
  });

  Map<String, dynamic> toJson() => {
        'friendly_name': friendlyName,
        'icon': icon,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'entity_id': entityId,
        'state': state,
      };

  factory LocationZone.fromJson(Map<String, dynamic> json) {
    return LocationZone(
      friendlyName: json['attributes']['friendly_name'],
      icon: json['attributes']['icon'],
      latitude: double.parse(json['attributes']['latitude'].toString()),
      longitude: double.parse(json['attributes']['longitude'].toString()),
      radius: double.parse(json['attributes']['radius'].toString()),
      entityId: json['entity_id'],
      state: json['state'],
    );
  }
}
