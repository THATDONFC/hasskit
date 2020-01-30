import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingMobileApp {
  String deviceName = "";
  String cloudHookUrl = "";
  String remoteUiUrl = "";
  String secret = "";
  String webHookId = "";
  bool trackLocation = false;

  SettingMobileApp({
    @required this.deviceName,
    @required this.cloudHookUrl,
    @required this.remoteUiUrl,
    @required this.secret,
    @required this.webHookId,
    @required this.trackLocation,
  });

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'cloudhook_url': cloudHookUrl,
        'cloudhook_url': remoteUiUrl,
        'secret': secret,
        'webhook_id': webHookId,
        'trackLocation': trackLocation,
      };

  factory SettingMobileApp.fromJson(Map<String, dynamic> json) {
    return SettingMobileApp(
      deviceName: json['deviceName'] != null ? json['deviceName'] : "",
      cloudHookUrl: json['cloudhook_url'] != null ? json['cloudhook_url'] : "",
      remoteUiUrl: json['remote_ui_url'] != null ? json['remote_ui_url'] : "",
      secret: json['secret'] != null ? json['secret'] : "",
      webHookId: json['webhook_id'] != null ? json['webhook_id'] : "",
      trackLocation:
          json['trackLocation'] != null ? json['trackLocation'] : false,
    );
  }
}

class SettingMobileAppRegistration extends StatefulWidget {
  @override
  _SettingMobileAppRegistrationState createState() =>
      _SettingMobileAppRegistrationState();
}

class _SettingMobileAppRegistrationState
    extends State<SettingMobileAppRegistration> {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "HassKit created a Mobile App component in Home Assistant to enable push notification.",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.justify,
                  textScaleFactor: gd.textScaleFactorFix,
                ),
                SizedBox(height: 8),
                Divider(
                  height: 8,
                ),
                Text(
                  "${gd.settingMobileApp.deviceName}",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.justify,
                  textScaleFactor: gd.textScaleFactorFix,
                ),
                Divider(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
//                    FlatButton(
//                      child: Text(
//                        "Open App Settings",
//                        style: Theme.of(context)
//                            .textTheme
//                            .button
//                            .copyWith(color: ThemeInfo.colorIconActive),
//                      ),
//                      onPressed: () {
//                        LocationPermissions().openAppSettings();
//                      },
//                    ),
                    Expanded(
                      child: Text(
                        "To enable Push Notification, please read the Setup Guide",
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.justify,
                        textScaleFactor: gd.textScaleFactorFix,
                      ),
                    ),
                    FlatButton(
                      child: Text(
                        "Setup Guide",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: ThemeInfo.colorIconActive),
                      ),
                      onPressed: () {
                        _launchMobileAppGuide();
                      },
                    ),
                  ],
                ),
//                Divider(
//                  height: 1,
//                ),
//                Row(
//                  children: <Widget>[
//                    Switch.adaptive(
//                      value: gd.settingMobileApp.webHookId != ""
//                          ? gd.settingMobileApp.trackLocation
//                          : false,
//                      onChanged: gd.settingMobileApp.webHookId != ""
//                          ? (val) {
//                              setState(
//                                () {
//                                  gd.settingMobileApp.trackLocation = val;
//                                  print(
//                                      "onChanged $val gd.deviceIntegration.trackLocation ${gd.settingMobileApp.trackLocation}");
//                                  if (val == true) {
//                                    if (gd.settingMobileApp.webHookId != "") {
//                                      gd.locationUpdateTime = DateTime.now()
//                                          .subtract(Duration(days: 1));
////                                      GeoLocatorHelper.updateLocation(
////                                          "Switch.adaptive");
//                                    }
//                                  } else {
//                                    gd.locationLatitude = 51.48;
//                                    gd.locationLongitude = 0.0;
//                                  }
//                                  gd.settingMobileAppSave();
//                                },
//                              );
//                            }
//                          : null,
//                    ),
//                    Expanded(
//                      child: Text(
//                        gd.settingMobileApp.trackLocation
//                            ? "Location Tracking Enabled"
//                                "\n${gd.textToDisplay(gd.mobileAppState)}"
//                            : "Location Tracking Disabled",
//                        style: Theme.of(context).textTheme.caption,
//                        textAlign: TextAlign.justify,
//                        textScaleFactor: gd.textScaleFactorFix,
//                      ),
//                    ),
//                  ],
//                ),
//                ExpandableNotifier(
//                  child: ScrollOnExpand(
//                    child: Column(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          children: <Widget>[
//                            Builder(
//                              builder: (context) {
//                                var controller =
//                                    ExpandableController.of(context);
//                                return FlatButton(
//                                  child: Text(
//                                    controller.expanded
//                                        ? "Hide Advance Settings"
//                                        : "Show Advance Settings",
//                                    style: Theme.of(context)
//                                        .textTheme
//                                        .button
//                                        .copyWith(
//                                            color: ThemeInfo.colorIconActive),
//                                  ),
//                                  onPressed: () {
//                                    controller.toggle();
//                                  },
//                                );
//                              },
//                            ),
//                          ],
//                        ),
//                        Expandable(
//                          collapsed: null,
//                          expanded: Row(
//                            children: <Widget>[
//                              SizedBox(width: 24),
//                              Text(
//                                  "Update Interval: ${gd.locationUpdateInterval} minutes")
//                            ],
//                          ),
//                        ),
//                        Expandable(
//                          collapsed: null,
//                          expanded: Slider(
//                            value: gd.locationUpdateInterval.toDouble(),
//                            onChanged: (val) {
//                              setState(() {
//                                gd.locationUpdateInterval = val.toInt();
//                              });
//                            },
//                            min: 1,
//                            max: 30,
//                          ),
//                        ),
//                        Expandable(
//                          collapsed: null,
//                          expanded: Row(
//                            children: <Widget>[
//                              SizedBox(width: 24),
//                              Text(
//                                  "Min Distance Change: ${(gd.locationUpdateMinDistance * 1000).toInt()} meters")
//                            ],
//                          ),
//                        ),
//                        Expandable(
//                          collapsed: null,
//                          expanded: Slider(
//                            value: gd.locationUpdateMinDistance,
//                            onChanged: (val) {
//                              setState(() {
//                                gd.locationUpdateMinDistance = val;
//                              });
//                            },
//                            min: 0.05,
//                            max: 0.5,
//                            divisions: 45,
//                          ),
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//                Text(
//                    "Debug: trackLocation ${gd.settingMobileApp.trackLocation}\n\n"
//                    "deviceName ${gd.settingMobileApp.deviceName}\n\n"
//                    "webHookId ${gd.settingMobileApp.webHookId}\n\n"
//                    "${gd.locationUpdateFail}\n\n"
//                    "${gd.locationUpdateSuccess}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _launchMobileAppGuide() async {
    const url =
        'https://github.com/tuanha2000vn/hasskit/blob/master/mobile_app.md';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
