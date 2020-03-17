import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:image_picker/image_picker.dart';

class BackgroundImageDropdownButton extends StatefulWidget {
  final int roomIndex;
  const BackgroundImageDropdownButton({@required this.roomIndex});

  @override
  _BackgroundImageDropdownButtonState createState() =>
      _BackgroundImageDropdownButtonState();
}

class _BackgroundImageDropdownButtonState
    extends State<BackgroundImageDropdownButton> {
  @override
  Widget build(BuildContext context) {
    var selectedValue =
        gd.backgroundImage[gd.roomList[widget.roomIndex].imageIndex];

    List<DropdownMenuItem<String>> dropdownMenuItems = [];

    for (String imageString in gd.backgroundImage) {
      String imageDisplay = imageString.split("/").last;
      imageDisplay = imageDisplay.split(".").first;

      var dropdownMenuItem = DropdownMenuItem<String>(
        value: imageString,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(4, 2, 2, 2),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image(
              image: AssetImage(
                imageString,
              ),
            ),
          ),
          title: Text(
            gd.textToDisplay("$imageDisplay"),
            style: Theme.of(context).textTheme.bodyText2,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: gd.textScaleFactorFix,
          ),
        ),
      );
      dropdownMenuItems.add(dropdownMenuItem);
//      log.d("dropdownMenuItems ${dropdownMenuItems.length}");
    }
    File _image;
    Future getImage() async {
      var image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1920,
        maxWidth: 1920,
      );
      setState(() {
        _image = image;
        int roomIndex = widget.roomIndex;
        String imagePath = _image.path;
        log.d("roomIndex $roomIndex _image path $imagePath uri ${_image.uri}");
        removeDeviceSettingBackgroundPhoto();
        gd.deviceSetting.backgroundPhoto.add("[$roomIndex]$imagePath");
        gd.delayCancelEditModeTimer(300);
        gd.deviceSettingSave();
//      if (!gd.backgroundImage.contains(image.path))
//        gd.backgroundImage.add(image.path);
      });
    }

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${gd.roomList[widget.roomIndex].name} Background Image",
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: gd.textScaleFactorFix,
                ),
                DropdownButton<String>(
                  underline: Container(),
                  isExpanded: true,
                  value: selectedValue,
                  items: dropdownMenuItems,
                  onChanged: (String newValue) {
                    setState(() {
                      removeDeviceSettingBackgroundPhoto();
                      gd.roomList[widget.roomIndex].imageIndex =
                          gd.backgroundImage.indexOf(newValue);
                      log.d("newValue $newValue");
                      gd.delayCancelEditModeTimer(300);
                      gd.roomListSave(true);
                    });
                  },
                ),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.all(4),
                  child: RaisedButton(
                    onPressed: getImage,
                    child: Row(
                      children: <Widget>[
//                    Icon(Icons.photo_album),
                        Expanded(
                          child: Text(
                            "${gd.roomList[widget.roomIndex].name} Background Photo",
                            overflow: TextOverflow.ellipsis,
                            textScaleFactor: gd.textScaleFactorFix,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void removeDeviceSettingBackgroundPhoto() {
    print("removeDeviceSettingBackgroundPhoto");
    List<String> recToRemove = [];
    for (var rec in gd.deviceSetting.backgroundPhoto) {
      if (rec.contains("[${widget.roomIndex}]")) recToRemove.add(rec);
    }
    print("recToRemove $recToRemove");
    for (var rec in recToRemove) {
      gd.deviceSetting.backgroundPhoto.remove(rec);
    }
    gd.deviceSettingSave();
  }
}
