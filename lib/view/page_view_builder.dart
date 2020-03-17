import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'roomview/view_normal.dart';
import 'roomview/view_sort.dart';
import 'default_page.dart';
import 'package:provider/provider.dart';
import 'roomview/view_edit.dart';

class PageViewBuilder extends StatelessWidget {
  final PageController controller =
      PageController(initialPage: 0, keepPage: true, viewportFraction: 1);
  @override
  Widget build(BuildContext context) {
//    log.w("Widget build RoomsPage");
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.webSocketConnectionStatus} |" +
          "${generalData.lastLifecycleState} |" +
          "${generalData.roomList.length} |",
      builder: (context, data, child) {
        gd.pageController = controller;
        return gd.roomList != null && gd.roomList.length > 0
            ? PageView.builder(
                controller: controller,
                onPageChanged: (int) {
                  gd.viewMode = ViewMode.normal;
                  gd.lastSelectedRoom = int;
                },
                itemBuilder: (context, position) {
                  try {
                    return SinglePage(roomIndex: position + 1);
                  } catch (e) {
                    return DefaultPage(error: e.toString());
                  }
                },
                itemCount: gd.roomListLength)
            : PageView.builder(
                controller: controller,
                onPageChanged: (val) {
                  gd.lastSelectedRoom = val;
                },
                itemBuilder: (context, position) {
                  return SinglePage(roomIndex: 0);
                },
                itemCount: 1);
      },
    );
  }
}

class SinglePage extends StatelessWidget {
  final int roomIndex;

  const SinglePage({@required this.roomIndex});

  @override
  Widget build(BuildContext context) {
//    log.w("Widget build HomePage");

    if (gd.roomList == null || gd.roomList.length < 1) {
      return DefaultPage(error: "..HassKit..");
    }

    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.connectivityStatus} |" +
          "${generalData.autoConnect} |" +
          "${generalData.showSpin} |" +
          "${generalData.loginDataCurrent.url} |" +
          "${generalData.viewMode} |" +
          "${generalData.mediaQueryOrientation} |" +
          "${generalData.deviceSetting.settingLocked} |" +
          "${generalData.deviceSetting.phoneLayout} |" +
          "${generalData.deviceSetting.tabletLayout} |" +
          "${generalData.deviceSetting.shapeLayout} |" +
          "${generalData.mediaQueryHeight} |" +
          "${generalData.roomList.length} |" +
          "${generalData.entities.length} |" +
          "${generalData.baseSetting.notificationDevices.length} |" +
          "${generalData.roomList[roomIndex].name} |" +
          "${generalData.roomList[roomIndex].tempEntityId} |" +
          "${generalData.roomList[roomIndex].imageIndex} |" +
          "${generalData.roomList[roomIndex].row1Name} |" +
          "${generalData.roomList[roomIndex].row2Name} |" +
          "${generalData.roomList[roomIndex].row3Name} |" +
          "${generalData.roomList[roomIndex].row4Name} |" +
          "${generalData.roomList[roomIndex].row1.toList()} |" +
          "${generalData.roomList[roomIndex].row2.toList()} |" +
          "${generalData.roomList[roomIndex].row3.toList()} |" +
          "${generalData.roomList[roomIndex].row4.toList()} |",
      builder: (context, data, child) {
        Widget widget;

        if (gd.connectivityStatus == "ConnectivityResult.none") {
          widget = Container(
            constraints: BoxConstraints.expand(),
            color: ThemeInfo.colorBackgroundDark,
            child: Opacity(
              opacity: 0.5,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    MaterialDesignIcons.getIconDataFromIconName(
                        "mdi:home-assistant"),
                    size: 150,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Internet Access",
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Make sure you have Wifi",
//                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "or Mobile Data turned on",
//                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        } else if (gd.autoConnect && gd.showSpin) {
          widget = Container(
            constraints: BoxConstraints.expand(),
            color: ThemeInfo.colorBackgroundDark,
            child: Opacity(
              opacity: 0.5,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    MaterialDesignIcons.getIconDataFromIconName(
                        "mdi:home-assistant"),
                    size: 150,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Connecting...",
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${gd.loginDataCurrent.url}",
//                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${gd.webSocketConnectionStatus}",
//                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  SpinKitThreeBounce(
                    size: 40,
                    color: ThemeInfo.colorIconActive.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          );
        } else if (gd.viewMode == ViewMode.edit) {
          widget = ViewEdit(roomIndex: roomIndex);
        } else if (gd.viewMode == ViewMode.sort) {
          widget = ViewSort(roomIndex: roomIndex);
        } else {
          widget = ViewNormal(roomIndex: roomIndex);
        }

        ImageProvider backgroundImage;
        String imageUrl = gd.getRoomBackgroundPhoto(roomIndex);
        print("getRoomBackgroundPhoto $imageUrl");
        if (imageUrl != null && gd.fileExists(imageUrl)) {
          backgroundImage = FileImage(File(imageUrl));
          print("FileImage $backgroundImage");
        } else {
          backgroundImage =
              AssetImage(gd.backgroundImage[gd.roomList[roomIndex].imageIndex]);
          print("AssetImage $backgroundImage");
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          child: widget,
        );
      },
    );
  }
}
