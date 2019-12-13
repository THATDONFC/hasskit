import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:provider/provider.dart';

class EntityControlFan extends StatefulWidget {
  final String entityId;

  const EntityControlFan({@required this.entityId});
  @override
  _EntityControlFanState createState() => _EntityControlFanState();
}

class _EntityControlFanState extends State<EntityControlFan> {
  double buttonValue;
  double buttonHeight = 300.0;
  double buttonWidth = 126.0;
  double currentPosX;
  double currentPosY;
  double startPosX;
  double startPosY;
  double upperPartHeight = 30.0;
  double lowerPartHeight = 80.0;
  double buttonValueOnTapDown;
  int division = 4;
  int currentStep = 0;
  double stepLength;
  bool isSliding = false;
  List<Widget> positionStacks = [];

  @override
  void initState() {
    super.initState();
    buttonValue = lowerPartHeight;
    buttonValueOnTapDown = lowerPartHeight;
    Entity entity = gd.entities[widget.entityId];
    division = entity.speedList.length - 1;
    stepLength = (buttonHeight - upperPartHeight - lowerPartHeight) / division;

    for (int i = 0; i < entity.speedList.length; i++) {
      var positionStack = Positioned(
        top: i * stepLength,
        child: Container(
          width: 5,
          height: 5,
          color: Colors.red,
        ),
      );
      positionStacks.add(positionStack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[widget.entityId].state} | " +
          "${generalData.entities[widget.entityId].isStateOn} | " +
          "${generalData.entities[widget.entityId].speedList} | " +
          "${generalData.entities[widget.entityId].speed} | " +
          "${generalData.entities[widget.entityId].angle} | " +
          "${generalData.entities[widget.entityId].oscillating} | ",
      builder: (context, data, child) {
        if (!isSliding) {
          var entity = gd.entities[widget.entityId];
          if (!entity.isStateOn) {
            buttonValue = lowerPartHeight;
          } else {
            if (entity.speedList.contains(entity.speed)) {
              currentStep = entity.speedList.indexOf(entity.speed.toString());
              buttonValue = lowerPartHeight + currentStep * stepLength;
            }
          }
        }

        return new GestureDetector(
          onVerticalDragStart: (DragStartDetails details) =>
              _onVerticalDragStart(context, details),
          onVerticalDragUpdate: (DragUpdateDetails details) =>
              _onVerticalDragUpdate(context, details),
          onVerticalDragEnd: (DragEndDetails details) =>
              _onVerticalDragEnd(context, details),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: currentStep > 0 ||
                              gd.entities[widget.entityId].isStateOn
                          ? ThemeInfo.colorIconActive
                          : ThemeInfo.colorIconInActive,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius:
                              0.0, // has the effect of softening the shadow
                          spreadRadius:
                              1.0, // has the effect of extending the shadow
                          offset: Offset(
                            0.0, // horizontal, move right 10
                            0.0, // vertical, move down 10
                          ),
                        ),
                      ],
                    ),
                  ),
                  division > 1
                      ? Positioned(
                          bottom: lowerPartHeight + 1 * stepLength - 1,
                          child: Container(
                            width: buttonWidth,
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.0),
                                  ]),
                            ),
                          ),
                        )
                      : Container(),
                  division > 2
                      ? Positioned(
                          bottom: lowerPartHeight + 2 * stepLength - 1,
                          child: Container(
                            width: buttonWidth,
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.0),
                                  ]),
                            ),
                          ),
                        )
                      : Container(),
                  division > 3
                      ? Positioned(
                          bottom: lowerPartHeight + 3 * stepLength - 1,
                          child: Container(
                            width: buttonWidth,
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.0),
                                  ]),
                            ),
                          ),
                        )
                      : Container(),
                  division > 4
                      ? Positioned(
                          bottom: lowerPartHeight + 4 * stepLength - 1,
                          child: Container(
                            width: buttonWidth,
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.0),
                                  ]),
                            ),
                          ),
                        )
                      : Container(),
                  division > 5
                      ? Positioned(
                          bottom: lowerPartHeight + 5 * stepLength - 1,
                          child: Container(
                            width: buttonWidth,
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.75),
                                    Colors.white.withOpacity(0.0),
                                  ]),
                            ),
                          ),
                        )
                      : Container(),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: buttonWidth,
                      height: buttonValue,
                      padding: const EdgeInsets.all(2.0),
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16)),
                        color: gd.entities[widget.entityId].isStateOn
                            ? Colors.white.withOpacity(1)
                            : Colors.white.withOpacity(1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                              MaterialDesignIcons.getIconDataFromIconName(
                                  gd.entities[widget.entityId].getDefaultIcon),
                              size: 50,
                              color: gd.entities[widget.entityId].isStateOn
                                  ? ThemeInfo.colorIconActive
                                  : ThemeInfo.colorIconInActive),
                          SizedBox(height: 4),
                          Text(
                            gd.textToDisplay(
                                "${gd.entities[widget.entityId].getStateDisplayTranslated(context)}"),
                            style: ThemeInfo.textStatusButtonActive,
                            maxLines: 1,
                            textScaleFactor: gd.textScaleFactorFix,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      width: buttonWidth,
                      height: upperPartHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                      ),
                      alignment: Alignment.center,
                      child: Oscillating(entityId: widget.entityId),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _onVerticalDragStart(BuildContext context, DragStartDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    buttonValueOnTapDown = buttonValue;
    isSliding = true;
    setState(() {
      startPosX = localOffset.dx;
      startPosY = localOffset.dy;
//      log.d(
//          "_onVerticalDragStart startPosX ${startPosX.toStringAsFixed(0)} startPosY ${startPosY.toStringAsFixed(0)}");
    });
  }

  _onVerticalDragEnd(BuildContext context, DragEndDetails details) {
    setState(() {
      isSliding = false;
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
        gd.setState(gd.entities[widget.entityId], 'off', json.encode(outMsg));
      } else {
        outMsg = {
          "id": gd.socketId,
          "type": "call_service",
          "domain": "fan",
          "service": "turn_on",
          "service_data": {
            "entity_id": widget.entityId,
          }
        };
        gd.setState(gd.entities[widget.entityId], 'on', json.encode(outMsg));
        outMsg = {
          "id": gd.socketId,
          "type": "call_service",
          "domain": "fan",
          "service": "set_speed",
          "service_data": {
            "entity_id": widget.entityId,
            "speed": gd.entities[widget.entityId].speedList[currentStep],
          }
        };
        gd.setFanSpeed(
            gd.entities[widget.entityId],
            gd.entities[widget.entityId].speedList[currentStep],
            json.encode(outMsg));
      }
    });
  }

  _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    isSliding = true;
    setState(() {
      currentPosX = localOffset.dx;
      currentPosY = localOffset.dy;
      buttonValue = buttonValueOnTapDown + startPosY - currentPosY;
      buttonValue =
          buttonValue.clamp(lowerPartHeight, buttonHeight - upperPartHeight);
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

        Flushbar(
          title: !entity.oscillating
              ? "Oscilation Disabled"
              : "Oscilation Enabled",
          message: "${gd.textToDisplay(gd.entities[entityId].getOverrideName)}",
          duration: Duration(seconds: 3),
        )..show(context);
      },
      child: Container(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.contain,
          child: !oscillating
              ? Icon(
                  MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:arrow-horizontal-lock"),
                  color: ThemeInfo.colorIconActive,
                  size: 100,
                )
              : Icon(
                  MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:arrow-left-right"),
                  color: ThemeInfo.colorIconInActive,
                  size: 100,
                ),
        ),
      ),
    );
  }
}
