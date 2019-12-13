import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/helper/LocaleHelper.dart';

BottomSheetMenu bottomSheetMenu = new BottomSheetMenu();

class BottomSheetMenu {
  mainBottomSheet(int roomIndex, BuildContext context) {
    bool showSort = false;
    List<String> classIds = [];
    for (String entityId in gd.roomList[roomIndex].favorites) {
      if (!classIds.contains(gd.entityTypeCombined(entityId))) {
        classIds.add(gd.entityTypeCombined(entityId));
      } else {
        showSort = true;
        break;
      }
    }

    if (!showSort) {
      classIds.clear();
      for (String entityId in gd.roomList[roomIndex].entities) {
        if (!classIds.contains(gd.entityTypeCombined(entityId))) {
          classIds.add(gd.entityTypeCombined(entityId));
        } else {
          showSort = true;
          break;
        }
      }
    }

    if (!showSort) {
      classIds.clear();
      for (String entityId in gd.roomList[roomIndex].row3) {
        if (!classIds.contains(gd.entityTypeCombined(entityId))) {
          classIds.add(gd.entityTypeCombined(entityId));
        } else {
          showSort = true;
          break;
        }
      }
    }

    if (!showSort) {
      classIds.clear();
      for (String entityId in gd.roomList[roomIndex].row4) {
        if (!classIds.contains(gd.entityTypeCombined(entityId))) {
          classIds.add(gd.entityTypeCombined(entityId));
        } else {
          showSort = true;
          break;
        }
      }
    }

    log.d(
        "BottomSheetMenu roomIndex $roomIndex gd.roomList.length ${gd.roomList.length}");
    bool showMoveLeft = false;
    if (roomIndex > 1 && roomIndex < gd.roomList.length) {
      showMoveLeft = true;
    }

    bool showMoveRight = false;
    if (roomIndex > 0 && roomIndex != gd.roomList.length - 1) {
      showMoveRight = true;
    }
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _createTile(
                      context,
                      roomIndex,
                      '${Translate.getString('edit.edit', context)} ${gd.roomList[roomIndex].name}',
                      MaterialDesignIcons.getIconDataFromIconName(
                          "mdi:view-dashboard-variant"),
                      true,
                      editRoom),
                  _createTile(
                      context,
                      roomIndex,
                      '${Translate.getString('edit.arrange', context)} ${gd.roomList[roomIndex].name} ${Translate.getString('edit.devices', context)}',
                      MaterialDesignIcons.getIconDataFromIconName(
                          "mdi:vector-arrange-above"),
                      showSort,
                      sortRoom),
                  _createTile(
                      context,
                      roomIndex,
                      '${Translate.getString('edit.move', context)} ${gd.roomList[roomIndex].name} ${Translate.getString('global.left', context)}',
                      Icons.chevron_left,
                      showMoveLeft,
                      moveLeft),
                  _createTile(
                      context,
                      roomIndex,
                      '${Translate.getString('edit.move', context)} ${gd.roomList[roomIndex].name} ${Translate.getString('global.right', context)}',
                      Icons.chevron_right,
                      showMoveRight,
                      moveRight),
                  _createTile(context, roomIndex, Translate.getString("edit.add_room", context), Icons.add_box,
                      roomIndex != 0, addNewRoom),
                  _createTile(
                      context,
                      roomIndex,
                      '${Translate.getString('edit.delete', context)} ${gd.roomList[roomIndex].name}',
                      Icons.delete,
                      roomIndex != 0 && roomIndex != 1,
                      deleteRoom),
                ],
              ),
            ),
          );
        });
  }

  ListTile _createTile(BuildContext context, int roomIndex, String name,
      IconData icon, bool enabled, Function action) {
    return ListTile(
      leading: Opacity(opacity: enabled ? 1 : 0.2, child: Icon(icon)),
      title: Opacity(opacity: enabled ? 1 : 0.2, child: Text(name)),
      onTap: enabled
          ? () {
              Navigator.pop(context);
              action(roomIndex);
            }
          : () {},
    );
  }

  addNewRoom(int roomIndex) {
    log.d('addNewRoom $roomIndex');
    gd.addRoom(roomIndex);
    gd.viewMode = ViewMode.normal;
  }

  editRoom(int roomIndex) {
    log.d('editRoom $roomIndex');
    gd.viewMode = ViewMode.edit;
  }

  deleteRoom(int roomIndex) {
    log.d('deleteRoom $roomIndex');
    gd.deleteRoom(roomIndex);
    gd.viewMode = ViewMode.normal;
  }

  sortRoom(int roomIndex) {
    log.d('sortRoom $roomIndex');
    gd.viewMode = ViewMode.sort;
  }

  moveLeft(int roomIndex) {
    log.d('moveLeft $roomIndex');
    gd.viewMode = ViewMode.normal;
    gd.swapRoom(roomIndex, roomIndex - 1);
  }

  moveRight(int roomIndex) {
    log.d('moveRight $roomIndex');
    gd.viewMode = ViewMode.normal;
    gd.swapRoom(roomIndex, roomIndex + 1);
  }
}
