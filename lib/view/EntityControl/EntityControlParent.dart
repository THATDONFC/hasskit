import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:hasskit/model/EntityOverride.dart';
import 'package:hasskit/view/EntityControl/EntityControlAlarmPanel.dart';
import 'package:hasskit/view/EntityControl/EntityControlClimate.dart';
import 'package:hasskit/view/EntityControl/EntityControlCoverPosition.dart';
import 'package:hasskit/view/EntityControl/EntityControlGeneral.dart';
import 'package:hasskit/view/EntityControl/EntityControlMediaPlayer.dart';
import 'package:provider/provider.dart';
import 'EntityControlBinarySensor.dart';
import 'EntityControlFan.dart';
import 'EntityControlInputNumber.dart';
import 'EntityControlLightDimmer.dart';
import 'EntityControlSensor.dart';
import 'EntityControlToggle.dart';
import 'package:hasskit/helper/LocaleHelper.dart';

class EntityControlParent extends StatefulWidget {
  final String entityId;
  const EntityControlParent({@required this.entityId});
  @override
  _EntityControlParentState createState() => _EntityControlParentState();
}

class _EntityControlParentState extends State<EntityControlParent> {
  bool showEditName = false;
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = '${gd.entities[widget.entityId].getOverrideName}';
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[widget.entityId].state} " +
          "${generalData.entities[widget.entityId].getFriendlyName} " +
          "${generalData.entities[widget.entityId].getOverrideIcon} " +
          "",
      builder: (context, data, child) {
        final Entity entity = gd.entities[widget.entityId];
        if (entity == null) {
          log.e('Cant find entity name ${widget.entityId}');
          return Container();
        }

        Widget entityControl;

        if (entity.entityType == EntityType.climateFans &&
            entity.hvacModes != null &&
            entity.hvacModes.length > 0) {
          entityControl = EntityControlClimate(entityId: widget.entityId);
        } else if (entity.entityType == EntityType.climateFans &&
            entity.speedList != null &&
            entity.speedList.length > 0) {
          entityControl = EntityControlFan(entityId: widget.entityId);
        } else if (entity.entityId.contains("light.") &&
            (entity.getSupportedFeaturesLights.contains("SUPPORT_RGB_COLOR") ||
                entity.getSupportedFeaturesLights
                    .contains("SUPPORT_COLOR_TEMP") ||
                entity.getSupportedFeaturesLights
                    .contains("SUPPORT_BRIGHTNESS"))) {
          entityControl = EntityControlLightDimmer(entityId: widget.entityId);
        } else if (entity.entityId.contains("cover.") &&
            entity.currentPosition != null) {
          entityControl = EntityControlCoverPosition(entityId: widget.entityId);
        } else if (entity.entityId.contains("input_number.") &&
            entity.state != null &&
            entity.min != null &&
            entity.max != null) {
          entityControl = EntityControlInputNumber(entityId: widget.entityId);
        } else if (entity.entityType == EntityType.mediaPlayers) {
          entityControl = EntityControlMediaPlayer(entityId: widget.entityId);
        } else if (entity.entityType == EntityType.lightSwitches ||
            entity.entityType == EntityType.mediaPlayers ||
            entity.entityId.contains("group.") ||
            entity.entityId.contains("scene.")) {
          entityControl = EntityControlToggle(entityId: widget.entityId);
        } else if (entity.entityId.contains("binary_sensor.")
//            ||            entity.entityId.contains("device_tracker.") //Need more data check
            ) {
          entityControl = EntityControlBinarySensor(
            entityId: widget.entityId,
          );
        } else if (entity.entityId.contains("sensor.")) {
          entityControl = EntityControlSensor(entityId: widget.entityId);
        } else if (entity.entityId.contains("alarm_control_panel.")) {
          entityControl = EntityControlAlarmPanel(entityId: widget.entityId);
        } else {
          entityControl = EntityControlGeneral(entityId: widget.entityId);
        }
//    return Selector<GeneralData, String>(
//      selector: (_, generalData) =>
//          "${generalData.connectionStatus} " +
//          "${generalData.entities[widget.entityId].state}",
//      builder: (_, state, __) {
        return SafeArea(
          child: Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                color: ThemeInfo.colorBottomSheet,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: gd.mediaQueryLongestSide > 600 ? 48 : 24),
                    Container(
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Positioned(
                            left: 10,
                            child: Container(
                              width: 50,
                              height: 50,
                              child: Icon(
                                MaterialDesignIcons.getIconDataFromIconName(
                                  gd.entities[widget.entityId].getDefaultIcon,
                                ),
                                color: gd.entities[widget.entityId].isStateOn
                                    ? ThemeInfo.colorIconActive
                                    : ThemeInfo.colorIconInActive,
                                size: 35,
                              ),
                            ),
                          ),
                          !showEditName
                              ? Stack(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        SizedBox(width: 60),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              gd.textToDisplay(
                                                  entity.getOverrideName),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .title,
                                              textScaleFactor:
                                                  gd.textScaleFactorFix,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 60),
                                      ],
                                    ),
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: InkWell(
                                          onTap: () {
                                            showEditName = true;
                                            setState(() {});
                                          },
                                          child: Container(
                                            child: Icon(
                                              Icons.edit,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        SizedBox(width: 60),
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            alignment: Alignment.center,
                                            child: TextField(
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  hintText:
                                                      '${gd.entities[widget.entityId].getFriendlyName}'),
                                              focusNode: _focusNode,
                                              controller: _controller,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .title,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              autocorrect: false,
                                              autofocus: true,
                                              onEditingComplete: () {
                                                showEditName = false;
                                                setState(
                                                  () {
                                                    if (gd.entitiesOverride[
                                                            widget.entityId] !=
                                                        null) {
                                                      gd
                                                              .entitiesOverride[
                                                                  widget.entityId]
                                                              .friendlyName =
                                                          _controller.text
                                                              .trim();
                                                    } else {
                                                      gd.entitiesOverride[
                                                              widget.entityId] =
                                                          EntityOverride(
                                                              friendlyName:
                                                                  _controller
                                                                      .text
                                                                      .trim());
                                                    }
                                                    gd.entitiesOverrideSave(
                                                        true);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 60),
                                      ],
                                    ),
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: InkWell(
                                          onTap: () {
                                            showEditName = false;

                                            if (gd.entitiesOverride[
                                                    widget.entityId] !=
                                                null) {
                                              gd
                                                      .entitiesOverride[
                                                          widget.entityId]
                                                      .friendlyName =
                                                  _controller.text.trim();
                                            } else {
                                              gd.entitiesOverride[
                                                      widget.entityId] =
                                                  EntityOverride(
                                                      friendlyName: _controller
                                                          .text
                                                          .trim());
                                            }
                                            gd.entitiesOverrideSave(true);
                                            setState(
                                              () {},
                                            );
                                          },
                                          child: Container(
                                            child: Icon(
                                              Icons.save,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    !showEditName
                        ? Stack(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    child: !showEditName
                                        ? entityControl
                                        : Container(),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Stack(
                            children: <Widget>[
                              _IconSelection(
                                entityId: widget.entityId,
                                closeIconSelection: () {
                                  showEditName = false;
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  setState(() {});
                                },
                                clickChangeIcon: () {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                    Expanded(
                      child: Container(),
                    ),
                    entity.entityType == EntityType.lightSwitches ||
                            entity.entityType == EntityType.climateFans
                        ? Column(
                            children: <Widget>[
                              Container(
                                height: 25,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: EntityControlBinarySensor(
                                  entityId: entity.entityId,
                                  horizontalMode: true,
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
              entity.entityType == EntityType.lightSwitches ||
                      entity.entityType == EntityType.climateFans
                  ? Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ThemeInfo.colorBottomSheet,
                          boxShadow: [
                            BoxShadow(
                              color: ThemeInfo.colorBottomSheet,
                              offset: new Offset(0.0, 0.0),
                              blurRadius: 6.0,
                            )
                          ],
                        ),
                        child: Icon(
                          MaterialDesignIcons.getIconDataFromIconName(
                              "mdi:history"),
                          color: ThemeInfo.colorBottomSheetReverse
                              .withOpacity(0.25),
                          size: 28,
                        ),
                      ),
                    )
                  : Container(),
              Positioned(
                bottom: 8,
                right: 8,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ThemeInfo.colorBottomSheet,
                      boxShadow: [
                        new BoxShadow(
                          color: ThemeInfo.colorBottomSheet,
                          offset: new Offset(0.0, 0.0),
                          blurRadius: 6.0,
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.cancel,
                      color: ThemeInfo.colorBottomSheetReverse.withOpacity(1),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IconSelection extends StatefulWidget {
  final String entityId;
  final Function closeIconSelection;
  final Function clickChangeIcon;
  const _IconSelection({
    @required this.entityId,
    @required this.closeIconSelection,
    @required this.clickChangeIcon,
  });

  @override
  __IconSelectionState createState() => __IconSelectionState();
}

class __IconSelectionState extends State<_IconSelection> {
  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            color: ThemeInfo.colorIconActive,
            boxShadow: [
              new BoxShadow(
                color: ThemeInfo.colorBottomSheet,
                offset: new Offset(0.0, 0.0),
                blurRadius: 6.0,
              )
            ],
          ),
          child: Center(
            child: Text(
              Translate.getString("edit.select_icon", context),
              style: Theme.of(context).textTheme.title,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: gd.textScaleFactorFix,
            ),
          ),
        ),
        Container(
          height: gd.mediaQueryHeight -
              kBottomNavigationBarHeight -
              kToolbarHeight -
              100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
              color: ThemeInfo.colorBottomSheetReverse.withOpacity(0.25)),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.all(8),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 80.0,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          if (gd.entitiesOverride[widget.entityId] != null) {
                            gd.entitiesOverride[widget.entityId].icon =
                                gd.iconsOverride[index];
                          } else {
                            EntityOverride entityOverride =
                                EntityOverride(icon: gd.iconsOverride[index]);
                            gd.entitiesOverride[widget.entityId] =
                                entityOverride;
                          }
                          log.d(
                              "SliverChildBuilderDelegate ${gd.iconsOverride[index]}");
                          widget.clickChangeIcon();

                          gd.entitiesOverrideSave(true);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color:
                                  ThemeInfo.colorBottomSheet.withOpacity(0.25)),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              index == 0
                                  ? Text(
                                      Translate.getString(
                                          "edit.reset_icon", context),
                                      style: ThemeInfo.textStatusButtonInActive
                                          .copyWith(
                                              color: ThemeInfo
                                                  .colorBottomSheetReverse
                                                  .withOpacity(0.75)),
                                      textScaleFactor: gd.textScaleFactorFix,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                    )
                                  : Icon(
                                      gd.mdiIcon(gd.iconsOverride[index]),
                                      size: 50,
                                      color: ThemeInfo.colorBottomSheetReverse
                                          .withOpacity(0.75),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: gd.iconsOverride.length,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
