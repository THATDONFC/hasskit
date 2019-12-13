import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/helper/WebSocket.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:provider/provider.dart';

class EntityControlCoverPosition extends StatelessWidget {
  final String entityId;
  const EntityControlCoverPosition({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CoverSlider(
            entityId: entityId,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class CoverSlider extends StatefulWidget {
  final String entityId;

  const CoverSlider({@required this.entityId});

  @override
  State<StatefulWidget> createState() {
    return new CoverSliderState();
  }
}

class CoverSliderState extends State<CoverSlider> {
  double buttonHeight = 300.0;
  double buttonWidth = 126.0;
  double currentPosX;
  double currentPosY;
  double startPosX;
  double startPosY;
  double buttonValue = 0;
  double upperPartHeight = 30.0;
  double lowerPartHeight = 50.0;
  double buttonValueOnTapDown = 0;
  DateTime draggingTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[widget.entityId].state} " +
          "${generalData.entities[widget.entityId].currentPosition} ",
      builder: (context, data, child) {
        if (draggingTime.millisecondsSinceEpoch <
            DateTime.now().millisecondsSinceEpoch) {
          if (!gd.entities[widget.entityId].isStateOn) {
            buttonValue = lowerPartHeight;
          } else {
            var mapValue = gd.mapNumber(
                gd.entities[widget.entityId].currentPosition,
                0,
                100,
                lowerPartHeight,
                buttonHeight - upperPartHeight);
            buttonValue = mapValue;
          }
          log.d(
              "currentPosition ${gd.entities[widget.entityId].currentPosition} buttonValue $buttonValue ");
        }

        return new GestureDetector(
          onVerticalDragStart: (DragStartDetails details) =>
              _onVerticalDragStart(context, details),
          onVerticalDragUpdate: (DragUpdateDetails details) =>
              _onVerticalDragUpdate(context, details),
          onVerticalDragEnd: (DragEndDetails details) => _onVerticalDragEnd(
              context, details, gd.entities[widget.entityId]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: ThemeInfo.colorBottomSheetReverse,
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
                  Positioned(
                    top: 0,
                    child: Container(
                      width: buttonWidth,
                      height: buttonHeight,
                      decoration: BoxDecoration(
                        color: gd.entities[widget.entityId].isStateOn
                            ? ThemeInfo.colorIconActive
                            : ThemeInfo.colorIconInActive,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: buttonWidth,
                        height: buttonValue,
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16)),
                        ),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(
                            MaterialDesignIcons.getIconDataFromIconName(
                                gd.entities[widget.entityId].getDefaultIcon),
                            size: 45,
                            color: gd.entities[widget.entityId].isStateOn
                                ? ThemeInfo.colorIconActive
                                : ThemeInfo.colorIconInActive,
                          ),
                        ),
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
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        gd
                            .mapNumber(buttonValue, lowerPartHeight,
                                buttonHeight - upperPartHeight, 0, 100)
                            .toInt()
                            .toString(),
                        style: TextStyle(
                          fontSize: 20,
                          color: gd.entities[widget.entityId].isStateOn
                              ? ThemeInfo.colorIconActive
                              : ThemeInfo.colorIconInActive,
                        ),
                      ),
                    ),
                  )
                ],
              ),
//              Text("${gd.entities[widget.entityId].rgbColor}"),
            ],
          ),
        );
      },
    );
  }

  _onVerticalDragStart(BuildContext context, DragStartDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      draggingTime = DateTime.now().add(Duration(seconds: 1));
      startPosX = localOffset.dx;
      startPosY = localOffset.dy;
      buttonValueOnTapDown = buttonValue;
      log.d(
          "_onVerticalDragStart startPosX ${startPosX.toStringAsFixed(0)} startPosY ${startPosY.toStringAsFixed(0)}");
    });
  }

  _onVerticalDragEnd(
      BuildContext context, DragEndDetails details, Entity entity) {
    setState(
      () {
        draggingTime = DateTime.now().add(Duration(seconds: 1));
        var sendValue = gd.mapNumber(buttonValue, lowerPartHeight,
            buttonHeight - upperPartHeight, 0, 100);

        log.d("_onVerticalDragEnd $sendValue");
        var outMsg;
        if (sendValue <= 0) {
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": entity.entityId.split('.').first,
            "service": "close_cover",
            "service_data": {
              "entity_id": entity.entityId,
            },
          };
        } else {
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": entity.entityId.split('.').first,
            "service": "set_cover_position",
            "service_data": {
              "entity_id": entity.entityId,
              "position": sendValue.toInt(),
            },
          };
        }
        var outMsgEncoded = json.encode(outMsg);
        webSocket.send(outMsgEncoded);
        HapticFeedback.mediumImpact();
      },
    );
  }

  _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      draggingTime = DateTime.now().add(Duration(seconds: 1));
      currentPosX = localOffset.dx;
      currentPosY = localOffset.dy;
//      log.d(
//          "_onVerticalDragUpdate currentPosX ${currentPosX.toStringAsFixed(0)} currentPosY ${currentPosY.toStringAsFixed(0)}");
      buttonValue = buttonValueOnTapDown + (startPosY - currentPosY);
      buttonValue =
          buttonValue.clamp(lowerPartHeight, buttonHeight - upperPartHeight);
    });
  }
}
