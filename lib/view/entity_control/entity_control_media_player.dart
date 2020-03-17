import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/entity.dart';
import 'package:provider/provider.dart';

class EntityControlMediaPlayer extends StatelessWidget {
  final String entityId;
  const EntityControlMediaPlayer({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) => "${generalData.entities[entityId].state} "
          "${generalData.entities[entityId].volumeLevel} "
          "${generalData.entities[entityId].isVolumeMuted} "
          "${generalData.entities[entityId].mediaContentType} "
          "${generalData.entities[entityId].mediaTitle} "
          "${generalData.entities[entityId].mediaArtist} "
          "${generalData.entities[entityId].entityPicture} "
          "${generalData.entities[entityId].source} "
          "${generalData.entities[entityId].sourceList.length} "
          "${generalData.entities[entityId].soundMode} "
          "${generalData.entities[entityId].soundModeList.length} "
          "${generalData.entities[entityId].soundModeRaw} "
          "${generalData.entities[entityId].mediaPosition} "
          "${generalData.entities[entityId].mediaDuration} "
          "",
      builder: (_, generalData, __) {
        Entity entity = gd.entities[entityId];
        return Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MediaPlayerButton(
                entityId: entityId,
                buttonData: ButtonData(
                  showWhen: entity != null &&
                      !entity.isStateOn &&
                      entity.getSupportedFeaturesMediaPlayer
                          .contains("SUPPORT_TURN_ON"),
                  disableOnPowerOff: false,
                  icon: "mdi:power",
                  iconColor: ThemeInfo.colorIconInActive,
                  iconSize: 200,
                  json: jsonEncode(
                    {
                      "service": "turn_on",
                      "service_data": {
                        "entity_id": entityId,
                      }
                    },
                  ),
                ),
              ),
              entity.entityPicture != "" &&
                      entity.entityPicture != "null" &&
                      entity.mediaTitle != "null" &&
                      entity.mediaArtist != "null"
                  ? FittedBox(
                      child: Container(
                        height: entity.sourceList.length > 1 ||
                                entity.soundModeList.length > 1
                            ? gd.mediaQueryHeight / 3
                            : gd.mediaQueryHeight / 2,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  entity.entityPicture.contains("http")
                                      ? '${entity.entityPicture}'
                                      : '${gd.currentUrl + entity.entityPicture}',
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SpinKitThreeBounce(
                                        size: 40,
                                        color: ThemeInfo.colorIconActive
                                            .withOpacity(0.5),
                                      ),
//                                    child: CircularProgressIndicator(
//                                      value: loadingProgress
//                                                  .expectedTotalBytes !=
//                                              null
//                                          ? loadingProgress
//                                                  .cumulativeBytesLoaded /
//                                              loadingProgress.expectedTotalBytes
//                                          : null,
//                                    ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              child: AutoSizeText(
                                "${gd.textToDisplay(entity.mediaTitle)} - ${gd.textToDisplay(entity.mediaArtist)}",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),

              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  entity.sourceList.length > 1
                      ? Expanded(child: MediaPlayerSource(entityId: entityId))
                      : Container(),
                  entity.soundModeList.length > 1
                      ? Expanded(
                          child: MediaPlayerSoundMode(entityId: entityId))
                      : Container(),
                ],
              ),
              // Row(
              //   mainAxisSize: MainAxisSize.max,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Text(entity.mediaPosition.toString()),
              //     Text("/"),
              //     Text(entity.mediaDuration.toString())
              //   ],
              // ),
              MpSeekSlider(entityId: entityId),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MediaPlayerButton(
                    entityId: entityId,
                    buttonData: ButtonData(
                      showWhen: entity != null &&
                          entity.isStateOn &&
                          entity.getSupportedFeaturesMediaPlayer
                              .contains("SUPPORT_TURN_OFF"),
                      icon: "mdi:power",
                      json: jsonEncode(
                        {
                          "service": "turn_off",
                          "service_data": {
                            "entity_id": entityId,
                          }
                        },
                      ),
                    ),
                  ),
                  MpVolumeSlider(entityId: entityId),
                  MediaPlayerButton(
                    entityId: entityId,
                    buttonData: ButtonData(
                      showWhen: entity != null &&
                          !entity.isVolumeMuted &&
                          entity.getSupportedFeaturesMediaPlayer
                              .contains("SUPPORT_VOLUME_MUTE"),
                      icon: "mdi:volume-high",
                      json: jsonEncode(
                        {
                          "service": "volume_mute",
                          "service_data": {
                            "entity_id": entityId,
                            "is_volume_muted": true,
                          }
                        },
                      ),
                    ),
                  ),
                  MediaPlayerButton(
                    entityId: entityId,
                    buttonData: ButtonData(
                      showWhen: entity != null &&
                          entity.isVolumeMuted &&
                          entity.getSupportedFeaturesMediaPlayer
                              .contains("SUPPORT_VOLUME_MUTE"),
                      icon: "mdi:volume-off",
                      iconColor: ThemeInfo.colorIconInActive,
                      json: jsonEncode(
                        {
                          "service": "volume_mute",
                          "service_data": {
                            "entity_id": entityId,
                            "is_volume_muted": false,
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
//                          SUPPORT_VOLUME_STEP volume_down
//                        MediaPlayerButton(
//                          entityId: entityId,
//                          buttonData: ButtonData(
//                            showWhen: entity != null &&
//                                entity.isStateOn &&
//                                entity.getSupportedFeaturesMediaPlayer
//                                    .contains("SUPPORT_VOLUME_STEP"),
//                            icon: "mdi:volume-medium",
//                            json: jsonEncode(
//                              {
//                                "service": "volume_down",
//                                "service_data": {
//                                  "entity_id": entityId,
//                                }
//                              },
//                            ),
//                          ),
//                        ),
                        //SUPPORT_PREVIOUS_TRACK
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_PREVIOUS_TRACK"),
                            icon: "mdi:skip-previous-circle",
                            json: jsonEncode(
                              {
                                "service": "media_previous_track",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
                        //SUPPORT_STOP
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_STOP") &&
                                !entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_PAUSE"),
                            icon: "mdi:stop-circle",
                            json: jsonEncode(
                              {
                                "service": "media_stop",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
                        //SUPPORT_PAUSE
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.state == "playing" &&
                                entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_PAUSE"),
                            icon: "mdi:pause-circle",
                            json: jsonEncode(
                              {
                                "service": "media_pause",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
                        //SUPPORT_PLAY_MEDIA
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.state != "playing" &&
                                (entity.getSupportedFeaturesMediaPlayer
                                        .contains("SUPPORT_PLAY_MEDIA") ||
                                    entity.getSupportedFeaturesMediaPlayer
                                        .contains("SUPPORT_PLAY")),
                            icon: "mdi:play-circle",
                            json: jsonEncode(
                              {
                                "service": "media_play",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
                        //SUPPORT_NEXT_TRACK
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_NEXT_TRACK"),
                            icon: "mdi:skip-next-circle",
                            json: jsonEncode(
                              {
                                "service": "media_next_track",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
                        //SUPPORT_CLEAR_PLAYLIST
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_CLEAR_PLAYLIST"),
                            icon: "mdi:playlist-remove",
                            json: jsonEncode(
                              {
                                "service": "clear_playlist",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
//                        //SUPPORT_VOLUME_STEP volume_up
//                        MediaPlayerButton(
//                          entityId: entityId,
//                          buttonData: ButtonData(
//                            showWhen: entity != null &&
//                                entity.isStateOn &&
//                                entity.getSupportedFeaturesMediaPlayer
//                                    .contains("SUPPORT_VOLUME_STEP"),
//                            icon: "mdi:volume-high",
//                            json: jsonEncode(
//                              {
//                                "service": "volume_up",
//                                "service_data": {
//                                  "entity_id": entityId,
//                                }
//                              },
//                            ),
//                          ),
//                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ButtonData {
  bool showWhen;
  bool disableOnPowerOff;
  String icon;
  String json;
  double iconSize;
  Color iconColor;

  ButtonData({
    @required this.showWhen,
    @required this.icon,
    @required this.json,
    this.disableOnPowerOff = true,
    this.iconSize = 40,
    this.iconColor = ThemeInfo.colorIconActive,
  });
}

class MediaPlayerButton extends StatelessWidget {
  final String entityId;
  final ButtonData buttonData;

  const MediaPlayerButton({
    @required this.entityId,
    @required this.buttonData,
  });

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[entityId];
    if (entity == null) return Container();
    if (!buttonData.showWhen ||
        buttonData.disableOnPowerOff && !entity.isStateOn) return Container();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: buttonData.iconSize,
        icon: Icon(
          MaterialDesignIcons.getIconDataFromIconName(buttonData.icon),
        ),
        color: buttonData.iconColor,
        onPressed: () {
          Map<String, dynamic> jsonCombined = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "media_player",
          };
          Map<String, dynamic> buttonDataJson = jsonDecode(buttonData.json);
          jsonCombined.addAll(buttonDataJson);
//              log.d("jsonCombined $jsonCombined");
          var message = jsonEncode(jsonCombined);
          gd.sendSocketMessage(message);
          if (jsonCombined.toString().contains("turn_on"))
            entity.state = "turning on...";
          if (jsonCombined.toString().contains("turn_off"))
            entity.state = "turning off...";
        },
      ),
    );
  }
}

class MpSeekSlider extends StatefulWidget {
  final String entityId;

  const MpSeekSlider({@required this.entityId});

  @override
  _MpSeekSliderState createState() => _MpSeekSliderState();
}

class _MpSeekSliderState extends State<MpSeekSlider> {
  Entity entity;
  bool supportSeekSet;
  DateTime isSeeking;
  double currentPosition = 0.0;
  double mediaPositionLast;
  Timer timerPeriodic;
  @override
  void initState() {
    super.initState();

    //1000/60=17 mean refresh 60 fps
    const Duration refreshTime = const Duration(milliseconds: 17);
    isSeeking = DateTime.now();
    entity = gd.entities[widget.entityId];

    if (entity != null &&
        entity.getSupportedFeaturesMediaPlayer.contains("SUPPORT_SEEK")) {
      timerPeriodic = Timer.periodic(refreshTime, (Timer t) {
        if (isSeeking.isBefore(DateTime.now()) &&
            entity != null &&
            gd.entities[widget.entityId].state == "playing") {
          setState(() {
            currentPosition =
                currentPosition + refreshTime.inMilliseconds / 1000;
            currentPosition = currentPosition.clamp(0, entity.mediaDuration);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    if (timerPeriodic != null) {
      timerPeriodic.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    entity = gd.entities[widget.entityId];
    if (entity == null) return Container();

    supportSeekSet =
        entity.getSupportedFeaturesMediaPlayer.contains("SUPPORT_SEEK");
    if (!entity.isStateOn ||
        !supportSeekSet ||
        entity.mediaPosition == null ||
        entity.mediaPosition < 0 ||
        entity.mediaDuration == null ||
        entity.mediaDuration < 0) return Container();

    if (mediaPositionLast != entity.mediaPosition) {
      mediaPositionLast = entity.mediaPosition;
      currentPosition = entity.mediaPosition;
      log.e(
          "mediaPositionLast != entity.mediaPosition mediaPositionLast $mediaPositionLast entity.mediaPosition ${entity.mediaPosition}");
      currentPosition = currentPosition.clamp(0, entity.mediaDuration);
    }

    var songDurationInt = Duration(seconds: entity.mediaDuration.toInt());
    var songDurationLabel =
        "${songDurationInt.inMinutes.remainder(60).toString().padLeft(2, '0')}:${songDurationInt.inSeconds.remainder(60).toString().padLeft(2, '0')}";

    var currentPositionInt = Duration(seconds: currentPosition.toInt());
    var currentPositionLabel =
        "${currentPositionInt.inMinutes.remainder(60).toString().padLeft(2, '0')}:${currentPositionInt.inSeconds.remainder(60).toString().padLeft(2, '0')}";

    return Row(
      children: <Widget>[
        Container(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
            child: Text("$currentPositionLabel")),
        Expanded(
          child: Slider(
            value: currentPosition,
            min: 0.0,
            max: entity.mediaDuration,
            divisions: 1000,
            label: "$currentPositionLabel",
            onChangeStart: (val) {
              isSeeking = DateTime.now().add(Duration(days: 1));
            },
            onChangeEnd: (val) {
              currentPosition = val.clamp(0, entity.mediaDuration);
              var outMsg = {
                "id": gd.socketId,
                "type": "call_service",
                "domain": "media_player",
                "service": "media_seek",
                "service_data": {
                  "entity_id": widget.entityId,
                  "seek_position": currentPosition
                }
              };
              entity.mediaPosition = currentPosition;
              gd.sendSocketMessage(jsonEncode(outMsg));
              isSeeking = DateTime.now().subtract(Duration(days: 1));
            },
            onChanged: (val) {
              setState(
                () {
                  currentPosition = val;
                  isSeeking = DateTime.now().add(Duration(days: 1));
                },
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
          child: Text("$songDurationLabel"),
        ),
      ],
    );
  }
}

class MpVolumeSlider extends StatefulWidget {
  final String entityId;

  const MpVolumeSlider({@required this.entityId});

  @override
  _MpVolumeSliderState createState() => _MpVolumeSliderState();
}

class _MpVolumeSliderState extends State<MpVolumeSlider> {
  double volume;
  Entity entity;
  double volumeLast;
  bool supportVolumeSet;
  DateTime isChanging;

  @override
  void initState() {
    super.initState();
    entity = gd.entities[widget.entityId];
    volume = entity.volumeLevel;
    isChanging = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    entity = gd.entities[widget.entityId];
    supportVolumeSet =
        entity.getSupportedFeaturesMediaPlayer.contains("SUPPORT_VOLUME_SET");
    if (!entity.isStateOn || !supportVolumeSet) return Container();

    if (isChanging.isBefore(DateTime.now())) {
      volume = entity.volumeLevel;
    }
    return Expanded(
      child: Slider(
        value: volume,
        min: 0.0,
        max: 1.0,
        divisions: 20,
        label: "${(volume * 100).toInt()}",
        onChangeStart: (val) {
          isChanging = DateTime.now().add(Duration(days: 1));
        },
        onChangeEnd: (val) {
          if (val == volumeLast) return;
          var outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "media_player",
            "service": "volume_set",
            "service_data": {"entity_id": widget.entityId, "volume_level": val}
          };
          entity.volumeLevel = val;
          volumeLast = val;
          gd.sendSocketMessage(jsonEncode(outMsg));
          isChanging = DateTime.now().add(Duration(seconds: 1));
        },
        onChanged: !entity.isStateOn
            ? null
            : (val) {
                setState(() {
                  volume = val;
                  isChanging = DateTime.now().add(Duration(days: 1));
                });
              },
      ),
    );
  }
}

class MediaPlayerSource extends StatelessWidget {
  final String entityId;
  const MediaPlayerSource({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[entityId];

    if (entity == null || entity.sourceList.length <= 1) return Container();

    log.d("entity.sourceList ${entity.sourceList}");
    log.d("entity.source ${entity.source}");

    var index = entity.sourceList.indexOf(entity.source);
    log.d("index $index");

    var sourceModeController = FixedExtentScrollController(initialItem: index);

    List<Widget> sourceList = [];

    for (String source in entity.sourceList) {
      var container = Container(
        alignment: entity.soundModeList.length > 1
            ? Alignment.centerRight
            : Alignment.center,
        child: (AutoSizeText(
          source,
          style: Theme.of(context).textTheme.bodyText2,
          maxLines: 1,
        )),
      );
      sourceList.add(container);
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
//          color: ThemeInfo.pickerActivateStyle.color,
          width: 1.0,
        ),
      ),
      margin: EdgeInsets.all(1),
      child: Column(
        children: <Widget>[
//          Container(
//            width: double.infinity,
//            alignment: Alignment.center,
//            decoration: BoxDecoration(
//                color: ThemeInfo.colorIconActive.withOpacity(1),
//                borderRadius: BorderRadius.only(
//                  topLeft: Radius.circular(8),
//                  topRight: entity.soundModeList.length > 0
//                      ? Radius.circular(0)
//                      : Radius.circular(8),
//                )),
//            padding: EdgeInsets.all(4),
//            child: AutoSizeText(
//              "Source",
//              style: Theme.of(context).textTheme.bodyText2,
//              maxLines: 1,
//              overflow: TextOverflow.ellipsis,
//            ),
//          ),
          Container(
            height: 128,
            margin: EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.5),
                  ]),
            ),
            child: CupertinoPicker(
              squeeze: 1.45,
              diameterRatio: 1.1,
              offAxisFraction: entity.soundModeList.length > 1 ? -0.5 : 0,
              scrollController: sourceModeController,
              magnification: 1,
              backgroundColor: Colors.transparent,
              children: sourceList,
              itemExtent: 32, //height of each item
              looping: true,
              onSelectedItemChanged: (covariant) {
                log.d("onSelectedItemChanged $covariant");
                var outMsg = {
                  "id": gd.socketId,
                  "type": "call_service",
                  "domain": "media_player",
                  "service": "select_source",
                  "service_data": {
                    "entity_id": entityId,
                    "source": entity.sourceList[covariant]
                  }
                };
                var message = jsonEncode(outMsg);
                gd.sendSocketMessageDelay(message, 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MediaPlayerSoundMode extends StatelessWidget {
  final String entityId;
  const MediaPlayerSoundMode({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[entityId];
    if (entity == null || entity.soundModeList.length <= 1) return Container();

    log.d("entity.soundModeList ${entity.soundModeList}");
    log.d("entity.soundMode ${entity.soundMode}");
    var index = entity.soundModeList.indexOf(entity.soundMode);
    log.d("index $index");

    var soundModeController = FixedExtentScrollController(initialItem: index);

    List<Widget> sourceList = [];

    for (String source in entity.soundModeList) {
      var container = Container(
        alignment: entity.sourceList.length > 1
            ? Alignment.centerLeft
            : Alignment.center,
        child: (AutoSizeText(
          source,
          style: Theme.of(context).textTheme.bodyText2,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )),
      );
      sourceList.add(container);
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
//          color: ThemeInfo.pickerActivateStyle.color,
          width: 1.0,
        ),
      ),
      margin: EdgeInsets.all(1),
      child: Column(
        children: <Widget>[
//          Container(
//            width: double.infinity,
//            alignment: Alignment.center,
//            decoration: BoxDecoration(
//                color: ThemeInfo.colorIconActive.withOpacity(1),
//                borderRadius: BorderRadius.only(
//                  topLeft: entity.sourceList.length > 0
//                      ? Radius.circular(0)
//                      : Radius.circular(8),
//                  topRight: Radius.circular(8),
//                )),
//            padding: EdgeInsets.all(4),
//            child: AutoSizeText(
//              "Sound Modes",
//              style: Theme.of(context).textTheme.bodyText2,
//              maxLines: 1,
//              overflow: TextOverflow.ellipsis,
//            ),
//          ),
          Container(
            height: 128,
            margin: EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.5),
                  ]),
            ),
            child: CupertinoPicker(
              squeeze: 1.45,
              diameterRatio: 1.1,
              offAxisFraction: entity.sourceList.length > 1 ? 0.5 : 0,
              scrollController: soundModeController,
              magnification: 1,
              backgroundColor: Colors.transparent,
              children: sourceList,
              itemExtent: 32, //height of each item
              looping: true,

              onSelectedItemChanged: (covariant) {
                log.d("onSelectedItemChanged $covariant");
                var outMsg = {
                  "id": gd.socketId,
                  "type": "call_service",
                  "domain": "media_player",
                  "service": "select_sound_mode",
                  "service_data": {
                    "entity_id": entityId,
                    "sound_mode": entity.soundModeList[covariant]
                  }
                };
                var message = jsonEncode(outMsg);
                gd.sendSocketMessageDelay(message, 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}
