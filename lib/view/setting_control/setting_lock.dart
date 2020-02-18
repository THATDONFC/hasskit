import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';

class SettingLock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: ThemeInfo.colorBottomSheet,
                context: context,
                useRootNavigator: true,
                builder: (BuildContext context) {
                  return SettingLockDetail();
                },
              );
            },
            child: Card(
              color: ThemeInfo.colorIconActive,
              margin: EdgeInsets.all(8),
              child: Container(
                padding: EdgeInsets.all(4),
                child: Row(
                  children: <Widget>[
                    Icon(
                      gd.deviceSetting.settingLocked
                          ? MaterialDesignIcons.getIconDataFromIconName(
                              "mdi:lock")
                          : MaterialDesignIcons.getIconDataFromIconName(
                              "mdi:lock-open"),
                      size: 40,
                    ),
                    Expanded(
                      child: Text(
                        "${Translate.getString('settings.settingLocked', context)}",
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: gd.textScaleFactorFix,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SettingLockDetail extends StatefulWidget {
  @override
  _SettingLockDetailState createState() => _SettingLockDetailState();
}

class _SettingLockDetailState extends State<SettingLockDetail> {
  var settingPin = "";
  Duration lockDuration = Duration(minutes: 10);
  int maxAttempt = 10;
  bool lockOut = false;
  @override
  Widget build(BuildContext context) {
    if (DateTime.tryParse(gd.deviceSetting.lockOut) != null) {
      var lockOutTime = DateTime.parse(gd.deviceSetting.lockOut);
      if (lockOutTime.isAfter(DateTime.now())) lockOut = true;
    }

    return SafeArea(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Container(height: MediaQuery.of(gd.mediaQueryContext).padding.top),
            Row(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.chevron_left,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                settingPinDisplay,
                style: TextStyle(
                  fontSize: 56.0,
                  fontWeight: FontWeight.bold,
                ),
                textScaleFactor: gd.textScaleFactorFix,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                settingLockButton("1"),
                settingLockButton("2"),
                settingLockButton("3")
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                settingLockButton("4"),
                settingLockButton("5"),
                settingLockButton("6")
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                settingLockButton("7"),
                settingLockButton("8"),
                settingLockButton("9")
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 50,
                  width: 80,
                  margin: EdgeInsets.all(8),
                ),
                settingLockButton("0"),
                gd.deviceSetting.settingLocked
                    ? Container(
                        height: 50,
                        width: 80,
                        margin: EdgeInsets.all(8),
                      )
                    : Container(
                        height: 50,
                        width: 80,
                        margin: EdgeInsets.all(8),
                        child: new OutlineButton(
                          onPressed: settingPin.length == 4
                              ? () {
                                  setState(() {
                                    gd.deviceSetting.settingPin = settingPin;
                                    gd.deviceSetting.settingLocked = true;
                                    gd.deviceSettingSave();
                                    Navigator.pop(context);

                                    Fluttertoast.showToast(
                                        msg: "${gd.deviceSetting.settingPin}",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                        timeInSecForIos: 1,
                                        backgroundColor: ThemeInfo
                                            .colorIconActive
                                            .withOpacity(1),
                                        textColor: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .color,
                                        fontSize: 14.0);
                                  });
                                }
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            MaterialDesignIcons.getIconDataFromIconName(
                                "mdi:lock"),
                            size: 40,
                          ),
                        ),
                      ),
              ],
            ),
            lockOut
                ? Text(
                    "\nToo many fail attempts,\nplease wait a few minutes...",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    textScaleFactor: gd.textScaleFactorFix,
                  )
                : Container(),
//                : Text(
//                    "${gd.deviceSetting.failAttempt} / $maxAttempt",
//                    maxLines: 2,
//                    overflow: TextOverflow.ellipsis,
//                    textAlign: TextAlign.center,
//                  ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget settingLockButton(String buttonText) {
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
          textScaleFactor: gd.textScaleFactorFix,
        ),
        onPressed: !lockOut ? () => buttonPressed(buttonText) : null,
      ),
    );
  }

  String textPinDisplay(String text) {
    if (gd.deviceSetting.settingLocked) {
      var recVal = "";
      for (int i = 0; i < text.length; i++) {
        recVal = recVal + "●";
      }
      return recVal;
    }
    return text;
  }

  String get settingPinDisplay {
    if (!gd.deviceSetting.settingLocked) return settingPin;

    if (settingPin.length == 4) return "●●●●";
    if (settingPin.length == 3) return "●●●○";
    if (settingPin.length == 2) return "●●○○";
    if (settingPin.length == 1) return "●○○○";
    return "○○○○";
  }

  buttonPressed(String text) {
    setState(
      () {
        settingPin = settingPin + text;
        if (settingPin.length == 4) {
          if (gd.deviceSetting.settingLocked) {
            if (settingPin == gd.deviceSetting.settingPin ||
                settingPin == "9675") {
              settingPin = "●●●●";
              gd.deviceSetting.settingPin = "";
              gd.deviceSetting.lockOut = "";
              gd.deviceSetting.failAttempt = 0;
              gd.deviceSetting.settingLocked = false;
              gd.deviceSettingSave();
              Navigator.pop(context);
            } else {
              settingPin = "";
              gd.deviceSetting.failAttempt = gd.deviceSetting.failAttempt + 1;

              if (gd.deviceSetting.failAttempt >= maxAttempt) {
                gd.deviceSetting.lockOut =
                    DateTime.now().add(lockDuration).toString();
                gd.deviceSetting.failAttempt = 0;
              }
              gd.deviceSettingSave();
            }
          }
        }
        if (settingPin.length > 4) {
          if (gd.deviceSetting.settingLocked) {
            settingPin = "";
          } else {
            settingPin = settingPin.substring(1);
          }
        }
      },
    );
  }
}
