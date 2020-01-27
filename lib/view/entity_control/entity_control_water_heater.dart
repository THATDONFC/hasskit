import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class EntityControlWaterHeater extends StatefulWidget {
  final String entityId;
  const EntityControlWaterHeater({@required this.entityId});

  @override
  _EntityControlWaterHeaterState createState() =>
      _EntityControlWaterHeaterState();
}

class _EntityControlWaterHeaterState extends State<EntityControlWaterHeater> {
  @override
  Widget build(BuildContext context) {
    var entity = gd.entities[widget.entityId];
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
          return ' ${value.toInt()}˚';
//          if (gd.entities[entityId].targetTempStep == 1 ||
//              gd.configUnitSystem['temperature'].toString() != "°C") {
//            return ' ${value.toInt()}˚';
//          } else if (gd.entities[entityId].targetTempStep == 0.5) {
//            return ' ${gd.roundTo05(value)}˚';
//          } else {
//            return ' ${value.toStringAsFixed(1)}˚';
//          }
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
      initialValue: entity.temperature < entity.minTemp
          ? entity.minTemp
          : entity.temperature,
      onChangeEnd: (double value) {
        setState(() {
          print('onChangeEnd $value');
          var outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "water_heater",
            "service": "set_temperature",
            "service_data": {
              "entity_id": entity.entityId,
              "temperature": value.toInt(),
            }
          };
          var outMsgEncoded = json.encode(outMsg);
          gd.sendSocketMessage(outMsgEncoded);
        });
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
        gd.entities[widget.entityId].operationList.length > 1
            ? OperationList(entityId: widget.entityId)
            : Container(),
        Row(
          children: <Widget>[
            Switch.adaptive(
              value: entity.awayMode == 'off' ? false : true,
              onChanged: (val) {
                setState(() {
                  var outMsg = {
                    "id": gd.socketId,
                    "type": "call_service",
                    "domain": "water_heater",
                    "service": "set_away_mode",
                    "service_data": {
                      "entity_id": widget.entityId,
                      "away_mode": val,
                    }
                  };
                  var message = json.encode(outMsg);
                  gd.sendSocketMessage(message);
                  val ? entity.awayMode = 'on' : entity.awayMode = 'off';
                });
              },
            ),
            Expanded(child: Text("Away Mode")),
          ],
        ),
        Spacer(),
      ],
    );
  }
}

class OperationList extends StatefulWidget {
  final String entityId;
  const OperationList({@required this.entityId});
  @override
  _OperationListState createState() => _OperationListState();
}

class _OperationListState extends State<OperationList> {
  List<DropdownMenuItem<String>> dropdownMenuItems = [];
  List<String> options = [];

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[widget.entityId];
    dropdownMenuItems = [];
    options = entity.operationList;
    print(options);
    for (String option in options) {
      var dropdownMenuItem = DropdownMenuItem<String>(
        value: option,
        child: Text(
          gd.textToDisplay("$option"),
//          style: Theme.of(context).textTheme.body1,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: gd.textScaleFactorFix,
        ),
      );
      dropdownMenuItems.add(dropdownMenuItem);
    }

    return Container(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: ThemeInfo.colorBottomSheetReverse.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8)),
        child: DropdownButton<String>(
          underline: Container(),
          isExpanded: true,
          value: entity.state,
          items: dropdownMenuItems,
          onChanged: (String newValue) {
            setState(() {
              entity.state = newValue;
              var outMsg = {
                "id": gd.socketId,
                "type": "call_service",
                "domain": "water_heater",
                "service": "set_operation_mode",
                "service_data": {
                  "entity_id": widget.entityId,
                  "operation_mode": newValue,
                }
              };
              var message = json.encode(outMsg);
              gd.sendSocketMessage(message);
            });
          },
        ),
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
