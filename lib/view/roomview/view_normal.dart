import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/model/entity.dart';
import 'package:hasskit/view/slivers/sliver_entities.dart';
import 'package:hasskit/view/slivers/sliver_entity_status_running.dart';
import 'package:hasskit/view/slivers/sliver_header.dart';
import 'package:hasskit/view/slivers/sliver_navigation_bar.dart';

class ViewNormal extends StatelessWidget {
  final int roomIndex;
  const ViewNormal({@required this.roomIndex});

  @override
  Widget build(BuildContext context) {
//    log.w("Widget build CustomScrollViewNormal");

    var row1 = entityFilterByRow(roomIndex, 1, false);
    var row1Cam = entityFilterByRow(roomIndex, 1, true);
    var row2 = entityFilterByRow(roomIndex, 2, false);
    var row2Cam = entityFilterByRow(roomIndex, 2, true);
    var row3 = entityFilterByRow(roomIndex, 3, false);
    var row3Cam = entityFilterByRow(roomIndex, 3, true);
    var row4 = entityFilterByRow(roomIndex, 4, false);
    var row4Cam = entityFilterByRow(roomIndex, 4, true);

//    log.d("row1 ${row1.length} "
//        "row1Cam ${row1Cam.length} "
//        "row2 ${row2.length} "
//        "row2Cam ${row2Cam.length} "
//        "row3 ${row3.length} "
//        "row3Cam ${row3Cam.length} "
//        "row4 ${row4.length} "
//        "row4Cam ${row4Cam.length} "
//        "");

//    bool showAddFirstButton = false;
//    if (row1.length +
//            row1Cam.length +
//            row2.length +
//            row2Cam.length +
//            row3.length +
//            row3Cam.length +
//            row4.length +
//            row4Cam.length <
//        1) {
//      showAddFirstButton = true;
////      log.d("showAddFirstButton $showAddFirstButton");
//    }

    return CustomScrollView(
      controller: gd.viewNormalController,
      slivers: [
        SliverNavigationBar(roomIndex: roomIndex),
        SliverEntityStatusRunning(),
//        showAddFirstButton
//            ? SliverPadding(
//                padding: EdgeInsets.all(12),
//                sliver: SliverGrid(
//                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                    crossAxisCount: gd.layoutCameraCount,
//                    mainAxisSpacing: 8.0,
//                    crossAxisSpacing: 10.0,
//                    childAspectRatio: 1,
//                  ),
//                  delegate: SliverChildBuilderDelegate(
//                    (BuildContext context, int index) {
//                      return Container(
//                        decoration: BoxDecoration(
//                          borderRadius: BorderRadius.circular(8),
//                          color: ThemeInfo.colorEntityBackground,
//                        ),
//                        child: Opacity(
//                          opacity: 0.5,
//                          child: IconButton(
//                            iconSize: 60 * 3 / gd.layoutCameraCount,
//                            onPressed: () {
//                              gd.viewMode = ViewMode.edit;
//                            },
//                            icon: Icon(
//                              Icons.add_circle,
//                            ),
//                          ),
//                        ),
//                      );
//                    },
//                    childCount: 1,
//                  ),
//                ),
//              )
//            : gd.emptySliver,
//        SliverFixedExtentList(
//          itemExtent: 10,
//          delegate: SliverChildListDelegate(
//            [Container()],
//          ),
//        ),
        row1.length + row1Cam.length > 0
            ? SliverHeaderNormal(
                icon: Icon(Icons.looks_one),
                title: gd.roomList[roomIndex].row1Name)
            : gd.emptySliver,
        row1.length > 0
            ? SliverEntitiesNormal(
                roomIndex: roomIndex,
                aspectRatio: gd.buttonRatio,
                isCamera: false,
                entities: row1,
              )
            : gd.emptySliver,
        row1Cam.length > 0
            ? SliverEntitiesNormal(
                roomIndex: roomIndex,
                aspectRatio: 8 / 5,
                isCamera: true,
                entities: row1Cam,
              )
            : gd.emptySliver,
        row2.length + row2Cam.length > 0
            ? SliverHeaderNormal(
                icon: Icon(Icons.looks_two),
                title: gd.roomList[roomIndex].row2Name)
            : gd.emptySliver,
        row2.length > 0
            ? SliverEntitiesNormal(
                roomIndex: roomIndex,
                aspectRatio: gd.buttonRatio,
                isCamera: false,
                entities: row2,
              )
            : gd.emptySliver,
        row2Cam.length > 0
            ? SliverEntitiesNormal(
                roomIndex: roomIndex,
                aspectRatio: 8 / 5,
                isCamera: true,
                entities: row2Cam,
              )
            : gd.emptySliver,
        row3.length + row3Cam.length > 0
            ? SliverHeaderNormal(
                icon: Icon(Icons.looks_3),
                title: gd.roomList[roomIndex].row3Name)
            : gd.emptySliver,
        row3.length > 0
            ? SliverEntitiesNormal(
                roomIndex: roomIndex,
                aspectRatio: gd.buttonRatio,
                isCamera: false,
                entities: row3,
              )
            : gd.emptySliver,
        row3Cam.length > 0
            ? SliverEntitiesNormal(
                roomIndex: roomIndex,
                aspectRatio: 8 / 5,
                isCamera: true,
                entities: row3Cam,
              )
            : gd.emptySliver,
        row4.length + row4Cam.length > 0
            ? SliverHeaderNormal(
                icon: Icon(Icons.looks_4),
                title: gd.roomList[roomIndex].row4Name)
            : gd.emptySliver,
        row4.length > 0
            ? SliverEntitiesNormal(
                roomIndex: roomIndex,
                aspectRatio: gd.buttonRatio,
                isCamera: false,
                entities: row4,
              )
            : gd.emptySliver,
        row4Cam.length > 0
            ? SliverEntitiesNormal(
                roomIndex: roomIndex,
                aspectRatio: 8 / 5,
                isCamera: true,
                entities: row4Cam,
              )
            : gd.emptySliver,
        SliverSafeArea(sliver: gd.emptySliver),
      ],
    );
  }

  List<Entity> entityFilter(int roomIndex, List<EntityType> types) {
    List<String> roomEntities = gd.roomList[roomIndex].row2;
    List<Entity> entitiesFilter = [];

    for (String entityId in roomEntities) {
      var entity = gd.entities[entityId];
      if (entity != null && types.contains(entity.entityType)) {
        entitiesFilter.add(entity);
      }
    }

    return entitiesFilter;
  }

  List<Entity> entityFrontRow(int roomIndex) {
    List<String> frontRowEntities = gd.roomList[roomIndex].row1;
    List<Entity> entitiesFilter = [];

    for (String entityId in frontRowEntities) {
      var entity = gd.entities[entityId];
      if (entity != null && entity.entityType != EntityType.cameras) {
        entitiesFilter.add(entity);
      }
    }

    return entitiesFilter;
  }

  List<Entity> entityFrontRowCamera(int roomIndex) {
    List<String> frontRowEntities = gd.roomList[roomIndex].row1;
    List<Entity> entitiesFilter = [];

    for (String entityId in frontRowEntities) {
      var entity = gd.entities[entityId];
      if (entity != null && entity.entityType == EntityType.cameras) {
        entitiesFilter.add(entity);
      }
    }

    return entitiesFilter;
  }
}

List<String> webViewByRow(int roomIndex, int rowNumber) {
  List<String> webViews = [];

  switch (rowNumber) {
    case 1:
      {
        for (int i = 0; i < gd.webViewSupportMax; i++) {
          if (gd.roomList[roomIndex].row1.contains("WebView${i + 1}")) {
            webViews.add("WebView${i + 1}");
          }
        }
      }
      break;
    case 2:
      {
        for (int i = 0; i < gd.webViewSupportMax; i++) {
          if (gd.roomList[roomIndex].row2.contains("WebView${i + 1}")) {
            webViews.add("WebView${i + 1}");
          }
        }
      }
      break;
    case 3:
      {
        for (int i = 0; i < gd.webViewSupportMax; i++) {
          if (gd.roomList[roomIndex].row3.contains("WebView${i + 1}")) {
            webViews.add("WebView${i + 1}");
          }
        }
      }
      break;
    case 4:
      {
        for (int i = 0; i < gd.webViewSupportMax; i++) {
          if (gd.roomList[roomIndex].row4.contains("WebView${i + 1}")) {
            webViews.add("WebView${i + 1}");
          }
        }
      }
      break;
    default:
      {
        for (int i = 0; i < gd.webViewSupportMax; i++) {
          if (gd.roomList[roomIndex].row1.contains("WebView${i + 1}")) {
            webViews.add("WebView${i + 1}");
          }
        }
      }
      break;
  }

  return webViews;
}

List<String> entityFilterByRow(int roomIndex, int rowNumber, bool isCamera) {
  List<String> roomRowEntities = [];

  switch (rowNumber) {
    case 1:
      {
        roomRowEntities = gd.roomList[roomIndex].row1;
      }
      break;
    case 2:
      {
        roomRowEntities = gd.roomList[roomIndex].row2;
      }
      break;
    case 3:
      {
        roomRowEntities = gd.roomList[roomIndex].row3;
      }
      break;
    case 4:
      {
        roomRowEntities = gd.roomList[roomIndex].row4;
      }
      break;
    default:
      {
        roomRowEntities = gd.roomList[roomIndex].row1;
      }
      break;
  }

  List<String> entitiesFilter = [];
  for (String entityId in roomRowEntities) {
    if (!entityId.contains("WebView") && gd.entities[entityId] == null)
      continue;

    bool containCamera =
        entityId.contains("camera.") || entityId.contains("WebView");
//
//    if (containCamera) {
//      log.w("containCamera $entityId");
//    }

    if (isCamera && containCamera || !isCamera && !containCamera) {
      entitiesFilter.add(entityId);
    }
  }

  return entitiesFilter;
}
