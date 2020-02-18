import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';

class EntityControlFan extends StatefulWidget {
  final String entityId;

  const EntityControlFan({@required this.entityId});
  @override
  _EntityControlFanState createState() => _EntityControlFanState();
}

class _EntityControlFanState extends State<EntityControlFan> {
  double buttonValue;
  double buttonHeight = 300.0;
  double buttonWidth = 93.75;
  double currentPosX;
  double currentPosY;
  double startPosX;
  double startPosY;
  double lowerPartHeight = 80.0;
  double buttonValueOnTapDown;
  int division = 4;
  int currentStep = 0;
  double stepLength;
  List<Widget> positionStacks = [];
  List<String> speedList = [];

  @override
  void initState() {
    super.initState();
    buttonValue = lowerPartHeight;
    buttonValueOnTapDown = lowerPartHeight;
    Entity entity = gd.entities[widget.entityId];
    speedList = entity.speedList;
    if (!speedList.contains("off") &&
        !speedList.contains("Off") &&
        !speedList.contains("OFF")) {
      speedList.insert(0, 'off');
    }
    division = speedList.length - 1;
    stepLength = (buttonHeight - lowerPartHeight) / division;

    for (int i = 0; i < speedList.length; i++) {
      var positionStack = Positioned(
        top: i * stepLength,
        child: Container(
          width: 5,
          height: 5,
        ),
      );
      positionStacks.add(positionStack);
    }

    if (!entity.isStateOn) {
      buttonValue = lowerPartHeight;
    } else {
      if (speedList.contains(entity.speed)) {
        currentStep = speedList.indexOf(entity.speed.toString());
        buttonValue = lowerPartHeight + currentStep * stepLength;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Spacer(),
        new GestureDetector(
          onVerticalDragStart: (DragStartDetails details) =>
              _onVerticalDragStart(context, details),
          onVerticalDragUpdate: (DragUpdateDetails details) =>
              _onVerticalDragUpdate(context, details),
          onVerticalDragEnd: (DragEndDetails details) =>
              _onVerticalDragEnd(context, details),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(
                width: buttonWidth,
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: gd.entities[widget.entityId].isStateOn
                      ? ThemeInfo.colorIconActive
                      : ThemeInfo.colorGray,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              division > 0
                  ? Positioned(
                      bottom: lowerPartHeight + 0 * stepLength,
                      child: Container(
                        width: buttonWidth,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withOpacity(0.25),
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.25),
                              ]),
                        ),
                      ),
                    )
                  : Container(),
              division > 1
                  ? Positioned(
                      bottom: lowerPartHeight + 1 * stepLength,
                      child: Container(
                        width: buttonWidth,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withOpacity(0.25),
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.25),
                              ]),
                        ),
                      ),
                    )
                  : Container(),
              division > 2
                  ? Positioned(
                      bottom: lowerPartHeight + 2 * stepLength,
                      child: Container(
                        width: buttonWidth,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withOpacity(0.25),
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.25),
                              ]),
                        ),
                      ),
                    )
                  : Container(),
              division > 3
                  ? Positioned(
                      bottom: lowerPartHeight + 3 * stepLength,
                      child: Container(
                        width: buttonWidth,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withOpacity(0.25),
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.25),
                              ]),
                        ),
                      ),
                    )
                  : Container(),
              division > 4
                  ? Positioned(
                      bottom: lowerPartHeight + 4 * stepLength,
                      child: Container(
                        width: buttonWidth,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withOpacity(0.25),
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.25),
                              ]),
                        ),
                      ),
                    )
                  : Container(),
              division > 5
                  ? Positioned(
                      bottom: lowerPartHeight + 5 * stepLength,
                      child: Container(
                        width: buttonWidth,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withOpacity(0.25),
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.25),
                              ]),
                        ),
                      ),
                    )
                  : Container(),
              Positioned(
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: buttonWidth,
                      height: buttonValue,
                      padding: const EdgeInsets.all(2.0),
                      decoration: new BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      child: Text(
                        gd.textToDisplay(
                            "${gd.entities[widget.entityId].getStateDisplayTranslated(gd.mediaQueryContext)}"),
                        style: ThemeInfo.textStatusButtonActive,
                        maxLines: 2,
                        textScaleFactor: gd.textScaleFactorFix,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: buttonWidth,
                height: buttonHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                  border: Border.all(
                    color: ThemeInfo.colorBottomSheetReverse,
                    width: 1.0,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  children: <Widget>[
                    Icon(
                        MaterialDesignIcons.getIconDataFromIconName(
                            gd.entities[widget.entityId].getDefaultIcon),
                        size: gd.entities[widget.entityId].oscillating != null
                            ? 30
                            : 50,
                        color: gd.entities[widget.entityId].isStateOn
                            ? ThemeInfo.colorIconActive
                            : ThemeInfo.colorGray),
                    Oscillating(entityId: widget.entityId),
                  ],
                ),
              ),
            ],
          ),
        ),
        Spacer(),
      ],
    );
  }

  _onVerticalDragStart(BuildContext context, DragStartDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    buttonValueOnTapDown = buttonValue;
    setState(() {
      startPosX = localOffset.dx;
      startPosY = localOffset.dy;
//      log.d(
//          "_onVerticalDragStart startPosX ${startPosX.toStringAsFixed(0)} startPosY ${startPosY.toStringAsFixed(0)}");
    });
  }

  _onVerticalDragEnd(BuildContext context, DragEndDetails details) {
    setState(() {
      for (int i = division; i >= 0; i--) {
        if (buttonValue - lowerPartHeight >= i * stepLength - stepLength / 2) {
          currentStep = i;
          buttonValue = lowerPartHeight + currentStep * stepLength;
          break;
        }
      }
      log.d(
          "_onVerticalDragEnd currentStep $currentStep buttonValue $buttonValue");

      var outMsg;

      if (currentStep == 0) {
        outMsg = {
          "id": gd.socketId,
          "type": "call_service",
          "domain": "fan",
          "service": "turn_off",
          "service_data": {
            "entity_id": widget.entityId,
          }
        };
        gd.entities[widget.entityId].state = "off";
      } else {
        if (!gd.entities[widget.entityId].isStateOn) {
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "fan",
            "service": "turn_on",
            "service_data": {
              "entity_id": widget.entityId,
            }
          };
          gd.entities[widget.entityId].state = "on";
          var message = json.encode(outMsg);
          gd.sendSocketMessage(message);
        }

        outMsg = {
          "id": gd.socketId,
          "type": "call_service",
          "domain": "fan",
          "service": "set_speed",
          "service_data": {
            "entity_id": widget.entityId,
            "speed": speedList[currentStep],
          }
        };
      }
      gd.entities[widget.entityId].speed = speedList[currentStep];
      print(
          "XXX speed ${gd.entities[widget.entityId].speed} state ${gd.entities[widget.entityId].state} getStateDisplay ${gd.entities[widget.entityId].getStateDisplay} getStateDisplayTranslated ${gd.entities[widget.entityId].getStateDisplayTranslated(context)}");
      var message = json.encode(outMsg);
      gd.sendSocketMessage(message);
    });
  }

  _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      currentPosX = localOffset.dx;
      currentPosY = localOffset.dy;
      buttonValue = buttonValueOnTapDown + startPosY - currentPosY;
      buttonValue = buttonValue.clamp(lowerPartHeight, buttonHeight);
    });
  }
}

class Oscillating extends StatelessWidget {
  final String entityId;
  const Oscillating({@required this.entityId});
  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[entityId];

    if (entity.oscillating == null) {
      return Container();
    }
    bool oscillating = entity.oscillating;
//    print("entity.oscillating ${oscillating}");

    return InkWell(
      onTap: () {
        var outMsg = {
          "id": gd.socketId,
          "type": "call_service",
          "domain": "fan",
          "service": "oscillate",
          "service_data": {
            "entity_id": entity.entityId,
            "oscillating": !oscillating,
          }
        };

        gd.setFanOscillating(entity, !oscillating, json.encode(outMsg));

        Fluttertoast.showToast(
            msg: !entity.oscillating
                ? "Oscilation Disabled"
                : "Oscilation Enabled",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
            textColor: Theme.of(context).textTheme.headline6.color,
            fontSize: 14.0);
      },
      child: Container(
        child: !oscillating
            ? Icon(
                MaterialDesignIcons.getIconDataFromIconName(
                    "mdi:arrow-horizontal-lock"),
                color: ThemeInfo.colorIconActive,
                size: 30,
              )
            : Icon(
                MaterialDesignIcons.getIconDataFromIconName(
                    "mdi:arrow-left-right"),
                color: ThemeInfo.colorGray,
                size: 30,
              ),
      ),
    );
  }
}
