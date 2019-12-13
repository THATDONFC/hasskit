import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/SquircleBorder.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
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
                      height: buttonSize * 0.75,
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
    return InkWell(
      onTap: () {
        gd.toggleStatus(gd.entities[entityId]);
        if (gd.activeDevicesOn.length <= 0) {
          gd.activeDevicesOffTimer(0);
        } else {
          gd.activeDevicesOffTimer(60);
        }
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Material(
            color: entityId.contains("binary_sensor")
                ? ThemeInfo.colorBackgroundActive.withOpacity(0.1)
                : ThemeInfo.colorBackgroundActive,
            shape: gd.baseSetting.shapeLayout == 1
                ? SquircleBorder()
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.all(8 * gd.textScaleFactor),
              width: buttonSize,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: FittedBox(
                          child: Icon(
                            MaterialDesignIcons.getIconDataFromIconName(
                                gd.entities[entityId].getDefaultIcon),
                            color: ThemeInfo.colorIconActive,
                            size: 100,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4 * gd.textScaleFactor),
                          child: gd.showSpin ||
                                  gd.entities[entityId].state.contains("...")
                              ? FittedBox(
                                  child: SpinKitThreeBounce(
                                    size: 100,
                                    color: ThemeInfo.colorIconActive
                                        .withOpacity(0.5),
                                  ),
                                )
                              : Container(),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "${gd.textToDisplay(gd.entities[entityId].getOverrideName)}",
                        style: gd.entities[entityId].isStateOn
                            ? ThemeInfo.textNameButtonActive
                            : ThemeInfo.textNameButtonInActive,
                        maxLines: 2,
                        textScaleFactor: gd.textScaleFactor * 0.9,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                  Text(
                    "${gd.textToDisplay(gd.entities[entityId].getStateDisplayTranslated(context))}",
                    style: gd.entities[entityId].isStateOn
                        ? ThemeInfo.textStatusButtonActive
                        : ThemeInfo.textStatusButtonInActive,
                    maxLines: 1,
                    textScaleFactor: gd.textScaleFactor * 0.9,
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
