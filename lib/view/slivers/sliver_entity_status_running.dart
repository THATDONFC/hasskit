import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/view/entity_control/entity_control_parent.dart';
import 'package:provider/provider.dart';

class SliverEntityStatusRunning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var buttonSize = (gd.mediaQueryWidth / gd.layoutButtonCount);

    if (gd.isTablet && gd.mediaQueryOrientation == Orientation.landscape) {
      buttonSize = gd.mediaQueryLongestSide / gd.layoutButtonCount;
    }

    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.activeDevicesShow} " +
          "${generalData.activeDevicesOn.length} ",
      builder: (context, data, child) {
        List<Widget> status2ndRowButtons = [];

        for (var entity in gd.activeDevicesOn) {
          status2ndRowButtons.add(Status2ndRowItem(
            entityId: entity.entityId,
            buttonSize: buttonSize,
          ));
        }
        return gd.activeDevicesShow && gd.activeDevicesOn.length > 0
            ? SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      height: buttonSize * 0.5,
                      margin: EdgeInsets.fromLTRB(10, 4, 10, 0),
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: status2ndRowButtons),
                    ),
                  ],
                ),
              )
            : SliverList(
                delegate: SliverChildListDelegate(
                  [],
                ),
              );
      },
    );
  }
}

class Status2ndRowItem extends StatelessWidget {
  const Status2ndRowItem({
    @required this.entityId,
    @required this.buttonSize,
  });

  final String entityId;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 8 / 5,
      child: InkWell(
        onTap: () {
          if (entityId.contains('alarm_control_panel.')) {
            showModalBottomSheet(
              context: context,
              elevation: 1,
              backgroundColor: ThemeInfo.colorBottomSheet,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (BuildContext context) {
                return EntityControlParent(entityId: entityId);
              },
            );
          } else {
            gd.toggleStatus(gd.entities[entityId]);
          }
          if (gd.activeDevicesOn.length <= 0) {
            gd.activeDevicesOffTimer(0);
          } else {
            gd.activeDevicesOffTimer(60);
          }
        },
        child: Container(
          margin: EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: EdgeInsets.all(4),
                color: entityId.contains("binary_sensor.") ||
                        entityId.contains("device_tracker.") ||
                        entityId.contains("person.")
                    ? ThemeInfo.colorBackgroundActive.withOpacity(0.1)
                    : ThemeInfo.colorBackgroundActive,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          flex: 100,
                          child: Text(
                            "${gd.textToDisplay(gd.entities[entityId].getOverrideName)}",
                            style: gd.entities[entityId].isStateOn
                                ? ThemeInfo.textNameButtonActive
                                : ThemeInfo.textNameButtonInActive,
                            textAlign: TextAlign.left,
                            maxLines: 2,
                            textScaleFactor: gd.textScaleFactor * 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                        Expanded(
                          flex: 45,
                          child: FittedBox(
                            child: Icon(
                              MaterialDesignIcons.getIconDataFromIconName(
                                  gd.entities[entityId].getDefaultIcon),
                              color: ThemeInfo.colorIconActive,
                              size: 100,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    AutoSizeText(
                      "${gd.textToDisplay(gd.entities[entityId].getStateDisplayTranslated(context))} ${gd.entities[entityId].unitOfMeasurement}",
                      style: gd.entities[entityId].isStateOn
                          ? ThemeInfo.textStatusButtonActive
                          : ThemeInfo.textStatusButtonInActive,
                      maxLines: 1,
                      textScaleFactor: gd.textScaleFactor * 1,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
//      child: AspectRatio(
//        aspectRatio: 1,
//        child: Padding(
//          padding: EdgeInsets.all(4 * gd.textScaleFactor),
//          child: Material(
//            color: entityId.contains("binary_sensor")
//                ? ThemeInfo.colorBackgroundActive.withOpacity(0.1)
//                : ThemeInfo.colorBackgroundActive,
//            shape:
//                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//            child: Container(
//              margin: EdgeInsets.symmetric(horizontal: 4 * gd.textScaleFactor),
//              padding: EdgeInsets.all(8 * gd.textScaleFactor),
//              width: buttonSize,
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Row(
//                    children: <Widget>[
//                      Expanded(
//                        flex: 2,
//                        child: FittedBox(
//                          child: Icon(
//                            MaterialDesignIcons.getIconDataFromIconName(
//                                gd.entities[entityId].getDefaultIcon),
//                            color: ThemeInfo.colorIconActive,
//                            size: 100,
//                          ),
//                        ),
//                      ),
//                      Expanded(
//                        flex: 3,
//                        child: Container(
//                          padding: EdgeInsets.symmetric(
//                              horizontal: 4 * gd.textScaleFactor),
//                          child: gd.showSpin ||
//                                  gd.entities[entityId].state.contains("...")
//                              ? FittedBox(
//                                  child: SpinKitThreeBounce(
//                                    size: 100,
//                                    color: ThemeInfo.colorIconActive
//                                        .withOpacity(0.5),
//                                  ),
//                                )
//                              : Container(),
//                        ),
//                      ),
//                    ],
//                  ),
//                  Expanded(
//                    child: Container(
//                      alignment: Alignment.bottomLeft,
//                      child: Text(
//                        "${gd.textToDisplay(gd.entities[entityId].getOverrideName)}",
//                        style: gd.entities[entityId].isStateOn
//                            ? ThemeInfo.textNameButtonActive
//                            : ThemeInfo.textNameButtonInActive,
//                        maxLines: 2,
//                        textScaleFactor: gd.textScaleFactor * 0.9,
//                        overflow: TextOverflow.ellipsis,
//                      ),
//                    ),
//                  ),
//                  Text(
//                    "${gd.textToDisplay(gd.entities[entityId].getStateDisplayTranslated(context))}",
//                    style: gd.entities[entityId].isStateOn
//                        ? ThemeInfo.textStatusButtonActive
//                        : ThemeInfo.textStatusButtonInActive,
//                    maxLines: 1,
//                    textScaleFactor: gd.textScaleFactor * 0.9,
//                    overflow: TextOverflow.ellipsis,
//                  ),
//                ],
//              ),
//            ),
//          ),
//        ),
//      ),
      ),
    );
  }
}
