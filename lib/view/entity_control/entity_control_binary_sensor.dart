import 'dart:convert';

import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/squircle_border.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/sensor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EntityControlBinarySensor extends StatefulWidget {
  final String entityId;
  final bool horizontalMode;
  const EntityControlBinarySensor({
    @required this.entityId,
    this.horizontalMode = false,
  });

  @override
  _EntityControlBinarySensorState createState() =>
      _EntityControlBinarySensorState();
}

class _EntityControlBinarySensorState extends State<EntityControlBinarySensor> {
  String deviceClass;
  bool inAsyncCall = true;
  String lastState;

  @override
  void initState() {
    print("_EntityControlBinarySensorState initState");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (lastState != gd.entities[widget.entityId].state) {
      getHistory();
    }
//    print("_EntityControlBinarySensorState build");
    List<Sensor> binarySensorsReversed = [];
    for (int i = gd.sensors.length - 1; i > 0; i--) {
      if (gd.sensors[i - 1] == null ||
          gd.sensors[i - 1].isStateOn == null ||
          gd.sensors[i - 1].isStateOn != gd.sensors[i].isStateOn) {
        binarySensorsReversed.add(gd.sensors[i]);
      }
    }

//    log.d(
//        "gd.mediaQueryHeight ${gd.mediaQueryHeight} ${MediaQuery.of(context).padding.vertical} ${MediaQuery.of(context).padding.horizontal} kBottomNavigationBarHeight $kBottomNavigationBarHeight kToolbarHeight $kToolbarHeight");

    return Container(
      height: gd.mediaQueryHeight -
          kBottomNavigationBarHeight -
          kToolbarHeight -
          20,
      child: ModalProgressHUD(
        inAsyncCall: inAsyncCall,
        opacity: 0,
        progressIndicator: SpinKitThreeBounce(
          size: 40,
          color: ThemeInfo.colorIconActive.withOpacity(0.5),
        ),
        child: inAsyncCall
            ? Container()
            : !widget.horizontalMode
                ? ListView.builder(
                    itemCount: binarySensorsReversed.length,
                    itemBuilder: (BuildContext context, int index) {
                      var rec = binarySensorsReversed[index];
                      var changedTime =
                          DateTime.parse(rec.lastChanged).toLocal();
                      var formattedChangedTime =
                          DateFormat('kk:mm:ss').format(changedTime);
                      var timeDiff = DateTime.now()
                          .difference(DateTime.parse(rec.lastChanged));
                      Duration duration;

                      if (!rec.isStateOn &&
                          index + 1 < binarySensorsReversed.length &&
                          binarySensorsReversed[index + 1] != null &&
                          binarySensorsReversed[index + 1].isStateOn) {
                        var date1 = DateTime.parse(rec.lastChanged);
                        var date2 = DateTime.parse(
                            binarySensorsReversed[index + 1].lastChanged);
                        duration = date1.difference(date2);
                      }

                      return Stack(
                        alignment: rec.isStateOn
                            ? Alignment.topLeft
                            : Alignment.bottomLeft,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 33),
                            color: ThemeInfo.colorIconActive,
                            width: 2,
                            height: 5,
                          ),
                          Container(
                            height: 50,
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 14),
                                Material(
                                  color: rec.isStateOn
                                      ? ThemeInfo.colorIconActive
                                          .withOpacity(0.25)
                                      : ThemeInfo.colorGray.withOpacity(0),
                                  shape: gd.deviceSetting.shapeLayout == 1
                                      ? SquircleBorder(
                                          side: BorderSide(
                                            color: ThemeInfo.colorIconActive,
                                            width: 1.0,
                                          ),
                                        )
                                      : RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: ThemeInfo.colorIconActive,
                                            width: 1.0,
                                          ),
                                        ),
//                                  shape: SquircleBorder(
//                                    side: BorderSide(
//                                      color: ThemeInfo.colorIconActive,
//                                      width: 1.0,
//                                    ),
//                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    alignment: Alignment.center,
                                    width: 40,
                                    height: 40,
                                    child: FittedBox(
                                      child: Text(
                                          "${stateString(deviceClass, binarySensorsReversed[index].isStateOn, context)}"),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '$formattedChangedTime',
                                  style: Theme.of(context).textTheme.subtitle,
                                  textScaleFactor: gd.textScaleFactorFix,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: rec.isStateOn
                                      ? Text(
                                          '${printDuration(timeDiff, abbreviated: false, tersity: DurationTersity.minute, spacer: ' ', delimiter: ' ', conjugation: ' and ')} ago',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle,
                                          textScaleFactor:
                                              gd.textScaleFactorFix,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : duration != null
                                          ? Text(
                                              "${Translate.getString("global.duration", context)}: ${printDuration(duration, abbreviated: true, tersity: DurationTersity.second, spacer: '', delimiter: ' ', conjugation: ' and ')}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle,
                                              textScaleFactor:
                                                  gd.textScaleFactorFix,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(""),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    itemCount: binarySensorsReversed.length,
                    itemBuilder: (BuildContext context, int index) {
                      var rec = binarySensorsReversed[index];
                      var changedTime =
                          DateTime.parse(rec.lastChanged).toLocal();
                      var formattedChangedTime =
                          DateFormat('kk:mm').format(changedTime);

                      if (!rec.isStateOn &&
                          index + 1 < binarySensorsReversed.length &&
                          binarySensorsReversed[index + 1] != null &&
                          binarySensorsReversed[index + 1].isStateOn) {}

                      return Stack(
                        alignment: rec.isStateOn
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        children: <Widget>[
//                          Container(
//                            width: 5,
//                            height: 2,
//                            color: ThemeInfo.colorIconActive,
//                          ),
                          Container(
                            alignment: rec.isStateOn
                                ? Alignment.center
                                : Alignment.center,
                            width: 50,
                            margin: rec.isStateOn
                                ? EdgeInsets.only(left: 8, right: 0)
                                : EdgeInsets.only(left: 0, right: 8),
                            padding: rec.isStateOn
                                ? EdgeInsets.all(2)
                                : EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: rec.isStateOn
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(80),
                                      bottomLeft: Radius.circular(80),
                                    )
                                  : BorderRadius.only(
                                      topRight: Radius.circular(80),
                                      bottomRight: Radius.circular(80),
                                    ),
                              color: rec.isStateOn
                                  ? ThemeInfo.colorIconActive.withOpacity(0.25)
                                  : ThemeInfo.colorGray.withOpacity(0),
                              border: Border.all(
                                color: ThemeInfo.colorIconActive.withOpacity(1),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              "$formattedChangedTime",
                              maxLines: 1,
                              textScaleFactor: gd.textScaleFactorFix,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }

  void getHistory() async {
//    log.d("getHistory Start");
    await Future.delayed(const Duration(milliseconds: 500));
    var client = new http.Client();
    var url = gd.currentUrl +
        "/api/history/period?filter_entity_id=${widget.entityId}";
    Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ${gd.loginDataCurrent.longToken}',
    };

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
//        log.w("response.statusCode ${response.statusCode}");
        var jsonResponse = jsonDecode(response.body);
        gd.sensors = [];

        int i = 0;
        for (var rec in jsonResponse[0]) {
          var binarySensor = Sensor.fromJson(rec);
          gd.sensors.add(binarySensor);
          i++;
        }

        if (i > 0 && jsonResponse[0][i - 1] != null) {
          deviceClass =
              (jsonResponse[0][i - 1]["attributes"]["device_class"]).toString();
          if ((jsonResponse[0][i - 1]["state"] == "locked" ||
              jsonResponse[0][i - 1]["state"] == "unlocked")) {
            deviceClass = "lock";
          }
        }
//        setState(() {
        inAsyncCall = false;
//        });
      } else {
//        setState(() {
        inAsyncCall = false;
//        });
        log.e("Request failed with status: ${response.statusCode}.");
      }
    } catch (e) {
      inAsyncCall = false;
      log.e("getHistory $e");
    } finally {
      if (mounted) {
        setState(() {
//        log.d("getHistory finally");
          inAsyncCall = false;
          lastState = gd.entities[widget.entityId].state;
        });
      }
      client.close();
    }
  }
}

String stateString(String deviceClass, bool isStateOn, BuildContext context) {
//  log.d("stateString deviceClass $deviceClass isStateOn $isStateOn");
  if (deviceClass.contains("garage_door") ||
      deviceClass.contains("door") ||
      deviceClass.contains("lock") ||
      deviceClass.contains("opening") ||
      deviceClass.contains("window")) {
    if (isStateOn) {
      return Translate.getString("global.open", context);
    }

    return Translate.getString("global.closed", context);
  }

  if (isStateOn) {
    return Translate.getString("global.on", context);
  }

  return Translate.getString("global.off", context);
}
