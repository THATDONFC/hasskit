import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/web_socket.dart';
import 'package:intl/intl.dart';

enum EntityType {
  lightSwitches,
  climateFans,
  cameras,
  mediaPlayers,
  group,
  accessories,
  scriptAutomation,
}

class Entity {
  final String entityId;
  String deviceClass;
  String friendlyName;
  String icon;
  String state;
  //climate
  List<String> hvacModes;
  double minTemp;
  double maxTemp;
  double targetTempStep;
  double currentTemperature;
  double temperature;
  String fanMode;
  List<String> fanModes;
  String lastOnOperation;
  int deviceCode;
  String manufacturer;
//Fan
  List<String> speedList;
  bool oscillating;
  String speed;
  int angle;
  //Light
  int supportedFeatures;
  double brightness;
  List<int> rgbColor;
  int minMireds;
  int maxMireds;
  int colorTemp;
  String effect;
  List<String> effectList;
  //cover
  double currentPosition;
  //input_number
  double initial;
  double min;
  double max;
  double step;
  //media_player
  double volumeLevel;
  double mediaDuration;
  double mediaPosition;
  bool isVolumeMuted;
  String mediaContentType;
  String mediaTitle;
  String mediaArtist;
  String source;
  List<String> sourceList;
  String soundMode;
  List<String> soundModeList;
  String soundModeRaw;
  String entityPicture;
  String unitOfMeasurement;
  //vacuum
  String fanSpeed;
  List<String> fanSpeedList;
  //state string
  String oldState;
  String newState;
  //netatmo climate
  String presetMode;
  List<String> presetModes;
  //gps
  double latitude;
  double longitude;
  //input_select
  List<String> options;
  bool hidden;
  //water_heater
  String awayMode;
  String operationMode;
  List<String> operationList;

  Entity({
    this.entityId,
    this.deviceClass,
    this.friendlyName,
    this.icon,
    this.state,
    //climate
    this.hvacModes,
    this.minTemp,
    this.maxTemp,
    this.targetTempStep,
    this.currentTemperature,
    this.temperature,
    this.fanMode,
    this.fanModes,
    this.deviceCode,
    this.manufacturer,
    //fan
    this.speedList,
    this.oscillating,
    this.speed,
    this.angle,
    //light
    this.supportedFeatures,
    this.brightness,
    this.rgbColor,
    this.minMireds,
    this.maxMireds,
    this.colorTemp,
    this.effect,
    this.effectList,
    //cover
    this.currentPosition,
    //intput_number
    this.initial,
    this.min,
    this.max,
    this.step,
//    media_player
    this.volumeLevel = 0,
    this.mediaDuration = -1,
    this.mediaPosition = -1,
    this.isVolumeMuted = false,
    this.mediaContentType = "",
    this.mediaTitle = "",
    this.mediaArtist = "",
    this.source = "",
    this.sourceList,
    this.soundMode = "",
    this.soundModeList,
    this.soundModeRaw = "",
    this.entityPicture = "",
    //
    this.unitOfMeasurement = "",
    //vacuum
    this.fanSpeed,
    this.fanSpeedList,
    //netatmo climate
    this.presetMode,
    this.presetModes,
    //gps
    this.latitude,
    this.longitude,
    //input_select
    this.options,
    this.hidden = false,
    //water_heater
    this.awayMode,
    this.operationMode,
    this.operationList,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    try {
      if (json['entity_id'] == null) {
        return null;
      }
      return Entity(
        entityId: json['entity_id'].toString(),
        deviceClass: json['attributes']['device_class'].toString() != null
            ? json['attributes']['device_class'].toString()
            : "",
        icon: json['attributes']['icon'].toString() != null
            ? json['attributes']['icon'].toString()
            : "",
        friendlyName: json['attributes']['friendly_name'].toString() != null
            ? json['attributes']['friendly_name'].toString()
            : json['entity_id'].toString(),
        state: json['state'].toString(),
        //climate
        hvacModes: json['attributes']['hvac_modes'] != null
            ? List<String>.from(json['attributes']['hvac_modes'])
            : [],
        minTemp:
            double.tryParse(json['attributes']['min_temp'].toString()) != null
                ? double.parse(json['attributes']['min_temp'].toString())
                : 0,
        maxTemp:
            double.tryParse(json['attributes']['max_temp'].toString()) != null
                ? double.parse(json['attributes']['max_temp'].toString())
                : 0,
        targetTempStep: double.tryParse(
                    json['attributes']['target_temp_step'].toString()) !=
                null
            ? double.parse(json['attributes']['target_temp_step'].toString())
            : null,
        temperature:
            double.tryParse(json['attributes']['temperature'].toString()) !=
                    null
                ? double.parse(json['attributes']['temperature'].toString())
                : 0,

        currentTemperature: double.tryParse(
                    json['attributes']['current_temperature'].toString()) !=
                null
            ? double.parse(json['attributes']['current_temperature'].toString())
            : null,
        fanMode: json['attributes']['fan_mode'].toString() != null
            ? json['attributes']['fan_mode'].toString()
            : "",
        fanModes: json['attributes']['fan_modes'] != null
            ? List<String>.from(json['attributes']['fan_modes'])
            : [],
        deviceCode:
            int.tryParse(json['attributes']['device_code'].toString()) != null
                ? int.parse(json['attributes']['device_code'].toString())
                : 0,
        manufacturer: json['attributes']['manufacturer'].toString() != null
            ? json['attributes']['manufacturer'].toString()
            : "",
        //fan
        speedList: json['attributes']['speed_list'] != null
            ? List<String>.from(json['attributes']['speed_list'])
            : [],
        oscillating: json['attributes']['oscillating'] != null
            ? json['attributes']['oscillating']
            : null,
        speed: json['attributes']['speed_level'] != null
            ? json['attributes']['speed_level'].toString()
            : json['attributes']['direct_speed'] != null
                ? json['attributes']['direct_speed'].toString()
                : json['attributes']['speed'] != null
                    ? json['attributes']['speed'].toString()
                    : "Off",

        angle: int.tryParse(json['attributes']['angle'].toString()) != null
            ? int.parse(json['attributes']['angle'].toString())
            : 0,
        //supported_features
        supportedFeatures:
            int.tryParse(json['attributes']['supported_features'].toString()) !=
                    null
                ? int.parse(json['attributes']['supported_features'].toString())
                : 0,
        brightness:
            double.tryParse(json['attributes']['brightness'].toString()) != null
                ? double.parse(json['attributes']['brightness'].toString())
                : null,
        rgbColor: json['attributes']['rgb_color'] != null
            ? List<int>.from(json['attributes']['rgb_color'])
            : [],
        minMireds:
            int.tryParse(json['attributes']['min_mireds'].toString()) != null
                ? int.parse(json['attributes']['min_mireds'].toString())
                : 0,
        maxMireds:
            int.tryParse(json['attributes']['max_mireds'].toString()) != null
                ? int.parse(json['attributes']['max_mireds'].toString())
                : 0,
        colorTemp:
            int.tryParse(json['attributes']['color_temp'].toString()) != null
                ? int.parse(json['attributes']['color_temp'].toString())
                : 0,
        effect: json['attributes']['effect'].toString() != null
            ? json['attributes']['effect'].toString()
            : null,
        effectList: json['attributes']['effect_list'] != null
            ? List<String>.from(json['attributes']['effect_list'])
            : [],
        currentPosition: double.tryParse(
                    json['attributes']['current_position'].toString()) !=
                null
            ? double.parse(json['attributes']['current_position'].toString())
            : null,
        //input_number
        initial:
            double.tryParse(json['attributes']['initial'].toString()) != null
                ? double.parse(json['attributes']['initial'].toString())
                : 0,
        min: double.tryParse(json['attributes']['min'].toString()) != null
            ? double.parse(json['attributes']['min'].toString())
            : 0,
        max: double.tryParse(json['attributes']['max'].toString()) != null
            ? double.parse(json['attributes']['max'].toString())
            : 0,
        step: double.tryParse(json['attributes']['step'].toString()) != null
            ? double.parse(json['attributes']['step'].toString())
            : 0,
        //media_player
        volumeLevel:
            double.tryParse(json['attributes']['volume_level'].toString()) !=
                    null
                ? double.parse(json['attributes']['volume_level'].toString())
                : 0,
        mediaDuration:
            double.tryParse(json["attributes"]["media_duration"].toString()) !=
                    null
                ? double.parse(json["attributes"]["media_duration"].toString())
                : -1,
        mediaPosition:
            double.tryParse(json["attributes"]["media_position"].toString()) !=
                    null
                ? double.parse(json["attributes"]["media_position"].toString())
                : -1,
        isVolumeMuted: json['attributes']['is_volume_muted'] != null
            ? json['attributes']['is_volume_muted']
            : false,
        mediaContentType:
            json['attributes']['media_content_type'].toString() != null
                ? json['attributes']['media_content_type'].toString()
                : "",
        mediaTitle: json['attributes']['media_title'].toString() != null
            ? json['attributes']['media_title'].toString()
            : "",
        mediaArtist: json['attributes']['media_artist'].toString() != null
            ? json['attributes']['media_artist'].toString()
            : "",
        source: json['attributes']['source'].toString() != null
            ? json['attributes']['source'].toString()
            : "",
        sourceList: json['attributes']['source_list'] != null
            ? List<String>.from(json['attributes']['source_list'])
            : [],
        soundMode: json['attributes']['sound_mode'].toString() != null
            ? json['attributes']['sound_mode'].toString()
            : "",
        soundModeList: json['attributes']['sound_mode_list'] != null
            ? List<String>.from(json['attributes']['sound_mode_list'])
            : [],
        soundModeRaw: json['attributes']['sound_mode_raw'].toString() != null
            ? json['attributes']['sound_mode_raw'].toString()
            : "",
        entityPicture: json['attributes']['entity_picture'].toString() != null
            ? json['attributes']['entity_picture'].toString()
            : "",
        unitOfMeasurement: json['attributes']['unit_of_measurement'] != null
            ? json['attributes']['unit_of_measurement'].toString()
            : "",
        fanSpeed: json['attributes']['fan_speed'] != null
            ? json['attributes']['fan_speed'].toString()
            : "",
        fanSpeedList: json['attributes']['fan_speed_list'] != null
            ? List<String>.from(json['attributes']['fan_speed_list'])
            : [],
        presetMode: json['attributes']['preset_mode'] != null
            ? json['attributes']['preset_mode'].toString()
            : null,
        presetModes: json['attributes']['preset_modes'] != null
            ? List<String>.from(json['attributes']['preset_modes'])
            : [],
        latitude:
            double.tryParse(json["attributes"]["latitude"].toString()) != null
                ? double.parse(json["attributes"]["latitude"].toString())
                : 0,
        longitude:
            double.tryParse(json["attributes"]["longitude"].toString()) != null
                ? double.parse(json["attributes"]["longitude"].toString())
                : 0,
        options: json['attributes']['options'] != null
            ? List<String>.from(json['attributes']['options'])
            : [],
        hidden: json['attributes']['hidden'] != null
            ? json['attributes']['hidden']
            : false,
        awayMode: json['attributes']['away_mode'] != null
            ? json['attributes']['away_mode']
            : 'off',
        operationMode: json['attributes']['operation_mode'] != null
            ? json['attributes']['operation_mode']
            : "eco",
        operationList: json['attributes']['operation_list'] != null
            ? List<String>.from(json['attributes']['operation_list'])
            : ["eco"],
      );
    } catch (e) {
      log.e("Entity.fromJson newEntity $e");
      log.e("json $json");
      return null;
    }
  }

  toggleState() {
    log.d("toggleState entityId $entityId");
    var domain = entityId.split('.').first;
    if (domain == "group") domain = "homeassistant";
    var service = '';

    if (entityId == "group.all_covers") {
      domain = 'cover';
      if (isStateOn) {
        this.state = 'closing...';
        service = 'close_cover';
      } else {
        this.state = 'opening...';
        service = 'open_cover';
      }
    } else if (state == 'on' ||
        this.state == 'turning on...' ||
        domain == 'climate' && state != 'off') {
      this.state = 'turning off...';
      service = 'turn_off';
    } else if (state == 'off' || state == 'turning off...') {
      this.state = 'turning on...';
      service = 'turn_on';
    } else if (state == 'open' || state == 'opening...') {
      this.state = 'closing...';
      service = 'close_cover';
    } else if (state == 'closed' || state == 'closing...') {
      this.state = 'opening...';
      service = 'open_cover';
    } else if (state == 'locked' || state == 'locking...') {
      this.state = 'unlocking...';
      domain = "lock";
      service = 'unlock';
    } else if (state == 'unlocked' || state == 'unlocking...') {
      this.state = 'locking...';
      domain = "lock";
      service = 'lock';
    } else if (domain == "scene") {
      service = 'turn_on';
    }

    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": domain,
      "service": service,
      "service_data": {"entity_id": entityId}
    };

    log.d("toggleState $entityId - $state");
    var message = json.encode(outMsg);
    webSocket.send(message);
  }

  EntityType get entityType {
    if (entityId.contains('climate.') ||
        entityId.contains('fan.') ||
        entityId.contains('water_heater.')) {
      return EntityType.climateFans;
    } else if (entityId.contains('camera.')) {
      return EntityType.cameras;
    } else if (entityId.contains('media_player.')) {
      return EntityType.mediaPlayers;
    } else if (entityId.contains('group.')) {
      return EntityType.group;
    } else if (entityId.contains('script.') ||
        entityId.contains('automation.') ||
        entityId.contains('scene.')) {
      return EntityType.scriptAutomation;
    } else if (entityId.contains('light.') ||
        entityId.contains('switch.') ||
        entityId.contains('cover.') ||
        entityId.contains('input_boolean.') ||
        entityId.contains('lock.') ||
        entityId.contains('vacuum.')) {
      return EntityType.lightSwitches;
    } else {
      return EntityType.accessories;
    }
  }

  int get fanModeIndex {
    return fanModes.indexOf(fanMode);
  }

  int get hvacModeIndex {
    return hvacModes.indexOf(state);
  }

  IconData get mdiIcon {
    return gd.mdiIcon(getDefaultIcon);
  }

  String get getOverrideIcon {
    if (gd.entitiesOverride[entityId] != null &&
        gd.entitiesOverride[entityId].icon != null &&
        gd.entitiesOverride[entityId].icon.length > 0) {
      return gd.entitiesOverride[entityId].icon;
    }
    return null;
  }

  String get getDefaultIcon {
    if (getOverrideIcon != null && getOverrideIcon != "null") {
      return twoStateIcons(getOverrideIcon);
    }

    if (icon != null && icon != "null") {
      return twoStateIcons(icon);
    }

    String domain = entityId.split(".")[0];
    String stateTranslate = isStateOn ? "on" : "off";

//    log.d(
//        "getDefaultIcon entityId $entityId icon $icon domain $domain.$deviceClass.$stateTranslate state $state");

    if (domain != "null") {
      if (deviceClass != null &&
          MaterialDesignIcons.defaultIconsByDeviceClass[
                  "$domain.$deviceClass.$stateTranslate"] !=
              null) {
        return twoStateIcons(MaterialDesignIcons
            .defaultIconsByDeviceClass["$domain.$deviceClass.$stateTranslate"]);
      }
      if (MaterialDesignIcons
              .defaultIconsByDeviceClass["$domain.$deviceClass"] !=
          null) {
        return twoStateIcons(MaterialDesignIcons
            .defaultIconsByDeviceClass["$domain.$deviceClass"]);
      }
      if (MaterialDesignIcons
              .defaultIconsByDeviceClass["$domain.$stateTranslate"] !=
          null) {
        return twoStateIcons(MaterialDesignIcons
            .defaultIconsByDeviceClass["$domain.$stateTranslate"]);
      }
    }

    //https://www.home-assistant.io/integrations/sensor/
    if (entityId.contains("sensor.")) {
      if (entityId.contains("battery")) return twoStateIcons('mdi:battery');
      if (entityId.contains("humidity"))
        return twoStateIcons('mdi:water-percent');
      if (entityId.contains("illuminance"))
        return twoStateIcons('mdi:brightness-6');
      if (entityId.contains("signal_strength"))
        return twoStateIcons('mdi:signal');
      if (entityId.contains("temperature"))
        return twoStateIcons('mdi:thermometer');
      if (entityId.contains("power")) return twoStateIcons('mdi:power');
      if (entityId.contains("pressure")) return twoStateIcons('mdi:gauge');
      if (entityId.contains("timestamp")) return twoStateIcons('mdi:clock');
    }

    //https://www.home-assistant.io/integrations/cover/
    if (entityId.contains("cover.")) {
      if (entityId.contains("awning"))
        return twoStateIcons('mdi:window-shutter');
      if (entityId.contains("blind")) return twoStateIcons('mdi:blinds');
      if (entityId.contains("curtain")) return twoStateIcons('mdi:blinds');
      if (entityId.contains("damper")) return twoStateIcons('mdi:window-close');
      if (entityId.contains("door")) return twoStateIcons('mdi:door-closed');
      if (entityId.contains("garage")) return twoStateIcons('mdi:garage');
      if (entityId.contains("shade")) return twoStateIcons('mdi:blinds');
      if (entityId.contains("shutter"))
        return twoStateIcons('mdi:window-shutter');
      if (entityId.contains("window")) return twoStateIcons('mdi:window-close');
    }

    if (MaterialDesignIcons.defaultIconsByDomains["$domain.$stateTranslate"] !=
        null) {
      return twoStateIcons(
          MaterialDesignIcons.defaultIconsByDomains["$domain.$stateTranslate"]);
    }

    if (MaterialDesignIcons.defaultIconsByDomains["$domain"] != null) {
      return twoStateIcons(
          MaterialDesignIcons.defaultIconsByDomains["$domain"]);
    }

    return 'mdi:help-circle';
  }

  String twoStateIcons(String currentIcon) {
    if (isStateOn && currentIcon == "mdi:bell") return "mdi:bell-ring";
    if (!isStateOn && currentIcon == "mdi:bell-ring") return "mdi:bell";

    if (isStateOn && currentIcon == "mdi:blinds") return "mdi:blinds-open";
    if (!isStateOn && currentIcon == "mdi:blinds-open") return "mdi:blinds";

    if (isStateOn && currentIcon == "mdi:door-closed") return "mdi:door-open";
    if (!isStateOn && currentIcon == "mdi:door-open") return "mdi:door-closed";

    if (isStateOn && currentIcon == "mdi:fan-off") return "mdi:fan";
    if (!isStateOn && currentIcon == "mdi:fan") return "mdi:fan-off";

    if (isStateOn && currentIcon == "mdi:garage") return "mdi:garage-open";
    if (!isStateOn && currentIcon == "mdi:garage-open") return "mdi:garage";

    if (isStateOn && currentIcon == "mdi:lightbulb") return "mdi:lightbulb-on";
    if (!isStateOn && currentIcon == "mdi:lightbulb-on") return "mdi:lightbulb";

    if (isStateOn && currentIcon == "mdi:lightbulb-outline")
      return "mdi:lightbulb-on-outline";
    if (!isStateOn && currentIcon == "mdi:lightbulb-on-outline")
      return "mdi:lightbulb-outline";

    if (isStateOn && currentIcon == "mdi:lock") return "mdi:lock-open";
    if (!isStateOn && currentIcon == "mdi:lock-open") return "mdi:lock";
    if (isStateOn && currentIcon == "mdi:radiator-off") return "mdi:radiator";
    if (!isStateOn && currentIcon == "mdi:radiator") return "mdi:radiator-off";
    if (isStateOn && currentIcon == "mdi:window-closed")
      return "mdi:window-open";
    if (!isStateOn && currentIcon == "mdi:window-open")
      return "mdi:window-closed";
    if (isStateOn && currentIcon == "mdi:walk") return "mdi:run";
    if (!isStateOn && currentIcon == "mdi:run") return "mdi:walk";

    if (isStateOn && currentIcon == "mdi:window-shutter")
      return "mdi:window-shutter-open";
    if (!isStateOn && currentIcon == "mdi:window-shutter-open")
      return "mdi:window-shutter";

    return currentIcon;
  }

  bool get isStateOn {
    var stateLower = state.toLowerCase();
    if (stateLower == 'closed' ||
//        stateLower == 'false' ||
        stateLower == 'locked' ||
        stateLower == 'none' ||
        stateLower == 'off' ||
        stateLower == 'unavailable' ||
        stateLower == 'disarmed' ||
        stateLower == 'unknown') return false;

    if ([
      'on',
      'turning on...',
      'open',
      'opening...',
      'unlocked',
      'unlocking...',
      'cleaning'
    ].contains(stateLower)) {
      return true;
    }

    if ((entityId.split('.')[0] == 'climate' ||
            entityId.split('.')[0] == 'water_heater' ||
            entityId.split('.')[0] == 'media_player') &&
        stateLower != 'idle') {
      return true;
    }
    if ((entityId.split('.')[0] == 'device_tracker' ||
            entityId.split('.')[0] == 'person') &&
        stateLower == 'home') {
      return true;
    }

    if (entityType == EntityType.scriptAutomation ||
        entityType == EntityType.accessories &&
            !entityId.contains("binary_sensor") &&
            !entityId.contains("device_tracker") &&
            !entityId.contains("person")) {
      return true;
    }

    return false;
  }

  bool get showAsBigButton {
    return entityType == EntityType.cameras;
  }

  String get getOverrideName {
    if (gd.entitiesOverride[entityId] != null &&
        gd.entitiesOverride[entityId].friendlyName != null &&
        gd.entitiesOverride[entityId].friendlyName.length > 0) {
      return gd.entitiesOverride[entityId].friendlyName;
    } else {
      return getFriendlyName;
    }
  }

  String get getFriendlyName {
    if (friendlyName != null) {
      return friendlyName;
    } else if (entityId != null) {
      return entityId;
    } else {
      return "???";
    }
  }

  //https://community.home-assistant.io/t/supported-features/43696
  List<String> supportedFeaturesLightList = [
    "SUPPORT_BRIGHTNESS",
    "SUPPORT_COLOR_TEMP",
    "SUPPORT_EFFECT",
    "SUPPORT_FLASH",
    "SUPPORT_RGB_COLOR",
    "SUPPORT_TRANSITION",
    "SUPPORT_XY_COLOR",
    "SUPPORT_WHITE_VALUE",
  ];
  String get getSupportedFeaturesLights {
    if (supportedFeatures == null) {
      return "";
    }
    var recVal = "";
    var binaryText = supportedFeatures.toRadixString(2);
    int index = 0;
    for (int i = binaryText.length; i > 0; i--) {
      var x = binaryText.substring(i - 1, i);
      if (x == "1") {
        recVal = recVal + supportedFeaturesLightList[index] + " | ";
      }
      index++;
    }
//    print("recVal $recVal");
    return recVal;
  }

  // https://github.com/home-assistant/home-assistant/blob/dev/homeassistant/components/media_player/const.py
  // [media_player.denon_avr_x3000] [state: on] 69004 SUPPORT_VOLUME_SET | SUPPORT_VOLUME_MUTE | SUPPORT_TURN_ON | SUPPORT_TURN_OFF | SUPPORT_VOLUME_STEP | SUPPORT_SELECT_SOURCE | SUPPORT_SELECT_SOUND_MODE |

  //[media_player.apple_tv] [state: unknown] 21427 SUPPORT_PAUSE | SUPPORT_SEEK | SUPPORT_PREVIOUS_TRACK | SUPPORT_NEXT_TRACK | SUPPORT_TURN_ON | SUPPORT_TURN_OFF | SUPPORT_PLAY_MEDIA | SUPPORT_STOP | SUPPORT_PLAY |

  //[media_player.living_room_tv] [state: unavailable] 21389 SUPPORT_PAUSE | SUPPORT_VOLUME_SET | SUPPORT_VOLUME_MUTE | SUPPORT_TURN_ON | SUPPORT_TURN_OFF | SUPPORT_PLAY_MEDIA | SUPPORT_STOP | SUPPORT_PLAY |

  //Available services: turn_on, turn_off, toggle, volume_up, volume_down, volume_set, volume_mute, media_play_pause, media_play, media_pause, media_stop, media_next_track, media_previous_track, clear_playlist, shuffle_set

  List<String> supportedFeaturesMediaPlayerList = [
    "SUPPORT_PAUSE",
    "SUPPORT_SEEK",
    "SUPPORT_VOLUME_SET",
    "SUPPORT_VOLUME_MUTE",
    "SUPPORT_PREVIOUS_TRACK",
    "SUPPORT_NEXT_TRACK",
    "",
    "SUPPORT_TURN_ON",
    "SUPPORT_TURN_OFF",
    "SUPPORT_PLAY_MEDIA",
    "SUPPORT_VOLUME_STEP",
    "SUPPORT_SELECT_SOURCE",
    "SUPPORT_STOP",
    "SUPPORT_CLEAR_PLAYLIST",
    "SUPPORT_PLAY",
    "SUPPORT_SHUFFLE_SET",
    "SUPPORT_SELECT_SOUND_MODE",
  ];
  String get getSupportedFeaturesMediaPlayer {
    if (supportedFeatures == null) {
      return "";
    }
    var recVal = "";
    var binaryText = supportedFeatures.toRadixString(2);
    int index = 0;
    for (int i = binaryText.length; i > 0; i--) {
      var x = binaryText.substring(i - 1, i);
      if (x == "1") {
        recVal = recVal + supportedFeaturesMediaPlayerList[index] + " | ";
      }
      index++;
    }
//    print("recVal $recVal");
    return recVal;
  }

  List<String> supportedFeaturesVacuumList = [
    "SUPPORT_TURN_ON",
    "SUPPORT_TURN_OFF",
    "SUPPORT_PAUSE",
    "SUPPORT_STOP",
    "SUPPORT_RETURN_HOME",
    "SUPPORT_FAN_SPEED",
    "SUPPORT_BATTERY",
    "SUPPORT_STATUS",
    "SUPPORT_SEND_COMMAND",
    "SUPPORT_LOCATE",
    "SUPPORT_CLEAN_SPOT",
    "SUPPORT_MAP",
    "SUPPORT_STATE",
    "SUPPORT_START",
  ];
  String get getSupportedFeaturesVacuum {
//    print("getSupportedFeaturesVacuum $supportedFeatures");
    if (supportedFeatures == null) {
      return "";
    }
    var recVal = "";
    var binaryText = supportedFeatures.toRadixString(2);
    int index = 0;
    for (int i = binaryText.length; i > 0; i--) {
      var x = binaryText.substring(i - 1, i);
      if (x == "1") {
        recVal = recVal + supportedFeaturesVacuumList[index] + " | ";
      }
      index++;
    }
//    print("recVal $recVal");
    return recVal;
  }

  String get getStateDisplay {
    if (isStateOn && entityId.contains("fan.")) {
      if (speed != null && speed.length > 0 && speed != "null") return speed;
    }

    if (DateTime.tryParse(state) != null) {
      if (state.contains(":") && state.contains("-")) {
//        print("entityId $entityId.$state containt : and -");
        if (gd.configUnitSystem['length'].toString() == "km") {
          return DateFormat('dd/MM kk:mm').format(DateTime.parse(state));
        } else {
          return DateFormat('MM/dd kk:mm').format(DateTime.parse(state));
        }
      } else if (state.contains("-")) {
//        print("entityId $entityId.$state containt -");
        if (gd.configUnitSystem['length'].toString() == "km") {
          return DateFormat('E dd/MM').format(DateTime.parse(state));
        } else {
          return DateFormat('E MM/dd').format(DateTime.parse(state));
        }
      }
//      Can't parse only time
//      else if (state.contains(":")) {
//        print("entityId $entityId.$state containt :");
//        return DateFormat('kk:mm').format(DateTime.parse(state));
//      }
    }

    if (double.tryParse(state) != null) {
      var recVal = double.parse(state);
      if (recVal >= 100 || recVal.toStringAsFixed(1).contains(".0"))
        return recVal.toStringAsFixed(0);
      return recVal.toStringAsFixed(1);
    }
    return state;
  }

  String getStateDisplayTranslated(BuildContext context) {
    var openPercent = "";
    if (isStateOn &&
        entityId.contains("light.") &&
        brightness != null &&
        brightness > 0) {
      openPercent = " " +
          gd.mapNumber(brightness, 0, 254, 0, 100).toStringAsFixed(0) +
          "%";
    }
    if (isStateOn &&
        entityId.contains("cover.") &&
        currentPosition != null &&
        currentPosition > 0) {
      openPercent = " " + currentPosition.toStringAsFixed(0) + "%";
    }

    if (entityId.contains("fan.")) {
      if (speed.toLowerCase() == "high")
        return Translate.getString("states.fan_high", context);
      if (speed.toLowerCase() == "mediumhigh")
        return Translate.getString("states.fan_high_medium", context);
      if (speed.toLowerCase() == "medium")
        return Translate.getString("states.fan_medium", context);
      if (speed.toLowerCase() == "mediumlow")
        return Translate.getString("states.fan_medium_low", context);
      if (speed.toLowerCase() == "low")
        return Translate.getString("states.fan_low", context);
      if (speed.toLowerCase() == "lowest")
        return Translate.getString("states.fan_lowest", context);
      return speed;
    }

    if (state.toLowerCase() == "on")
      return Translate.getString("states.on", context) + openPercent;
    if (state.toLowerCase() == "turning on...")
      return Translate.getString("states.turning_on", context);
    if (state.toLowerCase() == "off")
      return Translate.getString("states.off", context);
    if (state.toLowerCase() == "turning off...")
      return Translate.getString("states.turning_off", context);
    if (state.toLowerCase() == "closed")
      return Translate.getString("states.closed", context);
    if (state.toLowerCase() == "closing...")
      return Translate.getString("states.closing", context);
    if (state.toLowerCase() == "open")
      return Translate.getString("states.open", context) + openPercent;
    if (state.toLowerCase() == "opening...")
      return Translate.getString("states.opening", context);
    if (state.toLowerCase() == "locked")
      return Translate.getString("states.locked", context);
    if (state.toLowerCase() == "locking...")
      return Translate.getString("states.locking", context);
    if (state.toLowerCase() == "unlocked")
      return Translate.getString("states.unlocked", context);
    if (state.toLowerCase() == "unlocking...")
      return Translate.getString("states.unlocking", context);
    if (state.toLowerCase() == "disarmed")
      return Translate.getString("states.disarmed", context);
    if (state.toLowerCase().contains("armed")) {
      if (state.toLowerCase().contains("away"))
        return Translate.getString("states.armed_away", context);
      if (state.toLowerCase().contains("home"))
        return Translate.getString("states.armed_home", context);
      if (state.toLowerCase().contains("night"))
        return Translate.getString("states.armed_night", context);
      return Translate.getString("states.armed", context);
    }
    if (state.toLowerCase().contains("pending"))
      return Translate.getString("states.arm_pending", context);

    return getStateDisplay;
  }

  double get getTemperature {
    if (temperature != null) return temperature;
    if (currentTemperature != null) return currentTemperature;
    return 0;
  }
}
