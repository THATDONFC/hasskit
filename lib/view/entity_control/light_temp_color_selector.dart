import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/squircle_border.dart';
import 'package:hasskit/helper/theme_info.dart';

import 'entity_control_light_dimmer.dart';

class LightTempColorSelector extends StatefulWidget {
  final String entityId;

  const LightTempColorSelector({@required this.entityId});
  @override
  _LightTempColorSelectorState createState() => _LightTempColorSelectorState();
}

class _LightTempColorSelectorState extends State<LightTempColorSelector> {
  int selectedIndex = 0;
  List<Widget> widgets = [];
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < colorTemps.length; i++) {
      var widget = InkWell(
        onTap: () {
          selectedIndex = i;
          sendColor();
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Material(
            color: colorTemps[i],
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

  void sendColor() {
    setState(() {
      if (gd.entities[widget.entityId].effect != null &&
          gd.entities[widget.entityId].effect != "none") {
        var outMsg = {
          "id": gd.socketId,
          "type": "call_service",
          "domain": gd.entities[widget.entityId].entityId.split('.').first,
          "service": "turn_on",
          "service_data": {
            "entity_id": widget.entityId,
            "effect": "none",
          }
        };
        var message = json.encode(outMsg);
        gd.sendSocketMessage(message);
      }

      var outMsg = {
        "id": gd.socketId,
        "type": "call_service",
        "domain": gd.entities[widget.entityId].entityId.split('.').first,
        "service": "turn_on",
        "service_data": {
          "entity_id": widget.entityId,
          "color_temp": gd
              .mapNumber(
                  selectedIndex.toDouble(),
                  0,
                  colorTemps.length.toDouble() - 1,
                  gd.entities[widget.entityId].minMireds.toDouble(),
                  gd.entities[widget.entityId].maxMireds.toDouble() - 1)
              .toInt()
        }
      };

      var message = json.encode(outMsg);
      gd.sendSocketMessage(message);

      log.d("minMireds ${gd.entities[widget.entityId].minMireds} "
          "maxMireds ${gd.entities[widget.entityId].maxMireds} "
          "selectedIndex $selectedIndex");
    });
  }
}
