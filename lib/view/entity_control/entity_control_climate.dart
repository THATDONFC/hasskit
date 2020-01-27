import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class EntityControlClimate extends StatelessWidget {
  final String entityId;
  const EntityControlClimate({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    var entity = gd.entities[entityId];
    var info04 = InfoProperties(
        bottomLabelStyle: Theme.of(context).textTheme.title,
//        bottomLabelStyle: TextStyle(
//            color: HexColor('#54826D'),
//            fontSize: 14,
//            fontWeight: FontWeight.w600),
        bottomLabelText: entity.currentTemperature != null
            ? entity.currentTemperature.toString() + " ˚"
            : "",
        mainLabelStyle: Theme.of(context).textTheme.display3,
//        mainLabelStyle: TextStyle(
//            color: HexColor('#54826D'),
//            fontSize: 30.0,
//            fontWeight: FontWeight.w600),
        modifier: (double value) {
          if (gd.entities[entityId].targetTempStep == 1 ||
              gd.configUnitSystem['temperature'].toString() != "°C") {
            return ' ${value.toInt()}˚';
          } else if (gd.entities[entityId].targetTempStep == 0.5) {
            return ' ${gd.roundTo05(value)}˚';
          } else {
            return ' ${value.toStringAsFixed(1)}˚';
          }
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
    );

    var slider = SleekCircularSlider(
      appearance: CircularSliderAppearance(
        customColors: customColors05,
        infoProperties: info04,
        customWidths: customWidths,
      ),
      min: entity.minTemp,
      max: entity.maxTemp,
      initialValue: entity.getTemperature < entity.minTemp
          ? entity.minTemp
          : entity.getTemperature,
      onChangeEnd: (double value) {
        print('onChangeEnd $value');
        var outMsg;
        if (gd.entities[entityId].targetTempStep == 1 ||
            gd.configUnitSystem['temperature'].toString() != "°C") {
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "climate",
            "service": "set_temperature",
            "service_data": {
              "entity_id": entity.entityId,
              "temperature": value.toInt(),
            }
          };
        } else if (gd.entities[entityId].targetTempStep == 0.5) {
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "climate",
            "service": "set_temperature",
            "service_data": {
              "entity_id": entity.entityId,
              "temperature": gd.roundTo05(value),
            }
          };
        } else {
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "climate",
            "service": "set_temperature",
            "service_data": {
              "entity_id": entity.entityId,
              "temperature": double.parse(value.toStringAsFixed(1)),
            }
          };
        }

        var outMsgEncoded = json.encode(outMsg);
        gd.sendSocketMessage(outMsgEncoded);
      },
    );

    return Column(
      children: <Widget>[
        Spacer(),
        SizedBox(
          width: 240,
          height: 240,
          child: slider,
        ),
        gd.entities[entityId].fanModes.length > 1
            ? FanSpeed(entityId: entityId)
            : Container(),
        gd.entities[entityId].hvacModes.length > 1
            ? SizedBox(height: 16)
            : Container(),
        gd.entities[entityId].hvacModes.length > 1
            ? HvacModes(entityId: entityId)
            : Container(),
        gd.entities[entityId].presetModes.length > 1
            ? SizedBox(height: 16)
            : Container(),
        gd.entities[entityId].presetModes.length > 1
            ? PresetModes(
                entityId: entityId,
              )
            : Container(),
        Spacer(),
      ],
    );
  }
}

class FanSpeed extends StatefulWidget {
  final String entityId;
  const FanSpeed({@required this.entityId});
  @override
  _FanSpeedState createState() => _FanSpeedState();
}

class _FanSpeedState extends State<FanSpeed> {
  final children = <String, Widget>{};
  Entity entity;
  String groupValue;

  @override
  Widget build(BuildContext context) {
    entity = gd.entities[widget.entityId];
    groupValue = entity.fanMode;

    for (String fanMode in entity.fanModes) {
      children[fanMode] = Text(
        gd.textToDisplay(fanMode),
        textScaleFactor: gd.textScaleFactorFix,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      child: CupertinoSlidingSegmentedControl<String>(
        thumbColor: ThemeInfo.colorBottomSheetReverse.withOpacity(0.75),
        children: children,
        onValueChanged: (String val) {
          setState(() {
            groupValue = val;
            var outMsg = {
              "id": gd.socketId,
              "type": "call_service",
              "domain": "climate",
              "service": "set_fan_mode",
              "service_data": {
                "entity_id": widget.entityId,
                "fan_mode": "$groupValue"
              }
            };
            var message = json.encode(outMsg);
            gd.sendSocketMessage(message);
          });
        },
        groupValue: groupValue,
      ),
    );
  }
}

class HvacModes extends StatefulWidget {
  final String entityId;
  const HvacModes({@required this.entityId});
  @override
  _HvacModesState createState() => _HvacModesState();
}

class _HvacModesState extends State<HvacModes> {
  final children = <String, Widget>{};
  Entity entity;
  String groupValue;

  @override
  Widget build(BuildContext context) {
    entity = gd.entities[widget.entityId];
    groupValue = entity.state;
    for (String hvacMode in entity.hvacModes) {
      children[hvacMode] = Text(
        gd.textToDisplay(hvacMode),
        textScaleFactor: gd.textScaleFactorFix,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      child: CupertinoSlidingSegmentedControl<String>(
        thumbColor: gd.climateModeToColor(groupValue),
        children: children,
        onValueChanged: (String val) {
          setState(() {
            groupValue = val;
            var outMsg = {
              "id": gd.socketId,
              "type": "call_service",
              "domain": "climate",
              "service": "set_hvac_mode",
              "service_data": {
                "entity_id": widget.entityId,
                "hvac_mode": "$groupValue"
              }
            };
            var message = json.encode(outMsg);
            gd.sendSocketMessage(message);
          });
        },
        groupValue: groupValue,
      ),
    );
  }
}

class PresetModes extends StatefulWidget {
  final String entityId;
  const PresetModes({@required this.entityId});
  @override
  _PresetModesState createState() => _PresetModesState();
}

class _PresetModesState extends State<PresetModes> {
  final children = <String, Widget>{};
  Entity entity;
  String groupValue;

  @override
  Widget build(BuildContext context) {
    entity = gd.entities[widget.entityId];
    groupValue = entity.presetMode;
    if (groupValue == null) groupValue = entity.presetModes.first;
    for (String presetMode in entity.presetModes) {
      children[presetMode] = Text(
        gd.textToDisplay(presetMode),
        textScaleFactor: gd.textScaleFactorFix,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      child: CupertinoSlidingSegmentedControl<String>(
        thumbColor: gd.climateModeToColor(groupValue),
        children: children,
        onValueChanged: (String val) {
          setState(() {
            groupValue = val;
            var outMsg = {
              "id": gd.socketId,
              "type": "call_service",
              "domain": "climate",
              "service": "set_preset_mode",
              "service_data": {
                "entity_id": widget.entityId,
                "preset_mode": "$groupValue"
              }
            };
            var message = json.encode(outMsg);
            gd.sendSocketMessage(message);
          });
        },
        groupValue: groupValue,
      ),
    );
  }
}
