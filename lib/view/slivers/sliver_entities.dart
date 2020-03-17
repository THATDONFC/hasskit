import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';
import 'package:hasskit/view/entity_button.dart';
import 'package:hasskit/view/entity_camera.dart';
import 'package:hasskit/view/entity_control/entity_control_camera_video_player.dart';
import 'package:hasskit/view/entity_control/entity_control_camera_webview.dart';
import 'package:hasskit/view/entity_control/entity_control_parent.dart';
import 'package:hasskit/view/slivers/sliver_web_view.dart';
import 'package:reorderables/reorderables.dart';

class SliverEntitiesNormal extends StatelessWidget {
  final int roomIndex;
  final double aspectRatio;
  final bool isCamera;
  final List<String> entities;

  const SliverEntitiesNormal({
    @required this.roomIndex,
    @required this.aspectRatio,
    @required this.isCamera,
    @required this.entities,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> sliverWidgets = [];

    for (int i = 0; i < entities.length; i++) {
      var entityId = entities[i];
      if (entityId.contains("WebView")) {
        var webView = WebView(webViewsId: entityId);
        sliverWidgets.add(webView);
      } else if (entityId.contains("camera.") &&
          gd.entities[entityId] != null) {
        var entityCamera = EntityCamera(
          entityId: entityId,
          onTapCallback: () {
            log.d("$entityId SliverEntitiesNormal onTapCallback");
            gd.cameraStreamUrl = "";
            gd.cameraStreamId = 0;
            gd.requestCameraStream(entityId);

            showModalBottomSheet(
              context: context,
              backgroundColor: ThemeInfo.colorBottomSheet,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (BuildContext context) {
                return Theme.of(context).platform == TargetPlatform.iOS
                    ? EntityControlCameraWebView(entityId: entityId)
                    : EntityControlCameraVideoPlayer(entityId: entityId);
              },
            );
          },
          onLongPressCallback: () {
            log.d("$entityId SliverEntitiesNormal onTapCallback");
            gd.cameraStreamUrl = "";
            gd.cameraStreamId = 0;
            gd.requestCameraStream(entityId);

            showModalBottomSheet(
              context: context,
              backgroundColor: ThemeInfo.colorBottomSheet,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (BuildContext context) {
                return Theme.of(context).platform == TargetPlatform.iOS
                    ? EntityControlCameraWebView(entityId: entityId)
                    : EntityControlCameraVideoPlayer(entityId: entityId);
              },
            );
          },
        );
        sliverWidgets.add(entityCamera);
      } else if (gd.entities[entityId] != null) {
        var entityButton = EntityButton(
          entityId: entityId,
          onTapCallback: () {
            log.d("$entityId SliverEntitiesNormal onTapCallback");
            if (gd.entities[entityId].entityType == EntityType.group ||
                gd.entities[entityId].entityType == EntityType.mediaPlayers ||
                gd.entities[entityId].entityType == EntityType.climateFans ||
                gd.entities[entityId].entityType == EntityType.accessories ||
                gd.entities[entityId].entityType == EntityType.cameras ||
                entityId.contains("automation.") ||
                entityId.contains("script.") ||
                entityId.contains("vacuum.") ||
                !gd.entities[entityId].isStateOn &&
                    gd.entitiesOverride[entityId] != null &&
                    gd.entitiesOverride[entityId].openRequireAttention !=
                        null ||
                entityId.contains('lock.') &&
                    !gd.entities[entityId].isStateOn ||
                gd.entities[entityId].currentPosition != null) {
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
              gd.clickedStatus[entityId] = true;
            }
          },
          onLongPressCallback: () {
            log.d("$entityId SliverEntitiesNormal onLongPressCallback");
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
          },
        );
        sliverWidgets.add(entityButton);
      } else {
//        log.e("Error entityId $entityId");
      }
    }

    return sliverWidgets.length < 1
        ? gd.emptySliver
        : SliverPadding(
            padding: EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    isCamera ? gd.layoutCameraCount : gd.layoutButtonCount,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: aspectRatio,
              ),
              delegate: SliverChildListDelegate(
                sliverWidgets,
              ),
            ),
          );
  }
}

class SliverEntitiesEdit extends StatelessWidget {
  final int roomIndex;
  final int itemPerRow;
  final List<Entity> entities;
  final bool clickToAdd;
  final Color borderColor;

  const SliverEntitiesEdit({
    @required this.roomIndex,
    @required this.itemPerRow,
    @required this.clickToAdd,
    @required this.entities,
    @required this.borderColor,
  });
  @override
  Widget build(BuildContext context) {
    if (entities.length < 1) {
      return gd.emptySliver;
    }
    return SliverPadding(
      padding: EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemPerRow,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: itemPerRow == 1 ? 8 / 5 : 8 / 5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return itemPerRow == 1
                ? EntityCamera(
                    entityId: entities[index].entityId,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onTapCallback");

                      if (!clickToAdd) {
                        gd.removeEntityInRoom(
                            entities[index].entityId,
                            roomIndex,
                            entities[index].getOverrideName,
                            context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].getOverrideName, context);
                      }
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onLongPressCallback");

                      if (!clickToAdd) {
                        gd.removeEntityInRoom(
                            entities[index].entityId,
                            roomIndex,
                            entities[index].getOverrideName,
                            context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].getOverrideName, context);
                      }
                    },
                  )
                : EntityButton(
                    entityId: entities[index].entityId,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onTapCallback");

                      if (!clickToAdd) {
                        gd.removeEntityInRoom(entities[index].entityId,
                            roomIndex, entities[index].friendlyName, context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].friendlyName, context);
                      }
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onLongPressCallback");
                      if (!clickToAdd) {
                        gd.removeEntityInRoom(entities[index].entityId,
                            roomIndex, entities[index].friendlyName, context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].friendlyName, context);
                      }
                    },
                  );
          },
          childCount: entities.length,
        ),
      ),
    );
  }
}

class SliverEntitiesSort extends StatelessWidget {
  final int roomIndex;
  final int rowNumber;
  final bool isCamera;
  final double aspectRatio;

  final List<String> entities;

  const SliverEntitiesSort({
    @required this.roomIndex,
    @required this.rowNumber,
    @required this.isCamera,
    @required this.aspectRatio,
    @required this.entities,
  });

  @override
  Widget build(BuildContext context) {
    if (entities.length < 2) {
      return SliverEntitiesNormal(
        roomIndex: roomIndex,
        entities: entities,
        isCamera: isCamera,
        aspectRatio: aspectRatio,
      );
    }

    var totalWidth = gd.mediaQueryWidth;

    var totalItemPerRow =
        isCamera ? gd.layoutCameraCount : gd.layoutButtonCount;
    if (totalItemPerRow < 1) totalItemPerRow = 1;
    var totalSpaceBetween = 8 * totalItemPerRow - 1;
    var width = (totalWidth - totalSpaceBetween - 8 * 2) / totalItemPerRow;
//    log.d(
//        "gd.mediaQueryWidth ${gd.mediaQueryWidth} totalWidth $totalWidth  totalItemPerRow $totalItemPerRow");
    List<Widget> entityShape = [];
    List<String> entityIdFiltered = [];
    for (String entityId in entities) {
//      log.d("SliverEntitiesSort entityId $entityId");
      if (!entityId.contains("WebView") && gd.entities[entityId] == null)
        continue;

      entityIdFiltered.add(entityId);

      Widget widget = Container(
        width: width,
        height: width * 1 / aspectRatio,
        child: entityId.contains("WebView")
            ? WebView(
                webViewsId: entityId,
              )
            : entityId.contains("camera.")
                ? EntityCamera(
                    entityId: entityId,
                    onTapCallback: null,
                    onLongPressCallback: null)
                : EntityButton(
                    entityId: entityId,
                    onTapCallback: null,
                    onLongPressCallback: null,
                  ),
      );

      entityShape.add(widget);
    }

    void _onReorder(int oldIndex, int newIndex) {
      String oldEntityId = entityIdFiltered[oldIndex];
      String newEntityId = entityIdFiltered[newIndex];
      log.w(
          "_onReorder oldIndex $oldIndex newIndex $newIndex roomIndex $roomIndex rowNumber $rowNumber oldEntityId $oldEntityId newEntityId $newEntityId \n$entities");
      gd.roomEntitySort(roomIndex, rowNumber, oldEntityId, newEntityId);
    }

    var wrap = ReorderableWrap(
      needsLongPressDraggable: false,
      spacing: 8,
      runSpacing: 8,
      padding: const EdgeInsets.all(0),
      children: entityShape,
      onReorder: _onReorder,
      onNoReorder: (int index) {
        //this callback is optional
        log.w("reorder cancelled. index: $index");
      },
      onReorderStarted: (int index) {
        //this callback is optional
        log.w("reorder started. index: $index");
        gd.delayCancelSortModeTimer(300);
      },
    );

//    var wrapCentered = Center(
//      child: wrap,
//    );

    return SliverPadding(
      padding: EdgeInsets.all(8),
      sliver: SliverList(
        delegate: SliverChildListDelegate([wrap]),
      ),
    );
  }
}
