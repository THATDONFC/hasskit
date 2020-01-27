import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/helper/web_socket.dart';
import 'package:share/share.dart';
import 'package:intl/intl.dart';

class BackupRestore extends StatelessWidget {
  Future<String> _asyncInputDialog(BuildContext context) async {
    String backupData = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Backup Data'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Backup Data',
                    hintText: 'Paste Backup Data Here',
                  ),
                  onChanged: (value) {
                    backupData = value;
                  },
                ),
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(backupData);
              },
            ),
            FlatButton(
              child: Text('Restore'),
              onPressed: () {
                var backupDatas = backupData.split("_hasskit_backup_data_");
                print("backupDatas.length ${backupDatas.length}");
//                for (backupData in backupDatas) {
//                  print("\n\nbackupData $backupData");
//                }

                if (backupDatas.length != 7 ||
                    backupDatas[1] == null ||
                    backupDatas[1].length < 10) {
                  Fluttertoast.showToast(
                      msg: "Invalid Data",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
                      textColor: Theme.of(context).textTheme.title.color,
                      fontSize: 14.0);
                } else {
                  try {
                    String url = backupDatas[0];
                    gd.saveString('loginDataList', backupDatas[1]);
                    gd.saveString('entitiesOverride', backupDatas[2]);
                    gd.saveString('deviceSetting $url', backupDatas[3]);
                    gd.saveString('roomList $url', backupDatas[4]);
                    gd.saveString('settingMobileApp $url', backupDatas[6]);

                    gd.loginDataListString = "";
                    gd.loginDataListString = backupDatas[1];
                    webSocket.initCommunication();

                    Fluttertoast.showToast(
                        msg: "Restore Backup Success\n${backupDatas[5]}",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        backgroundColor:
                            ThemeInfo.colorIconActive.withOpacity(1),
                        textColor: Theme.of(context).textTheme.title.color,
                        fontSize: 14.0);
                  } catch (e) {
                    Fluttertoast.showToast(
                        msg: "Restore Backup Error\n${backupDatas[5]}\n$e",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        backgroundColor:
                            ThemeInfo.colorIconActive.withOpacity(1),
                        textColor: Theme.of(context).textTheme.title.color,
                        fontSize: 14.0);
                  }
                }
                Navigator.of(context).pop(backupData);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var dateFormat =
        DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now().toLocal());
    String subject = "HassKit Backup Server: ${gd.currentUrl} - $dateFormat";
    String url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
    url = url.replaceAll("/", "-");
    url = url.replaceAll(":", "-");
    String loginDataList = json.encode(gd.loginDataList);
    String entitiesOverride = json.encode(gd.entitiesOverride);
    String deviceSetting = json.encode(gd.deviceSetting);
    String settingMobileApp = json.encode(gd.settingMobileApp);
    String roomList = json.encode(gd.roomList);
    String shareContent = "$url"
        "_hasskit_backup_data_$loginDataList"
        "_hasskit_backup_data_$entitiesOverride"
        "_hasskit_backup_data_$deviceSetting"
        "_hasskit_backup_data_$roomList"
        "_hasskit_backup_data_${gd.currentUrl}"
        "_hasskit_backup_data_$settingMobileApp";

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(width: 8),
                Expanded(
                  child: RaisedButton(
                    elevation: 1,
                    onPressed: () {
                      Share.share(shareContent, subject: subject);
                    },
                    child: Text(
                      "Backup",
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: RaisedButton(
                    elevation: 1,
                    onPressed: () async {
                      final String currentBackupData =
                          await _asyncInputDialog(context);
                      print("Current backup data is $currentBackupData");
                    },
                    child: Text(
                      "Restore",
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
