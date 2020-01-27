import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/sensor.dart';
import 'package:hasskit/helper/sensor_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:hasskit/helper/locale_helper.dart';

class EntityControlSensor extends StatefulWidget {
  final String entityId;

  const EntityControlSensor({@required this.entityId});

  @override
  _EntityControlSensorState createState() => _EntityControlSensorState();
}

class _EntityControlSensorState extends State<EntityControlSensor> {
  bool inAsyncCall = true;
  double stateMin;
  double stateMax;
  List<FlSpot> flSpotsYesterday = [];
  List<FlSpot> flSpotsToday = [];
  @override
  void initState() {
    super.initState();
    getHistory();
  }

  @override
  Widget build(BuildContext context) {
    Widget displayWidgetYesterday;
    Widget displayWidgetToday;
    if (inAsyncCall) {
      displayWidgetYesterday = Container();
      displayWidgetToday = Container();
    } else if (gd.sensors.length < 1) {
      displayWidgetYesterday = Container(
        child: Center(
          child: Text(
              "${gd.textToDisplay(gd.entities[widget.entityId].getOverrideName)} ${Translate.getString('global.no_data', context)} ${gd.sensors.length}"),
        ),
      );
      displayWidgetToday = Container();
    } else if (gd.sensors.length < 4) {
      displayWidgetYesterday = SensorLowNumber();
      displayWidgetToday = Container();
    } else {
      displayWidgetYesterday = SensorChart(
        stateMin: stateMin,
        stateMax: stateMax,
        title: DateFormat("EEEE, dd MMMM")
            .format(DateTime.now().subtract(Duration(days: 1))),
        flSpots: flSpotsYesterday,
      );
      displayWidgetToday = SensorChart(
        stateMin: stateMin,
        stateMax: stateMax,
        title:
            "${DateFormat("EEEE, dd MMMM").format(DateTime.now())} | ${gd.textToDisplay(gd.entities[widget.entityId].getStateDisplay)} ${gd.textToDisplay(gd.entities[widget.entityId].unitOfMeasurement)}",
        flSpots: flSpotsToday,
      );
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      width: gd.mediaQueryWidth,
      child: ModalProgressHUD(
        inAsyncCall: inAsyncCall,
        opacity: 0,
        progressIndicator: SpinKitThreeBounce(
          size: 40,
          color: ThemeInfo.colorIconActive.withOpacity(0.5),
        ),
        child: !gd.isTablet ||
                MediaQuery.of(context).orientation != Orientation.landscape
            ? Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        child: displayWidgetYesterday),
                  ),
                  SizedBox(
                    width: 8,
                    height: 8,
                  ),
                  Expanded(
                    child: Container(
                        alignment: Alignment.topCenter,
                        child: displayWidgetToday),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        alignment: Alignment.centerRight,
                        child: displayWidgetYesterday),
                  ),
                  SizedBox(
                    width: 8,
                    height: 8,
                  ),
                  Expanded(
                    child: Container(
                        alignment: Alignment.centerLeft,
                        child: displayWidgetToday),
                  ),
                ],
              ),
      ),
    );
  }

  void getHistory() async {
    var client = new http.Client();

    var timeZoneOffset = DateTime.now().timeZoneOffset;
    var timeZoneOffsetHour =
        timeZoneOffset.inHours.toInt().abs().toString().padLeft(2, '0');
    var timeZoneOffsetMinute =
        ((timeZoneOffset - Duration(hours: timeZoneOffset.inHours.toInt()))
                .inMinutes)
            .toString()
            .padLeft(2, '0');
    var timeZoneOffsetString = timeZoneOffsetHour + ":" + timeZoneOffsetMinute;
    if (timeZoneOffset.isNegative) {
      timeZoneOffsetString = "-" + timeZoneOffsetString;
    } else {
      timeZoneOffsetString = "+" + timeZoneOffsetString;
    }
    print("timeZoneOffset $timeZoneOffset");
    print("timeZoneOffsetHour $timeZoneOffsetHour");
    print("timeZoneOffsetMinute $timeZoneOffsetMinute");
    print("timeZoneOffsetString $timeZoneOffsetString");

    var startPeriod = DateTime.now().subtract(Duration(hours: 24));
    startPeriod = startPeriod.subtract(Duration(hours: DateTime.now().hour));
    startPeriod =
        startPeriod.subtract(Duration(minutes: DateTime.now().minute));
    startPeriod =
        startPeriod.subtract(Duration(seconds: DateTime.now().second));

    var startPeriodString =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startPeriod);
    startPeriodString = startPeriodString + timeZoneOffsetString;
    print("startPeriodString $startPeriodString");

    var endPeriodString = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
        .format(startPeriod.add(Duration(minutes: 2879)));
    endPeriodString = endPeriodString + timeZoneOffsetString;
    print("endPeriodString $endPeriodString");
    endPeriodString = Uri.encodeComponent(endPeriodString);

    var url = gd.currentUrl +
        "/api/history/period/$startPeriodString"
            "?"
            "end_time=$endPeriodString"
            "&"
            "filter_entity_id=${widget.entityId}"
            "";
    Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ${gd.loginDataCurrent.longToken}',
    };

    log.d("url $url");

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
//        log.w("response.statusCode ${response.statusCode}");
        var jsonResponse = jsonDecode(response.body);
        log.d("getHistory jsonResponse $jsonResponse");
        gd.sensors = [];
        for (var rec in jsonResponse[0]) {
          var sensor = Sensor.fromJson(rec);

          var lastUpdated = DateTime.tryParse(sensor.lastUpdated);
          if (lastUpdated == null) {
            continue;
          }
          var lastChanged = DateTime.tryParse(sensor.lastChanged);
          if (lastChanged == null) {
            continue;
          }
          var state = double.tryParse(sensor.state);
          if (state == null) {
            continue;
          }

          gd.sensors.add(sensor);

          if (stateMin == null) stateMin = state;
          if (stateMax == null) stateMax = state;
          if (state > stateMax) stateMax = state;
          if (state < stateMin) stateMin = state;
        }

        gd.sensors.sort((a, b) => DateTime.parse(a.lastUpdated)
            .toLocal()
            .compareTo(DateTime.parse(b.lastUpdated).toLocal()));

        processTable();

        if (stateMin != null && stateMax != null) {
          var range = (stateMax - stateMin).abs();
          var borderNumber;
          range == 0 ? borderNumber = 1 : borderNumber = range * 0.1;
          stateMin = stateMin - borderNumber;
          stateMax = stateMax + borderNumber;
          log.d(
              "stateMin $stateMin stateMax $stateMax borderNumber $borderNumber");
        }

        setState(() {
          inAsyncCall = false;
        });
      } else {
        setState(() {
          inAsyncCall = false;
        });
        log.e("Request failed with status: ${response.statusCode}.");
      }
    } finally {
      setState(() {
        inAsyncCall = false;
      });
      client.close();
    }
  }

  void processTable() {
    log.d("processTable");

//    var now = DateTime.now().toLocal().millisecondsSinceEpoch.toDouble();
//    var now24 = DateTime.now()
//        .toLocal()
//        .subtract(Duration(hours: 24))
//        .millisecondsSinceEpoch
//        .toDouble();

    trimData();

    var startPeriod = DateTime.now().subtract(Duration(hours: 24));
    startPeriod = startPeriod.subtract(Duration(hours: DateTime.now().hour));
    startPeriod =
        startPeriod.subtract(Duration(minutes: DateTime.now().minute));
    startPeriod =
        startPeriod.subtract(Duration(seconds: DateTime.now().second));

    double startPeriodEpoch = startPeriod.millisecondsSinceEpoch.toDouble();
    double startTodayEpoch =
        startPeriod.add(Duration(days: 1)).millisecondsSinceEpoch.toDouble();
    double endTodayEpoch =
        startPeriod.add(Duration(days: 2)).millisecondsSinceEpoch.toDouble();

//    log.d(
//        "startPeriodEpoch $startPeriodEpoch startTodayEpoch $startTodayEpoch endTodayEpoch $endTodayEpoch");

    for (int i = 0; i < gd.sensors.length; i++) {
      var lastChanged = DateTime.tryParse(gd.sensors[i].lastChanged)
          .toLocal()
          .millisecondsSinceEpoch
          .toDouble();

      if (lastChanged == null) {
        log.e("Can't parse lastChanged ${gd.sensors[i].lastUpdated}");
        continue;
      }
      var state = double.tryParse(gd.sensors[i].state);
      if (lastChanged == null) {
        log.e("Can't parse state ${gd.sensors[i].state}");
        continue;
      }

      if (lastChanged < startTodayEpoch) {
        var lastChangedMapped =
            gd.mapNumber(lastChanged, startPeriodEpoch, startTodayEpoch, 0, 24);
//        log.d("flSpotsYesterday add $lastChangedMapped - $state");
        flSpotsYesterday.add(FlSpot(lastChangedMapped, state));
      } else {
        var lastChangedMapped =
            gd.mapNumber(lastChanged, startTodayEpoch, endTodayEpoch, 0, 24);
//        log.d("flSpotsToday add $lastChangedMapped - $state");
        flSpotsToday.add(FlSpot(lastChangedMapped, state));
      }
    }

    if (flSpotsYesterday.length < 1) {
      flSpotsYesterday.add(FlSpot(0, 0));
    }

    if (flSpotsToday.length < 1) {
      flSpotsToday.add(FlSpot(0, 0));
    }
  }

  void trimData() {
    log.d("trimData before ${gd.sensors.length}");
    List<Sensor> trimData = [];
    var overPopulate = gd.sensors.length ~/ 96;
    if (overPopulate > 1) {
      for (int i = 0; i < gd.sensors.length; i++) {
        if (i % overPopulate == 0) {
          trimData.add(gd.sensors[i]);
        }
      }
      log.d("trimData after ${trimData.length}");
      gd.sensors = trimData;
    }
  }
}

class SensorLowNumber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < gd.sensors.length; i++) {
      var lastUpdated = DateTime.parse(gd.sensors[i].lastUpdated).toUtc();

      var widget = Container(
          height: 40,
          child: Text(DateFormat('dd-MMM kk:mm:ss').format(lastUpdated) +
              " - " +
              gd.sensors[i].state));
      widgets.add(widget);
    }

    return Column(
      children: widgets,
    );
  }
}
