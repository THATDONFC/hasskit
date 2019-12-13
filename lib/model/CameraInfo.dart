import 'package:flutter/material.dart';

class CameraInfo {
  String entityId;
  DateTime updatedTime;
  DateTime requestingTime;
  ImageProvider currentImage;
  ImageProvider previousImage;

  CameraInfo({
    @required this.entityId,
    @required this.updatedTime,
    @required this.requestingTime,
    @required this.currentImage,
    @required this.previousImage,
  });
}
