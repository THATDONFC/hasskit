import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:provider/provider.dart';

class EntityControlAlarmPanel extends StatefulWidget {
  final String entityId;

  const EntityControlAlarmPanel({@required this.entityId});
  @override
  _EntityControlAlarmPanelState createState() =>
      _EntityControlAlarmPanelState();
}

class _EntityControlAlarmPanelState extends State<EntityControlAlarmPanel> {
  final int keyCodeLength = 4;
  String output = "";
  String _readableState = "";

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  _arm(entity) {
    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": entity.entityId.split('.').first,
      "service": "alarm_" + gd.deviceSetting.lastArmType,
      "service_data": {"entity_id": entity.entityId, "code": output}
    };

    var outMsgEncoded = json.encode(outMsg);
    gd.sendSocketMessage(outMsgEncoded);
  }

  _disarm(entity) {
    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": entity.entityId.split('.').first,
      "service": "alarm_disarm",
      "service_data": {"entity_id": entity.entityId, "code": output}
    };

    var outMsgEncoded = json.encode(outMsg);
    gd.sendSocketMessage(outMsgEncoded);
  }

  buttonPressed(String text) {
    if (text != "") {
      output += text;
    }

    if (output.length > keyCodeLength) {
      output = output.substring(1, keyCodeLength + 1);
    }

    if (output.length == keyCodeLength) {
      var entity = gd.entities[widget.entityId];
      if (entity.state == "disarmed") {
        _arm(entity);
      } else {
        _disarm(entity);
      }
    }
  }

  String _getStateText(entity) {
    if (entity.state == "disarmed") {
      return Translate.getString("alarm_panel.disarmed", context);
    } else if (entity.state == "pending") {
      return Translate.getString("alarm_panel.pending", context);
    } else if (entity.state == "armed_away") {
      return Translate.getString("alarm_panel.armed_away", context);
    } else if (entity.state == "armed_home") {
      return Translate.getString("alarm_panel.armed_home", context);
    } else if (entity.state == "armed_night") {
      return Translate.getString("alarm_panel.armed_night", context);
    } else {
      return Translate.getString("alarm_panel.armed", context);
    }
  }

  Widget alarmSelectionButton(String text, String armType) {
    log.d(
        "text $text armType $armType gd.deviceSetting.lastArmType ${gd.deviceSetting.lastArmType}");
    Color getColor() {
      return gd.deviceSetting.lastArmType == armType
          ? Theme.of(context).textTheme.body1.color
          : Theme.of(context).textTheme.body1.color.withOpacity(0.25);
    }

    return Container(
        height: 50,
        width: 80,
        decoration: BoxDecoration(
          color: gd.deviceSetting.lastArmType == armType
              ? Theme.of(context).textTheme.body1.color.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: EdgeInsets.all(8),
        child: OutlineButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(8.0),
          ),
          child: AutoSizeText(
            text,
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              color: getColor(),
              height: 1.0,
            ),
            maxLines: 3,
            textAlign: TextAlign.center,
            textScaleFactor: gd.textScaleFactorFix,
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: () => {
            setState(() {
              if (gd.deviceSetting.lastArmType != armType) {
                gd.deviceSetting.lastArmType = armType;
                gd.deviceSettingSave();
              }
            })
          },
        ));
  }

  Widget alarmButton(String buttonText) {
    return Container(
      height: 50,
      width: 80,
      margin: EdgeInsets.all(8),
      child: new OutlineButton(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(8.0),
        ),
        child: new Text(
          buttonText,
          style: TextStyle(
              fontSize: buttonText.length > 2 ? 15.0 : 20.0,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        onPressed: () => buttonPressed(buttonText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[widget.entityId].state}" +
          "${generalData.entities[widget.entityId].getFriendlyName}" +
          "${generalData.entities[widget.entityId].getOverrideIcon}",
      builder: (context, data, child) {
        var entity = gd.entities[widget.entityId];
        _readableState = _getStateText(entity);
        Color alarmColor = Colors.red;
        String alarmIcon = "mdi:shield-lock";
        if (entity.state == "disarmed") {
          alarmColor = Colors.green;
          alarmIcon = "mdi:shield-check";
        } else if (entity.state == "pending") {
          alarmColor = ThemeInfo.colorIconActive;
          alarmIcon = "mdi:shield-outline";
        }

        return new Container(
          child: new Column(
            children: <Widget>[
              Spacer(),
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: BorderSide(
                        width: 2,
                        color: alarmColor,
                      ),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.center,
                      child: Icon(
                        MaterialDesignIcons.getIconDataFromIconName(alarmIcon),
                        size: 50,
                        color: alarmColor,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: alarmColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: new Container(
                      padding: new EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 5,
                      ),
                      child: AutoSizeText(
                        _readableState.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                        textScaleFactor: gd.textScaleFactorFix,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
//              new Container(
//                alignment: Alignment.center,
//                padding:
//                    new EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
//                child: new Text(output,
//                    style: new TextStyle(
//                        fontSize: 36.0, fontWeight: FontWeight.bold)),
//              ),
              SizedBox(height: 20),

              Column(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      alarmButton("1"),
                      alarmButton("2"),
                      alarmButton("3")
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      alarmButton("4"),
                      alarmButton("5"),
                      alarmButton("6")
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      alarmButton("7"),
                      alarmButton("8"),
                      alarmButton("9")
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      alarmSelectionButton(
                          Translate.getString("alarm_panel.arm_home", context),
                          "arm_home"),
                      alarmButton("0"),
                      alarmSelectionButton(
                          Translate.getString("alarm_panel.arm_away", context),
                          "arm_away")
                    ],
                  )
                ],
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }
}
