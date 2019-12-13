import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class EntityControlClimate extends StatelessWidget {
  final String entityId;
  const EntityControlClimate({@required this.entityId});

  @override
  Widget build(BuildContext context) {
//    var hvacVal = "Off";
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[entityId].state}" +
          "${generalData.entities[entityId].hvacModeIndex}" +
          "${generalData.entities[entityId].temperature}" +
          "${generalData.entities[entityId].getFriendlyName}" +
          "${generalData.entities[entityId].getOverrideIcon}",
      builder: (context, data, child) {
        var entity = gd.entities[entityId];
        int hvacModeIndex = entity.hvacModeIndex;
        int fanModeIndex = entity.fanModeIndex;
        var info04 = InfoProperties(
//            bottomLabelStyle: Theme.of(context).textTheme.title,
//        bottomLabelStyle: TextStyle(
//            color: HexColor('#54826D'),
//            fontSize: 14,
//            fontWeight: FontWeight.w600),
//            bottomLabelText: entity.getOverrideName,
            mainLabelStyle: Theme.of(context).textTheme.display3,
//        mainLabelStyle: TextStyle(
//            color: HexColor('#54826D'),
//            fontSize: 30.0,
//            fontWeight: FontWeight.w600),
            modifier: (double value) {
              var temp = value.toInt();
              return '$temp˚';
            });

        var customColors05 = CustomSliderColors(
          trackColor: Colors.amber,
          progressBarColors: [Colors.amber, Colors.green],
          gradientStartAngle: 0,
          gradientEndAngle: 180,
          dotColor: Colors.white,
          hideShadow: true,
          shadowColor: Colors.black12,
          shadowMaxOpacity: 0.25,
          shadowStep: 1,
        );
        var customWidths = CustomSliderWidths(
          handlerSize: 8,
          progressBarWidth: 20,
//      shadowWidth: 10,
//      trackWidth: 10,
        );

        var slider = SleekCircularSlider(
          appearance: CircularSliderAppearance(
            customColors: customColors05,
            infoProperties: info04,
            customWidths: customWidths,
          ),
          min: entity.minTemp,
          max: entity.maxTemp,
          initialValue: entity.getTemperature,
//        innerWidget: (double value) {
//          print('innerWidget $value');
//          return Center(child: Text('$value'));
//        },
//      onChange: (double value) {
//        print('onChange $value');
//      },

          onChangeEnd: (double value) {
            print('onChangeEnd $value');

            var outMsg = {
              "id": gd.socketId,
              "type": "call_service",
              "domain": "climate",
              "service": "set_temperature",
              "service_data": {
                "entity_id": entity.entityId,
                "temperature": value.toInt(),
              }
            };
            var outMsgEncoded = json.encode(outMsg);
            gd.sendSocketMessage(outMsgEncoded);
          },
        );

        List<Widget> hvacModes = [];

        for (String hvacMode in entity.hvacModes) {
          var widget = Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    gd.textToDisplay(hvacMode),
                    style: Theme.of(context).textTheme.subhead,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: gd.textScaleFactorFix,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  gd.climateModeToIcon(hvacMode),
                  color: gd.climateModeToColor(hvacMode),
                ),
                SizedBox(width: 6),
              ],
            ),
          );
          hvacModes.add(widget);
        }
        List<Widget> fanModes = [];

        var hvacModesScrollController =
            FixedExtentScrollController(initialItem: hvacModeIndex);

        for (String fanMode in entity.fanModes) {
          var widget = Container(
            child: Row(
              children: <Widget>[
                SizedBox(width: 6),
                Icon(
                  MaterialDesignIcons.getIconDataFromIconName('mdi:fan'),
                  color: ThemeInfo.colorBottomSheetReverse,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    gd.textToDisplay(fanMode),
                    style: Theme.of(context).textTheme.subhead,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
          fanModes.add(widget);
        }

        var fanModesScrollController =
            FixedExtentScrollController(initialItem: fanModeIndex);

//        Map<String, Widget> hvacSegments = <String, Widget>{
//          "Off": Text('Off'),
//          "Heat": Text('Heat'),
//          "Cool": Text('Cool'),
//        };

//        var hvacSegment = CupertinoSlidingSegmentedControl<String>(
//          thumbColor: ThemeInfo.colorBottomSheetReverse.withOpacity(0.5),
//          padding: EdgeInsets.all(12),
//          children: hvacSegments,
//          onValueChanged: (String val) {
//            hvacVal = val;
//            log.d("onValueChanged hvacVal $hvacVal");
//          },
//          groupValue: hvacVal,
//        );

        return Column(
          children: <Widget>[
            SizedBox(
              width: 240,
              height: 240,
              child: slider,
            ),
//            hvacSegment,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.5),
                          ]),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      border: Border.all(
//          color: ThemeInfo.pickerActivateStyle.color,
                        width: 1.0,
                      ),
                    ),
                    height: 120,
                    child: CupertinoPicker(
                      squeeze: 1.45,
                      diameterRatio: 1.1,
                      offAxisFraction: -0.5,
                      scrollController: hvacModesScrollController,
                      magnification: 1,
                      backgroundColor: Colors.transparent,
                      children: hvacModes,
                      itemExtent: 32, //height of each item
                      looping: true,
                      onSelectedItemChanged: (int index) {
                        hvacModeIndex = index;
//                  print(
//                      'hvacModeIndex $hvacModeIndex ${entity.climate.hvacModes}');
                        var outMsg = {
                          "id": gd.socketId,
                          "type": "call_service",
                          "domain": "climate",
                          "service": "set_hvac_mode",
                          "service_data": {
                            "entity_id": entity.entityId,
                            "hvac_mode": "${entity.hvacModes[hvacModeIndex]}"
                          }
                        };
                        var delayOutMsg = json.encode(outMsg);
                        gd.sendSocketMessageDelay(delayOutMsg, 1);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 1,
                  height: 60,
                  child: Container(
                    color: Colors.black26,
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.5),
                          ]),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                      border: Border.all(
//          color: ThemeInfo.pickerActivateStyle.color,
                        width: 1.0,
                      ),
                    ),
                    height: 120,
                    child: CupertinoPicker(
                      squeeze: 1.45,
                      diameterRatio: 1.1,
                      offAxisFraction: 0.5,
                      scrollController: fanModesScrollController,
                      magnification: 1,
                      backgroundColor: Colors.transparent,
                      children: fanModes,
                      itemExtent: 32, //height of each item
                      looping: true,
                      onSelectedItemChanged: (int index) {
                        fanModeIndex = index;
                        print('fanModeIndex $fanModeIndex ${entity.fanModes}');
                        var outMsg = {
                          "id": gd.socketId,
                          "type": "call_service",
                          "domain": "climate",
                          "service": "set_fan_mode",
                          "service_data": {
                            "entity_id": entity.entityId,
                            "fan_mode": "${entity.fanModes[fanModeIndex]}"
                          }
                        };
                        var delayOutMsg = json.encode(outMsg);
                        gd.sendSocketMessageDelay(delayOutMsg, 1);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
