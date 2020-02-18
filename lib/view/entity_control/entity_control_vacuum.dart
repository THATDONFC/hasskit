import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';

class EntityControlVacuum extends StatefulWidget {
  final String entityId;
  const EntityControlVacuum({@required this.entityId});
  @override
  _EntityControlVacuumState createState() => _EntityControlVacuumState();
}

class _EntityControlVacuumState extends State<EntityControlVacuum> {
  Entity entity;
  String fanSpeed;

  List<bool> isSelected = [];
  List<Widget> toggleButtons = [];
  Map<int, Map<String, dynamic>> commandMap = {};
  Map<String, Widget> childrenSegment = {};
  @override
  void initState() {
    super.initState();
    entity = gd.entities[widget.entityId];
    fanSpeed = entity.fanSpeed;

    for (String fanSpeed in entity.fanSpeedList) {
      var entry = {
        fanSpeed: Text(gd.textToDisplay(fanSpeed)),
      };
      childrenSegment.addAll(entry);
    }

    int i = 0;
    String supportedFeaturesVacuumList = entity.getSupportedFeaturesVacuum;
    if (supportedFeaturesVacuumList.contains("SUPPORT_TURN_ON")) {
      var outMsg = {
        "service": "turn_on",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons.add(buttonWidget("Turn On", "mdi:power-cycle"));
      isSelected.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_TURN_OFF")) {
      var outMsg = {
        "service": "turn_off",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons.add(buttonWidget("Turn Off", "mdi:power-off"));
      isSelected.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_START")) {
      var outMsg = {
        "service": "start",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons.add(buttonWidget("Start", "mdi:play"));
      if (entity.state.toLowerCase() == "cleaning") {
        isSelected.add(true);
      } else {
        isSelected.add(false);
      }
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_PAUSE")) {
      var outMsg = {
        "service": "pause",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons.add(buttonWidget("Pause", "mdi:pause"));
      if (entity.state.toLowerCase() == "idle") {
        isSelected.add(true);
      } else {
        isSelected.add(false);
      }
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_STOP")) {
      var outMsg = {
        "service": "stop",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons.add(buttonWidget("Stop", "mdi:stop"));
      if (entity.state.toLowerCase() == "stop") {
        isSelected.add(true);
      } else {
        isSelected.add(false);
      }
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_CLEAN_SPOT")) {
      var outMsg = {
        "service": "clean_spot",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons.add(buttonWidget("Spot", "mdi:broom"));
      isSelected.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_LOCATE")) {
      var outMsg = {
        "service": "locate",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons.add(buttonWidget("Locate", "mdi:map-marker"));
      isSelected.add(false);
      commandMap[i] = outMsg;
      i = i + 1;
    }
    if (supportedFeaturesVacuumList.contains("SUPPORT_RETURN_HOME")) {
      var outMsg = {
        "service": "return_to_base",
        "service_data": {"entity_id": widget.entityId},
      };
      toggleButtons.add(buttonWidget("Home", "mdi:home-map-marker"));
      if (entity.state.toLowerCase() == "returning" ||
          entity.state.toLowerCase() == "docked") {
        isSelected.add(true);
      } else {
        isSelected.add(false);
      }
      commandMap[i] = outMsg;
      i = i + 1;
    }
  }

  Widget buttonWidget(String buttonText, String buttonIcon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(MaterialDesignIcons.getIconDataFromIconName(buttonIcon)),
        Text(
          buttonText,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: gd.textScaleFactor,
          maxLines: 1,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    entity = gd.entities[widget.entityId];
    String status;
    if (entity.newState != null) {
      var decode = jsonDecode(entity.newState);
      status = decode["attributes"]["status"];
//      print("decode $decode status $status");
    }
    return Column(
      children: <Widget>[
        Spacer(),
        Icon(
          MaterialDesignIcons.getIconDataFromIconName(entity.getDefaultIcon),
          size: 200,
          color: entity.isStateOn
              ? ThemeInfo.colorIconActive
              : ThemeInfo.colorIconInActive,
        ),
        Text(
          status == null
              ? gd.textToDisplay(entity.getStateDisplay)
              : gd.textToDisplay(status),
          style: Theme.of(context).textTheme.headline4,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: gd.textScaleFactorFix,
        ),
        SizedBox(height: 8),
        childrenSegment.length > 1
            ? CupertinoSlidingSegmentedControl<String>(
                padding: EdgeInsets.all(8),
                thumbColor: ThemeInfo.colorIconActive,
                backgroundColor: Colors.transparent,
                children: childrenSegment,
                onValueChanged: (String val) {
                  setState(() {
                    fanSpeed = val;
                    print("setState fanSpeed $fanSpeed");
                    var outMsg = {
                      "id": gd.socketId,
                      "type": "call_service",
                      "domain": widget.entityId.split('.').first,
                      "service": "set_fan_speed",
                      "service_data": {
                        "entity_id": widget.entityId,
                        "fan_speed": fanSpeed
                      },
                    };
                    var message = jsonEncode(outMsg);
                    gd.sendSocketMessage(message);
                  });
                },
                groupValue: fanSpeed,
              )
            : Container(),
        SizedBox(height: 8),
        ToggleButtons(
          borderWidth: 0,
          borderRadius: BorderRadius.circular(8),
          children: toggleButtons,
          isSelected: isSelected,
          onPressed: (int val) {
            setState(() {
              print("onPressed $val commandMap ${commandMap[val].toString()}");
              Map<String, dynamic> jsonCombined = {
                "id": gd.socketId,
                "type": "call_service",
                "domain": "vacuum",
              };
              jsonCombined.addAll(commandMap[val]);
              gd.sendSocketMessage(jsonEncode(jsonCombined));

              for (int i = 0; i < isSelected.length; i++) {
                isSelected[i] = false;
              }
              isSelected[val] = true;
            });
          },
        ),
        Spacer(),
      ],
    );
  }
}
