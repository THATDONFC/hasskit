import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';
import 'package:hasskit/view/entity_control/light_rgb_color_selector.dart';
import 'package:provider/provider.dart';
import 'light_effect_selector.dart';
import 'light_temp_color_selector.dart';

List<Color> colorTemps = [
//  Color(0xff64B5F6), //Blue
//  Color(0xff90CAF9), //Blue
//  Color(0xffBBDEFB), //Blue
//  Color(0xffFFF9C4), //Yellow
  Color(0xffBDBDBD), //Gray
  Color(0xffFFF59D), //Yellow
  Color(0xffFFF176), //Yellow
  Color(0xffFFEE58), //Yellow
  Color(0xffFFEB3B), //Yellow
  Color(0xffFDD835), //Yellow
];

class EntityControlLightDimmer extends StatefulWidget {
  final String entityId;
  final String viewMode;
  const EntityControlLightDimmer(
      {@required this.entityId, @required this.viewMode});

  @override
  _EntityControlLightDimmerState createState() =>
      _EntityControlLightDimmerState();
}

class _EntityControlLightDimmerState extends State<EntityControlLightDimmer> {
  String mode;

  @override
  void initState() {
    mode = widget.viewMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Widget> childrenSegment = {};
    var getSupportedFeaturesLights =
        gd.entities[widget.entityId].getSupportedFeaturesLights;
    if (getSupportedFeaturesLights.contains("SUPPORT_COLOR_TEMP")) {
      var entry = {
        'SUPPORT_COLOR_TEMP': Text("Temp"),
      };
      childrenSegment.addAll(entry);
    }
    if (getSupportedFeaturesLights.contains("SUPPORT_RGB_COLOR")) {
      var entry = {
        'SUPPORT_RGB_COLOR': Text("RGB"),
      };
      childrenSegment.addAll(entry);
    }
    if (getSupportedFeaturesLights.contains("SUPPORT_EFFECT")) {
      var entry = {
        'SUPPORT_EFFECT': Text("Effect"),
      };
      childrenSegment.addAll(entry);
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LightSlider(
            entityId: widget.entityId,
            viewMode: mode,
          ),
          childrenSegment.length >= 2 ? SizedBox(height: 10) : Container(),
          childrenSegment.length >= 2
              ? CupertinoSlidingSegmentedControl<String>(
                  thumbColor: ThemeInfo.colorIconActive,
                  backgroundColor: Colors.transparent,
                  children: childrenSegment,
                  onValueChanged: (String val) {
                    setState(() {
                      mode = val;
                      print("setState mode $mode");
                    });
                  },
                  groupValue: mode,
                )
              : Container(),
          SizedBox(height: 10),
          mode == "SUPPORT_RGB_COLOR"
              ? LightRgbColorSelector(
                  entityId: widget.entityId,
                )
              : mode == "SUPPORT_COLOR_TEMP"
                  ? LightTempColorSelector(
                      entityId: widget.entityId,
                    )
                  : mode == "SUPPORT_EFFECT"
                      ? LightEffectSelector(
                          entityId: widget.entityId,
                        )
                      : Container(),
        ],
      ),
    );
  }
}

class LightSlider extends StatefulWidget {
  final String entityId;
  final String viewMode;

  const LightSlider({@required this.entityId, @required this.viewMode});

  @override
  State<StatefulWidget> createState() {
    return new LightSliderState();
  }
}

class LightSliderState extends State<LightSlider> {
  double buttonHeight = 300.0;
  double buttonWidth = 93.75;
  double currentPosX;
  double currentPosY;
  double startPosX;
  double startPosY;
  Offset buttonPos;
  double buttonValue = 0;
  double lowerPartHeight = 68;
//  double lowerPartHeight = 50;
  double buttonValueOnTapDown = 0;
  String raisedButtonLabel = "";
  //creating Key for red panel
  GlobalKey buttonKey = GlobalKey();
  DateTime draggingTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[widget.entityId].state} " +
          "${generalData.entities[widget.entityId].brightness} " +
          "${generalData.entities[widget.entityId].colorTemp} " +
          "${generalData.entities[widget.entityId].rgbColor} ",
      builder: (context, data, child) {
//        print("LightSlider viewMode ${widget.viewMode} "
//            "colorTemp ${gd.entities[widget.entityId].colorTemp} "
//            "rgbColor ${gd.entities[widget.entityId].rgbColor}");

        if (draggingTime.millisecondsSinceEpoch <
            DateTime.now().millisecondsSinceEpoch) {
          if (!gd.entities[widget.entityId].isStateOn) {
            buttonValue = lowerPartHeight;
          } else {
            var mapValue = gd.mapNumber(
                gd.entities[widget.entityId].brightness.toDouble(),
                0,
                254,
                lowerPartHeight,
                buttonHeight);
            buttonValue = mapValue;
          }
        }
        Color sliderColor;
        if (!gd.entities[widget.entityId].isStateOn) {
          sliderColor = Color.fromRGBO(128, 128, 128, 1.0);
        } else if (widget.viewMode == "SUPPORT_RGB_COLOR" ||
            widget.viewMode == "SUPPORT_EFFECT") {
          var entityRGB = gd.entities[widget.entityId].rgbColor;
          if (entityRGB == null ||
              entityRGB.length < 3 ||
              entityRGB[0] > 250 && entityRGB[1] > 250 && entityRGB[2] > 250)
            entityRGB = [192, 192, 192];
          sliderColor =
              Color.fromRGBO(entityRGB[0], entityRGB[1], entityRGB[2], 1.0);
        } else if (widget.viewMode == "SUPPORT_COLOR_TEMP" &&
            gd.entities[widget.entityId].colorTemp != null &&
            gd.entities[widget.entityId].maxMireds != null &&
            gd.entities[widget.entityId].minMireds != null) {
          var colorTemp = gd.entities[widget.entityId].colorTemp;
          var minMireds = gd.entities[widget.entityId].minMireds;
          var maxMireds = gd.entities[widget.entityId].maxMireds;
          var miredsDivided = (maxMireds - minMireds) / colorTemps.length;
          var miredsDividedHalf = miredsDivided / 2;
//          log.d(
//              "colorTemp $colorTemp minMireds $minMireds maxMireds $maxMireds miredsDivided $miredsDivided");
          if (colorTemp <= minMireds + miredsDivided * 1 - miredsDividedHalf)
            sliderColor = colorTemps[0];
          else if (colorTemp <=
              minMireds + miredsDivided * 2 - miredsDividedHalf)
            sliderColor = colorTemps[1];
          else if (colorTemp <=
              minMireds + miredsDivided * 3 - miredsDividedHalf)
            sliderColor = colorTemps[2];
          else if (colorTemp <=
              minMireds + miredsDivided * 4 - miredsDividedHalf)
            sliderColor = colorTemps[3];
          else if (colorTemp <=
              minMireds + miredsDivided * 5 - miredsDividedHalf)
            sliderColor = colorTemps[4];
          else
            sliderColor = colorTemps[5];
        } else {
          sliderColor = colorTemps[0];
        }

        return new GestureDetector(
          onVerticalDragStart: (DragStartDetails details) =>
              _onVerticalDragStart(context, details),
          onVerticalDragUpdate: (DragUpdateDetails details) =>
              _onVerticalDragUpdate(context, details),
          onVerticalDragEnd: (DragEndDetails details) => _onVerticalDragEnd(
              context, details, gd.entities[widget.entityId]),
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
                      color: sliderColor,
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
                            .mapNumber(buttonValue, lowerPartHeight,
                                buttonHeight, 0, 100)
                            .toInt()
                            .toString(),
                        style: TextStyle(
                          color: sliderColor,
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
                    color: sliderColor,
                  ),
                ),
              )
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
        var sendValue =
            gd.mapNumber(buttonValue, lowerPartHeight, buttonHeight, 0, 255);
        log.d("_onVerticalDragEnd $sendValue");
        var outMsg;
        if (sendValue <= 0) {
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": entity.entityId.split('.').first,
            "service": "turn_off",
            "service_data": {
              "entity_id": entity.entityId,
            },
          };
        } else {
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": entity.entityId.split('.').first,
            "service": "turn_on",
            "service_data": {
              "entity_id": entity.entityId,
              "brightness": sendValue.toInt()
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
      draggingTime = DateTime.now().add(Duration(seconds: 1));
      currentPosX = localOffset.dx;
      currentPosY = localOffset.dy;
//      log.d(
//          "_onVerticalDragUpdate currentPosX ${currentPosX.toStringAsFixed(0)} currentPosY ${currentPosY.toStringAsFixed(0)}");
      buttonValue = buttonValueOnTapDown + (startPosY - currentPosY);
      buttonValue = buttonValue.clamp(lowerPartHeight, buttonHeight);
    });
  }
}
