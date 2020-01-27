import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';
import 'package:hasskit/model/entity_override.dart';
import 'package:hasskit/view/entity_control/entity_control_alarm_panel.dart';
import 'package:hasskit/view/entity_control/entity_control_climate.dart';
import 'package:hasskit/view/entity_control/entity_control_cover_position.dart';
import 'package:hasskit/view/entity_control/entity_control_general.dart';
import 'package:hasskit/view/entity_control/entity_control_google_maps.dart';
import 'package:hasskit/view/entity_control/entity_control_input_select.dart';
import 'package:hasskit/view/entity_control/entity_control_media_player.dart';
import 'package:hasskit/view/entity_control/entity_control_vacuum.dart';
import 'package:hasskit/view/entity_control/entity_control_water_heater.dart';
import 'package:provider/provider.dart';
import 'entity_control_binary_sensor.dart';
import 'entity_control_fan.dart';
import 'entity_control_input_datetime.dart';
import 'entity_control_input_number.dart';
import 'entity_control_light_dimmer.dart';
import 'entity_control_sensor.dart';
import 'entity_control_toggle.dart';
import 'package:hasskit/helper/locale_helper.dart';

class EntityControlParent extends StatefulWidget {
  final String entityId;
  const EntityControlParent({@required this.entityId});
  @override
  _EntityControlParentState createState() => _EntityControlParentState();
}

class _EntityControlParentState extends State<EntityControlParent> {
  bool showEditName = false;

  void showEditNameToggle() {
    setState(() {
      showEditName = !showEditName;
      log.d("showEditNameToggle $showEditName");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[widget.entityId].getOverrideName} " +
          "${generalData.entities[widget.entityId].getOverrideIcon} " +
          "${generalData.entities[widget.entityId].fanMode} " +
          "${generalData.entities[widget.entityId].speedList} " +
          "${generalData.entities[widget.entityId].speed} " +
          "${generalData.entities[widget.entityId].angle} " +
          "${generalData.entities[widget.entityId].oscillating} " +
          "${generalData.entities[widget.entityId].brightness} " +
          "${generalData.entities[widget.entityId].rgbColor} " +
          "${generalData.entities[widget.entityId].colorTemp} " +
          "${generalData.entities[widget.entityId].effect} " +
          "${generalData.entities[widget.entityId].effectList} " +
          "${generalData.entities[widget.entityId].getTemperature} " +
          "${generalData.entities[widget.entityId].currentPosition} " +
          "${generalData.entities[widget.entityId].state} " +
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
        } else if (entity.entityId.contains("light.")) {
          if (entity.getSupportedFeaturesLights
                  .contains("SUPPORT_COLOR_TEMP") ||
              entity.getSupportedFeaturesLights
                  .contains("SUPPORT_WHITE_VALUE")) {
            entityControl = EntityControlLightDimmer(
              entityId: widget.entityId,
              viewMode: "SUPPORT_COLOR_TEMP",
            );
          } else if (entity.getSupportedFeaturesLights
                  .contains("SUPPORT_RGB_COLOR") ||
              entity.getSupportedFeaturesLights.contains("SUPPORT_XY_COLOR")) {
            entityControl = EntityControlLightDimmer(
              entityId: widget.entityId,
              viewMode: "SUPPORT_RGB_COLOR",
            );
          } else if (entity.getSupportedFeaturesLights
              .contains("SUPPORT_EFFECT")) {
            entityControl = EntityControlLightDimmer(
              entityId: widget.entityId,
              viewMode: "SUPPORT_EFFECT",
            );
          } else if (entity.getSupportedFeaturesLights
                  .contains("SUPPORT_BRIGHTNESS") ||
              entity.getSupportedFeaturesLights
                  .contains("SUPPORT_TRANSITION")) {
            entityControl = EntityControlLightDimmer(
              entityId: widget.entityId,
              viewMode: "SUPPORT_BRIGHTNESS",
            );
          } else {
            entityControl = EntityControlToggle(entityId: widget.entityId);
          }
        } else if (entity.entityId.contains("cover.") &&
            entity.currentPosition != null) {
          entityControl = EntityControlCoverPosition(entityId: widget.entityId);
        } else if (entity.entityId.contains("input_number.") &&
            entity.state != null &&
            entity.min != null &&
            entity.max != null) {
          entityControl = EntityControlInputNumber(entityId: widget.entityId);
        } else if (entity.entityId.contains("input_datetime.")) {
          entityControl = EntityControlInputDateTime(entityId: widget.entityId);
        } else if (entity.entityType == EntityType.mediaPlayers) {
          entityControl = EntityControlMediaPlayer(entityId: widget.entityId);
        } else if (entity.entityId.contains("vacuum.")) {
          entityControl = EntityControlVacuum(entityId: widget.entityId);
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
        } else if (entity.entityId.contains("device_tracker.") ||
            entity.entityId.contains("person.")) {
          entityControl = EntityControlGoogleMaps(entityId: widget.entityId);
        } else if (entity.entityId.contains("input_select.")) {
          entityControl = EntityControlInputSelect(entityId: widget.entityId);
        } else if (entity.entityId.contains("water_heater.")) {
          entityControl = EntityControlWaterHeater(entityId: widget.entityId);
        } else if (entity.entityType == EntityType.lightSwitches ||
            entity.entityType == EntityType.mediaPlayers ||
            entity.entityId.contains("automation.") ||
            entity.entityId.contains("group.") ||
            entity.entityId.contains("scene.") ||
            entity.entityId.contains("script.")) {
          entityControl = EntityControlToggle(entityId: widget.entityId);
        } else {
          entityControl = EntityControlGeneral(entityId: widget.entityId);
        }

//        print(
//            "MediaQuery.of(context).padding.top ${MediaQuery.of(gd.mediaQueryContext).padding.top}");

        return SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(gd.mediaQueryContext).padding.top,
                  ),
                  EditEntityNormal(
                    entityId: widget.entityId,
                    showEditNameToggle: showEditNameToggle,
                    showEditName: showEditName,
                  ),
                  !showEditName
                      ? Expanded(child: entityControl)
                      : Expanded(
                          child: EditMode(
                          entityId: widget.entityId,
                          showEditNameToggle: showEditNameToggle,
                          showEditName: showEditName,
                        )),
                  //Show History
                  !showEditName &&
                          (entity.entityType == EntityType.lightSwitches ||
                              entity.entityType == EntityType.climateFans)
                      ? Column(
                          children: <Widget>[
                            Container(
                              height: 25,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: EntityControlBinarySensor(
                                entityId: entity.entityId,
                                horizontalMode: true,
                              ),
                            ),
                            SizedBox(height: 25),
                          ],
                        )
                      : Container(),
                ],
              ),
              //Show History Icon
              !showEditName &&
                      (entity.entityType == EntityType.lightSwitches ||
                          entity.entityType == EntityType.climateFans)
                  ? Positioned(
                      bottom: 25,
                      left: 0,
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
            ],
          ),
        );
      },
    );
  }
}

class IconSelection extends StatefulWidget {
  final String entityId;
  final Function closeIconSelection;
  final Function clickChangeIcon;
  const IconSelection({
    @required this.entityId,
    @required this.closeIconSelection,
    @required this.clickChangeIcon,
  });

  @override
  _IconSelectionState createState() => _IconSelectionState();
}

class _IconSelectionState extends State<IconSelection> {
  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
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
                                color: ThemeInfo.colorBottomSheet
                                    .withOpacity(0.25)),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                index == 0
                                    ? Text(
                                        Translate.getString(
                                            "edit.reset_icon", context),
                                        style: ThemeInfo
                                            .textStatusButtonInActive
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
      ),
    );
  }
}

class EditEntityNormal extends StatefulWidget {
  final String entityId;
  final Function showEditNameToggle;
  final bool showEditName;
  const EditEntityNormal(
      {@required this.entityId,
      @required this.showEditNameToggle,
      @required this.showEditName});
  @override
  _EditEntityNormalState createState() => _EditEntityNormalState();
}

class _EditEntityNormalState extends State<EditEntityNormal> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[widget.entityId];
    _controller.text = '${gd.entities[widget.entityId].getOverrideName}';
    return Material(
      color: ThemeInfo.colorBottomSheet,
      elevation: 1,
      child: Row(
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
          Icon(
            MaterialDesignIcons.getIconDataFromIconName(
              entity.getDefaultIcon,
            ),
            color: entity.isStateOn
                ? ThemeInfo.colorIconActive
                : ThemeInfo.colorIconInActive,
            size: 30,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              gd.textToDisplay(entity.getOverrideName),
              style: Theme.of(context).textTheme.subhead,
              textScaleFactor: gd.textScaleFactorFix,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
          ),
          gd.deviceSetting.settingLocked
              ? Container()
              : InkWell(
                  onTap: () {
                    setState(
                      () {
                        if (gd.entitiesOverride[widget.entityId] != null) {
                          gd.entitiesOverride[widget.entityId].friendlyName =
                              _controller.text.trim();
                        } else {
                          gd.entitiesOverride[widget.entityId] = EntityOverride(
                              friendlyName: _controller.text.trim());
                        }
                        gd.entitiesOverrideSave(true);
                        widget.showEditNameToggle();
                      },
                    );
                  },
                  child: Icon(
                    widget.showEditName ? Icons.settings : Icons.settings,
                    size: 30,
                  ),
                ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}

class EditMode extends StatefulWidget {
  final String entityId;
  final Function showEditNameToggle;
  final bool showEditName;

  const EditMode({
    @required this.entityId,
    @required this.showEditNameToggle,
    @required this.showEditName,
  });

  @override
  _EditModeState createState() => _EditModeState();
}

class _EditModeState extends State<EditMode> {
  Entity entity;
  TextEditingController _controllerName = TextEditingController();
  FocusNode _focusNodeName = new FocusNode();
  TextEditingController _controllerSearch = TextEditingController();
  FocusNode _focusNodeSearch = new FocusNode();

  @override
  void initState() {
    super.initState();
    if (gd.iconsOverride.length < 1) {
      gd.iconsOverride.add("");
      for (var key in MaterialDesignIcons.iconsDataMap.keys) {
        gd.iconsOverride.add(key);
      }
    }
    entity = gd.entities[widget.entityId];
    _controllerName.text = '${entity.getOverrideName}';
  }

  @override
  Widget build(BuildContext context) {
    print("_EditModeState build");
    List<Widget> roomWidgets = [];

    for (var room in gd.roomList) {
      var roomWidget = Container(
        margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ThemeInfo.colorBottomSheetReverse.withOpacity(0.25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(width: 1),
                Text(
                  room.name,
                  textScaleFactor: gd.textScaleFactorFix * 1.5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: ThemeInfo.colorBottomSheetReverse),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  if (room.row1.contains(widget.entityId)) {
                    room.row1.remove(widget.entityId);
                  } else {
                    room.row1.add(widget.entityId);
                  }
                  gd.roomListSave(true);
                });
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.looks_one,
                  ),
                  SizedBox(width: 4, height: 30),
                  Expanded(
                    child: Text(
                      room.row1Name,
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: ThemeInfo.colorBottomSheetReverse),
                    ),
                  ),
                  Opacity(
                    opacity: room.row1.contains(widget.entityId) ? 1 : 0.2,
                    child: Icon(
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  if (room.row2.contains(widget.entityId)) {
                    room.row2.remove(widget.entityId);
                  } else {
                    room.row2.add(widget.entityId);
                  }
                  gd.roomListSave(true);
                });
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.looks_two,
                  ),
                  SizedBox(width: 4, height: 30),
                  Expanded(
                    child: Text(
                      room.row2Name,
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: ThemeInfo.colorBottomSheetReverse),
                    ),
                  ),
                  Opacity(
                    opacity: room.row2.contains(widget.entityId) ? 1 : 0.2,
                    child: Icon(
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  if (room.row3.contains(widget.entityId)) {
                    room.row3.remove(widget.entityId);
                  } else {
                    room.row3.add(widget.entityId);
                  }
                  gd.roomListSave(true);
                });
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.looks_3,
                  ),
                  SizedBox(width: 4, height: 30),
                  Expanded(
                    child: Text(
                      room.row3Name,
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: ThemeInfo.colorBottomSheetReverse),
                    ),
                  ),
                  Opacity(
                    opacity: room.row3.contains(widget.entityId) ? 1 : 0.2,
                    child: Icon(
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  if (room.row4.contains(widget.entityId)) {
                    room.row4.remove(widget.entityId);
                  } else {
                    room.row4.add(widget.entityId);
                  }
                  gd.roomListSave(true);
                });
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.looks_4,
                  ),
                  SizedBox(width: 4, height: 30),
                  Expanded(
                    child: Text(
                      room.row4Name,
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: ThemeInfo.colorBottomSheetReverse),
                    ),
                  ),
                  Opacity(
                    opacity: room.row4.contains(widget.entityId) ? 1 : 0.2,
                    child: Icon(
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      roomWidgets.add(roomWidget);
    }

    List<String> iconsOverrideFiltered = [];
    if (_controllerSearch.text.trim() == "") {
      iconsOverrideFiltered = gd.iconsOverride;
    } else {
      iconsOverrideFiltered = gd.iconsOverride
          .where((e) =>
              e == "" ||
              e.toLowerCase().contains(_controllerSearch.text.toLowerCase()))
          .toList();
    }
    print("iconsOverrideFiltered  ${iconsOverrideFiltered.length}");

    return Container(
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                //Rename
                Container(
                  margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ThemeInfo.colorBottomSheetReverse.withOpacity(0.25),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                            hintText:
                                '${gd.entities[widget.entityId].getFriendlyName}',
                          ),
                          focusNode: _focusNodeName,
                          controller: _controllerName,
                          style: Theme.of(context).textTheme.subhead,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          autocorrect: false,
                          autofocus: false,
                          onEditingComplete: () {
                            setState(
                              () {
                                if (gd.entitiesOverride[widget.entityId] !=
                                    null) {
                                  gd.entitiesOverride[widget.entityId]
                                          .friendlyName =
                                      _controllerName.text.trim();
                                } else {
                                  gd.entitiesOverride[widget.entityId] =
                                      EntityOverride(
                                          friendlyName:
                                              _controllerName.text.trim());
                                }
                                print("onEditingComplete");
                                gd.entitiesOverrideSave(true);
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
//                          widget.showEditNameToggle();
                              },
                            );
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _controllerName.clear();
                            gd.entitiesOverride[widget.entityId].friendlyName =
                                "";
                            gd.entitiesOverrideSave(true);
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          });
                        },
                        icon: Icon(Icons.cancel),
                      ),
                      SizedBox(width: 4),
                    ],
                  ),
                ),
                //Icon
                Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.fromLTRB(4, 12, 4, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ThemeInfo.colorBottomSheetReverse.withOpacity(0.25),
                  ),
                  height: MediaQuery.of(context).viewInsets.bottom > 0
                      ? gd.mediaQueryHeight * 0.5
                      : gd.mediaQueryHeight * 0.5,
                  child: Column(
                    children: <Widget>[
                      //search text
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 0.0, 0.0, 0.0),
                                hintText:
                                    'Select Icon (${gd.iconsOverride.length}  available)',
                              ),
                              focusNode: _focusNodeSearch,
                              controller: _controllerSearch,
                              style: Theme.of(context).textTheme.subhead,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              autocorrect: false,
                              autofocus: false,
                              onChanged: (val) {
                                setState(() {});
                              },
                              onEditingComplete: () {
                                setState(
                                  () {
                                    if (gd.entitiesOverride[widget.entityId] !=
                                        null) {
                                      gd.entitiesOverride[widget.entityId]
                                              .friendlyName =
                                          _controllerName.text.trim();
                                    } else {
                                      gd.entitiesOverride[widget.entityId] =
                                          EntityOverride(
                                              friendlyName:
                                                  _controllerName.text.trim());
                                    }
                                    print("onEditingComplete");
                                    gd.entitiesOverrideSave(true);
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
//                              widget.showEditNameToggle();
                                  },
                                );
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _controllerSearch.clear();
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              });
                            },
                            icon: Icon(Icons.cancel),
                          ),
                        ],
                      ),
                      Expanded(
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverPadding(
                              padding: EdgeInsets.all(8),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 80.0,
                                  mainAxisSpacing: 8.0,
                                  crossAxisSpacing: 8.0,
                                  childAspectRatio: 1,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (gd.entitiesOverride[
                                                  widget.entityId] !=
                                              null) {
                                            gd.entitiesOverride[widget.entityId]
                                                    .icon =
                                                iconsOverrideFiltered[index];
                                          } else {
                                            EntityOverride entityOverride =
                                                EntityOverride(
                                                    icon: gd
                                                        .iconsOverride[index]);
                                            gd.entitiesOverride[widget
                                                .entityId] = entityOverride;
                                          }
                                          log.d(
                                              "SliverChildBuilderDelegate ${iconsOverrideFiltered[index]}");

                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());

                                          gd.entitiesOverrideSave(true);
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: ThemeInfo.colorBottomSheet
                                                .withOpacity(0.25)),
                                        alignment: Alignment.center,
                                        child: index == 0
                                            ? Text(
                                                Translate.getString(
                                                    "edit.reset_icon", context),
                                                style: ThemeInfo
                                                    .textStatusButtonInActive
                                                    .copyWith(
                                                        color: ThemeInfo
                                                            .colorBottomSheetReverse
                                                            .withOpacity(0.75)),
                                                textScaleFactor:
                                                    gd.textScaleFactorFix,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                maxLines: 3,
                                              )
                                            : Column(
                                                children: <Widget>[
                                                  SizedBox(height: 2),
                                                  Icon(
                                                    gd.mdiIcon(
                                                        iconsOverrideFiltered[
                                                            index]),
                                                    size: 34,
                                                    color: ThemeInfo
                                                        .colorBottomSheetReverse
                                                        .withOpacity(0.75),
                                                  ),
                                                  Text(
                                                    "${iconsOverrideFiltered[index].replaceAll("mdi:", "")}",
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textScaleFactor:
                                                        gd.textScaleFactorFix *
                                                            0.75,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    );
                                  },
                                  childCount: iconsOverrideFiltered.length,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                //Room
                gd.activeDevicesSupportedType(widget.entityId)
                    ? InkWell(
                        onTap: () {
                          if (gd.baseSetting.notificationDevices
                              .contains(widget.entityId)) {
                            setState(() {
                              gd.baseSetting.notificationDevices
                                  .remove(widget.entityId);
                              gd.baseSettingSave(true);
                            });
                          } else {
                            setState(() {
                              gd.baseSetting.notificationDevices
                                  .add(widget.entityId);
                              gd.baseSettingSave(true);
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 2),
                              Expanded(
                                  child: Text(
                                "Track device state",
                                textScaleFactor: gd.textScaleFactorFix,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )),
                              Icon(
                                gd.baseSetting.notificationDevices
                                        .contains(widget.entityId)
                                    ? Icons.notifications
                                    : Icons.notifications_off,
                                color: gd.baseSetting.notificationDevices
                                        .contains(widget.entityId)
                                    ? Theme.of(context).textTheme.title.color
                                    : (gd.activeDevicesSupportedType(
                                            widget.entityId))
                                        ? Theme.of(context)
                                            .textTheme
                                            .title
                                            .color
                                            .withOpacity(0.25)
                                        : Theme.of(context)
                                            .textTheme
                                            .title
                                            .color
                                            .withOpacity(0.0),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: roomWidgets,
                ),
                Container(
                  height: MediaQuery.of(context).viewInsets.bottom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
