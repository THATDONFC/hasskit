import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File _image;
  Future getImage() async {
    var imagePicker = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1920,
      maxWidth: 1920,
    );

    print("ImagePicker.path ${imagePicker.path}");
    var fileName = imagePicker.path.split("/").last;
    if (!fileName.contains("image_picker")) {
      print("!fileName.contains image_picker $fileName");
      return;
    }
    fileName = fileName.replaceAll("image_picker", "");
    print("fileName $fileName");

    var newImagePath = "${gd.backgroundUserFolderPath}/$fileName";
    print("newImagePath $newImagePath");
//
    if (FileSystemEntity.typeSync(newImagePath) !=
        FileSystemEntityType.notFound) {
      print("newImagePath exists $newImagePath");
      File oldImage = File(newImagePath);
      oldImage.deleteSync(recursive: true);
    }
//
    if (FileSystemEntity.typeSync(newImagePath) !=
        FileSystemEntityType.notFound) {
      print("WTF newImagePath exists newImagePath");
    } else {
      print("File newImage = await imagePicker.copy(newImagePath)");
    }

    File newImage = await imagePicker.copy(newImagePath);

    setState(() {
      _image = newImage;
      log.d("_image path ${_image.path} uri ${_image.uri}");
//      if (!gd.backgroundImage.contains(image.path))
//        gd.backgroundImage.add(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate([
      RaisedButton(
        onPressed: getImage,
        child: Text("Select Background"),
      )
    ]));
  }
}
