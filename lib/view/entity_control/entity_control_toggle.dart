import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';

class EntityControlToggle extends StatefulWidget {
  final String entityId;

  const EntityControlToggle({@required this.entityId});
  @override
  _EntityControlToggleState createState() => _EntityControlToggleState();
}

class _EntityControlToggleState extends State<EntityControlToggle> {
  double buttonHeight = 300.0;
  double buttonWidth = 93.75;
  double lowerPartHeight = 150.0;
  double buttonValue;
  double currentPosX;
  double currentPosY;
  double startPosX;
  double startPosY;
  double diffY = 0;
  double snap = 10;
  bool isDragging = false;
  @override
  void initState() {
    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!isDragging) {
      if (gd.entities[widget.entityId].isStateOn) {
        buttonValue = buttonHeight;
      } else {
        buttonValue = lowerPartHeight;
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
                        gd.textToDisplay(gd.entities[widget.entityId]
                            .getStateDisplayTranslated(context)),
                        style: TextStyle(
                          color: gd.entities[widget.entityId].isStateOn
                              ? ThemeInfo.colorIconActive
                              : ThemeInfo.colorGray,
                        ),
                        textAlign: TextAlign.center,
                        textScaleFactor: gd.textScaleFactorFix,
                        overflow: TextOverflow.ellipsis,
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
                    RequireSlideToOpen(
                      entityId: widget.entityId,
                      refresh: refresh,
                    ),
                    SizedBox(
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
                  ],
                ),
              ),
            ],
          ),
          widget.entityId.contains("automation.")
              ? RaisedButton(
                  onPressed: () {
                    var outMsg = {
                      "id": gd.socketId,
                      "type": "call_service",
                      "domain": "automation",
                      "service": "trigger",
                      "service_data": {
                        "entity_id": widget.entityId,
                      }
                    };
                    var message = json.encode(outMsg);
                    gd.sendSocketMessage(message);
                  },
                  child: Text("Trigger"),
                )
              : Container(),
        ],
      ),
    );
  }

  _onVerticalDragStart(BuildContext context, DragStartDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      isDragging = true;
      startPosX = localOffset.dx;
      startPosY = localOffset.dy;
//      log.d(
//          "_onVerticalDragStart startPosX ${startPosX.toStringAsFixed(0)} startPosY ${startPosY.toStringAsFixed(0)}");
    });
  }

  _onVerticalDragEnd(BuildContext context, DragEndDetails details) {
    setState(
      () {
        log.d("_onVerticalDragEnd");
        diffY = 0;
        isDragging = false;
        if (gd.entities[widget.entityId].isStateOn) {
          buttonValue = buttonHeight;
        } else {
          buttonValue = lowerPartHeight;
        }
      },
    );
  }

  _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      isDragging = true;
      currentPosX = localOffset.dx;
      currentPosY = localOffset.dy;
      diffY = startPosY - currentPosY;
      var stateValue;

      if (gd.entities[widget.entityId].isStateOn) {
        stateValue = buttonHeight;
        if (diffY > 0) diffY = 0;
        if (stateValue + diffY < lowerPartHeight + snap)
          gd.toggleStatus(gd.entities[widget.entityId]);
      }

      if (!gd.entities[widget.entityId].isStateOn) {
        stateValue = lowerPartHeight;
        if (diffY < 0) diffY = 0;
        if (stateValue + diffY > buttonHeight - snap)
          gd.toggleStatus(gd.entities[widget.entityId]);
      }

      buttonValue = stateValue + diffY;

//      print("yDiff $diffY");
    });
  }
}

class RequireSlideToOpen extends StatelessWidget {
  final String entityId;
  final Function refresh;
  const RequireSlideToOpen({@required this.entityId, @required this.refresh});
  @override
  Widget build(BuildContext context) {
    if (!entityId.contains("cover.")) {
      return Container();
    }

    bool required = false;

    if (gd.entitiesOverride[entityId] != null &&
        gd.entitiesOverride[entityId].openRequireAttention != null &&
        gd.entitiesOverride[entityId].openRequireAttention == true) {
      required = true;
    }

    return SizedBox(
      width: 50,
      height: 50,
      child: InkWell(
        onTap: () {
          gd.requireSlideToOpenAddRemove(entityId);
//          Flushbar(
//            title: required
//                ? Translate.getString(
//                    "toggle.require_slide_open_disabled", context)
//                : Translate.getString(
//                    "toggle.require_slide_open_enabled", context),
//            message: required
//                ? "${gd.textToDisplay(gd.entities[entityId].getOverrideName)} ${Translate.getString('toggle.1_touch', context)}"
//                : "${Translate.getString('toggle.prevent_accidentally_open', context)} ${gd.textToDisplay(gd.entities[entityId].getOverrideName)}",
//            duration: Duration(seconds: 3),
//          )..show(context);

          Fluttertoast.showToast(
              msg: required
                  ? Translate.getString(
                      "toggle.require_slide_open_disabled", context)
                  : Translate.getString(
                      "toggle.require_slide_open_enabled", context),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
              textColor: Theme.of(context).textTheme.headline6.color,
              fontSize: 14.0);

          refresh();
        },
        child: Icon(
          required
              ? MaterialDesignIcons.getIconDataFromIconName("mdi:lock")
              : MaterialDesignIcons.getIconDataFromIconName("mdi:lock-open"),
          color: required ? ThemeInfo.colorIconActive : ThemeInfo.colorGray,
          size: 45,
        ),
      ),
    );
  }
}
