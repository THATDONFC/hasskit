import 'package:flutter/material.dart';

class Room {
  String name;
  int imageIndex;
  String tempEntityId;
  String humidEntityId;
  List<String> row1;
  String row1Name;
  List<String> row2;
  String row2Name;
  List<String> row3;
  String row3Name;
  List<String> row4;
  String row4Name;

  Room({
    @required this.name,
    @required this.imageIndex,
    this.tempEntityId = "",
    this.humidEntityId = "",
    this.row1,
    this.row1Name,
    this.row2,
    this.row2Name,
    this.row3,
    this.row3Name,
    this.row4,
    this.row4Name,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'imageIndex': imageIndex,
        'tempEntityId': tempEntityId,
        'humidEntityId': humidEntityId,
        'favorites': row1,
        'row1Name': row1Name,
        'entities': row2,
        'row2Name': row2Name,
        'row3': row3,
        'row3Name': row3Name,
        'row4': row4,
        'row4Name': row4Name,
      };

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      name: json['name'],
      imageIndex: json['imageIndex'],
      tempEntityId: json['tempEntityId'] != null ? json['tempEntityId'] : "",
      humidEntityId: json['humidEntityId'] != null ? json['humidEntityId'] : "",
      row1:
          json['favorites'] != null ? List<String>.from(json['favorites']) : [],
      row1Name: json['row1Name'] != null ? json['row1Name'] : "",
      row2: json['entities'] != null ? List<String>.from(json['entities']) : [],
      row2Name: json['row2Name'] != null ? json['row2Name'] : "",
      row3: json['row3'] != null ? List<String>.from(json['row3']) : [],
      row3Name: json['row3Name'] != null ? json['row3Name'] : "",
      row4: json['row4'] != null ? List<String>.from(json['row4']) : [],
      row4Name: json['row2Name'] != null ? json['row4Name'] : "",
    );
  }
}
