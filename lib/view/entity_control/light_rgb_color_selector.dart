import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/squircle_border.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/base_setting.dart';

class LightRgbColorSelector extends StatefulWidget {
  final String entityId;

  const LightRgbColorSelector({@required this.entityId});
  @override
  _LightRgbColorSelectorState createState() => _LightRgbColorSelectorState();
}

class _LightRgbColorSelectorState extends State<LightRgbColorSelector> {
  Color pickerColor = Color(0xff443a49);
  bool showFlush = true;
  int selectedIndex;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < gd.baseSetting.colorPicker.length; i++) {
      var widget = InkWell(
        onTap: () {
          selectedIndex = i;
          pickerColor =
              gd.stringToColor(gd.baseSetting.colorPicker[selectedIndex]);
          if (showFlush) {
            Fluttertoast.showToast(
                msg: Translate.getString("edit.rbg_color", context),
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
                textColor: Theme.of(context).textTheme.title.color,
                fontSize: 14.0);
            showFlush = false;
          }
          sendColor();
        },
        onLongPress: () {
          selectedIndex = i;
          pickerColor =
              gd.stringToColor(gd.baseSetting.colorPicker[selectedIndex]);
          openColorPicker();
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Material(
            color: gd.stringToColor(gd.baseSetting.colorPicker[i]),
            shape: gd.deviceSetting.shapeLayout == 1
                ? SquircleBorder(
                    side: BorderSide(
                      color: ThemeInfo.colorBottomSheetReverse,
                      width: 1.0,
                    ),
                  )
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: ThemeInfo.colorBottomSheetReverse,
                      width: 1.0,
                    ),
                  ),
            child: Container(
              width: 40,
              height: 40,
            ),
          ),
        ),
      );
      widgets.add(widget);
    }

    return Column(
      children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          widgets[0],
          widgets[1],
          widgets[2],
          widgets[3],
          widgets[4],
          widgets[5],
        ]),
      ],
    );
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void openColorPicker() {
    showDialog(
      context: context,
      child: AlertDialog(
        contentPadding: EdgeInsets.all(8),
        title: Text(Translate.getString("rgb.pick_color", context)),
        backgroundColor: ThemeInfo.colorBottomSheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        content: SingleChildScrollView(
          child: ColorPicker(
            enableAlpha: false,
            displayThumbColor: true,
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            enableLabel: true,
            pickerAreaHeightPercent: 5 / 8,
          ),
        ),
        actions: <Widget>[
          RaisedButton(
            child: Text(Translate.getString("global.reset", context)),
            onPressed: () {
              setState(
                () {
                  gd.baseSetting.colorPicker[selectedIndex] =
                      baseSettingDefaultColor[selectedIndex];
                  pickerColor = gd.stringToColor(
                    baseSettingDefaultColor[selectedIndex],
                  );
                  log.d(
                      "AlertDialog Reset selectedIndex $selectedIndex pickerColor $pickerColor BaseSetting.baseSettingDefaultColor[selectedIndex] ${baseSettingDefaultColor[selectedIndex]}");
                },
              );
              sendColor();
              Navigator.of(context).pop();
              gd.baseSettingSave(true);
            },
          ),
          RaisedButton(
            child: Text(Translate.getString("global.ok", context)),
            onPressed: () {
              setState(
                () {
                  log.d(
                      "AlertDialog OK selectedIndex $selectedIndex pickerColor $pickerColor");
                  gd.baseSetting.colorPicker[selectedIndex] =
                      gd.colorToString(pickerColor);
                },
              );
              sendColor();
              gd.baseSettingSave(true);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void sendColor() {
    if (gd.entities[widget.entityId].effect != null &&
        gd.entities[widget.entityId].effect != "none") {
      var outMsg = {
        "id": gd.socketId,
        "type": "call_service",
        "domain": widget.entityId.split('.').first,
        "service": "turn_on",
        "service_data": {
          "entity_id": widget.entityId,
          "effect": "none",
        },
      };
      var message = jsonEncode(outMsg);
      gd.sendSocketMessage(message);
    }

    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": widget.entityId.split('.').first,
      "service": "turn_on",
      "service_data": {
        "entity_id": widget.entityId,
        "rgb_color": [pickerColor.red, pickerColor.green, pickerColor.blue]
      },
    };

    var message = jsonEncode(outMsg);
    gd.sendSocketMessage(message);

    log.d(
        "sendColor ${[pickerColor.red, pickerColor.green, pickerColor.blue]}");
  }
}
