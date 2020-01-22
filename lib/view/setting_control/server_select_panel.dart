import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/helper/web_socket.dart';
import 'package:hasskit/model/login_data.dart';

class ServerSelectPanel extends StatelessWidget {
  final LoginData loginData;
  const ServerSelectPanel(this.loginData);
  @override
  Widget build(BuildContext context) {
//    log.w("Widget build ServerSelectPanel");
    List<Widget> secondaryWidgets;

    Widget deleteWidget = Container();

    if (loginData.url != "http://hasskit.duckdns.org:8123")
      deleteWidget = new IconSlideAction(
          caption: Translate.getString("edit.delete", context),
          color: Colors.transparent,
          icon: Icons.delete,
          onTap: () async {
            log.w("ServerSelectPanel Delete");
            gd.loginDataListDelete(loginData);
            gd.autoConnect = false;
            gd.currentUrl = "";
            if (gd.loginDataCurrent.getUrl == loginData.getUrl) {
              gd.loginDataCurrent.url = "";
              webSocket.reset();
              gd.roomListClear();
            }
          });

    if (gd.loginDataCurrent.getUrl == loginData.getUrl) {
      var disconnectWidget = IconSlideAction(
          caption: Translate.getString("global.disconnect", context),
          color: Colors.transparent,
          icon: MaterialDesignIcons.getIconDataFromIconName(
              "mdi:server-network-off"),
          onTap: () {
            log.w("ServerSelectPanel Disconnect");
            gd.autoConnect = false;
            gd.currentUrl = "";
            webSocket.reset();
            gd.roomListClear();
          });
      secondaryWidgets = [disconnectWidget, deleteWidget];
    } else {
      secondaryWidgets = [deleteWidget];
    }
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        onTap: () {
          log.d("log.d OnTap");
          print("print OnTap");
          debugPrint("debugPrint OnTap");
          if (gd.loginDataCurrent.getUrl == loginData.getUrl &&
              gd.webSocketConnectionStatus == "Connected") {
            Fluttertoast.showToast(
                msg: "Swipe Right to Refresh, Left to Disconnect/Delete Server",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
                textColor: Theme.of(context).textTheme.title.color,
                fontSize: 14.0);
          } else {
            Fluttertoast.showToast(
                msg: "Swipe Right to Connect, Left to Delete Server",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
                textColor: Theme.of(context).textTheme.title.color,
                fontSize: 14.0);
          }
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Card(
          margin: EdgeInsets.all(8),
          color: Theme.of(context).canvasColor.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                gd.loginDataCurrent.getUrl == loginData.getUrl &&
                        gd.webSocketConnectionStatus == "Connected"
                    ? Icon(
                        MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:server-network"),
                        color: Theme.of(context).toggleableActiveColor,
                      )
                    : Icon(
                        MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:server-network-off"),
                        color: Theme.of(context)
                            .toggleableActiveColor
                            .withOpacity(0.5),
                      ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(loginData.getUrl,
                          style: Theme.of(context).textTheme.subhead,
                          maxLines: 2,
                          textScaleFactor: gd.textScaleFactorFix,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          gd.loginDataCurrent.getUrl == loginData.getUrl
                              ? "Status: " +
                                  (gd.webSocketConnectionStatus == "Connected"
                                      ? Translate.getString(
                                          "global.connected", context)
                                      : Translate.getString(
                                          "global.disconnected", context))
                              : Translate.getString(
                                      "global.last_access", context) +
                                  ": ${loginData.timeSinceLastAccess}",
                          style: Theme.of(context).textTheme.body1,
                          maxLines: 5,
                          textScaleFactor: gd.textScaleFactorFix,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        (gd.loginDataCurrent.getUrl == loginData.getUrl &&
                gd.webSocketConnectionStatus == "Connected")
            ? IconSlideAction(
                caption: Translate.getString("global.refresh", context),
                color: Colors.transparent,
                icon:
                    MaterialDesignIcons.getIconDataFromIconName("mdi:refresh"),
                onTap: () {
                  gd.autoConnect = true;
                  webSocket.initCommunication();
                })
            : IconSlideAction(
                caption: Translate.getString("settings.connect", context),
                color: Colors.transparent,
                icon: MaterialDesignIcons.getIconDataFromIconName(
                    "mdi:server-network"),
                onTap: () {
                  gd.loginDataCurrent = loginData;
                  gd.autoConnect = true;
                  webSocket.initCommunication();
                }),
      ],
      secondaryActions: secondaryWidgets,
    );
  }
}
