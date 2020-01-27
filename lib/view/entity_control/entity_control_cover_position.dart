import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';

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
  double buttonWidth = 93.75;
  double currentPosX;
  double currentPosY;
  double startPosX;
  double startPosY;
  double buttonValue = 0;
  double lowerPartHeight = 68.0;
  double buttonValueOnTapDown = 0;

  @override
  void initState() {
    super.initState();

    if (!gd.entities[widget.entityId].isStateOn) {
      buttonValue = lowerPartHeight;
    } else {
      var mapValue = gd.mapNumber(gd.entities[widget.entityId].currentPosition,
          0, 100, lowerPartHeight, buttonHeight);
      buttonValue = mapValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onVerticalDragStart: (DragStartDetails details) =>
          _onVerticalDragStart(context, details),
      onVerticalDragUpdate: (DragUpdateDetails details) =>
          _onVerticalDragUpdate(context, details),
      onVerticalDragEnd: (DragEndDetails details) =>
          _onVerticalDragEnd(context, details, gd.entities[widget.entityId]),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: buttonWidth,
                height: buttonHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: gd.entities[widget.entityId].isStateOn
                      ? ThemeInfo.colorIconActive
                      : ThemeInfo.colorGray,
                ),
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: buttonWidth,
                  height: buttonValue > 0 ? buttonValue : lowerPartHeight,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  child: Text(
                    gd
                        .mapNumber(
                            buttonValue, lowerPartHeight, buttonHeight, 0, 100)
                        .toInt()
                        .toString(),
                    style: TextStyle(
                      color: gd.entities[widget.entityId].isStateOn
                          ? ThemeInfo.colorIconActive
                          : ThemeInfo.colorGray,
                    ),
                    textAlign: TextAlign.center,
                    textScaleFactor: gd.textScaleFactorFix,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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
            child: SizedBox(
              width: 50,
              height: 50,
              child: Icon(
                MaterialDesignIcons.getIconDataFromIconName(
                    gd.entities[widget.entityId].getDefaultIcon),
                size: 45,
                color: gd.entities[widget.entityId].isStateOn
                    ? ThemeInfo.colorIconActive
                    : ThemeInfo.colorGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onVerticalDragStart(BuildContext context, DragStartDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
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
        var sendValue =
            gd.mapNumber(buttonValue, lowerPartHeight, buttonHeight, 0, 100);

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
        gd.sendSocketMessage(outMsgEncoded);
      },
    );
  }

  _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      currentPosX = localOffset.dx;
      currentPosY = localOffset.dy;
//      log.d(
//          "_onVerticalDragUpdate currentPosX ${currentPosX.toStringAsFixed(0)} currentPosY ${currentPosY.toStringAsFixed(0)}");
      buttonValue = buttonValueOnTapDown + (startPosY - currentPosY);
      buttonValue = buttonValue.clamp(lowerPartHeight, buttonHeight);
    });
  }
}
