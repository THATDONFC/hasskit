import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hasskit/helper/geolocator_helper.dart';
import 'package:hasskit/helper/mobile_app_helper.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/helper/web_socket.dart';
import 'package:hasskit/model/location_zone.dart';
import 'package:hasskit/view/setting_control/setting_mobile_app.dart';
import 'package:hasskit/model/base_setting.dart';
import 'package:hasskit/model/camera_info.dart';
import 'package:hasskit/model/device_setting.dart';
import 'package:hasskit/model/entity.dart';
import 'package:hasskit/model/entity_override.dart';
import 'package:hasskit/model/location.dart';
import 'package:hasskit/model/login_data.dart';
import 'package:hasskit/model/room.dart';
import 'package:hasskit/model/sensor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';
import 'dart:math' as Math;
import 'logger.dart';
import 'material_design_icons.dart';

GeneralData gd = GeneralData();
Random random = Random();

enum ViewMode {
  normal,
  edit,
  sort,
}

class GeneralData with ChangeNotifier {
  void saveBool(String key, bool content) async {
    var _preferences = await SharedPreferences.getInstance();
    _preferences.setBool(key, content);
    log.d('saveBool: key $key content $content');
  }

  Future<bool> getBool(String key) async {
    var _preferences = await SharedPreferences.getInstance();
    var value = _preferences.getBool(key) ?? false;
    return value;
  }

  void saveString(String key, String content) async {
    var _preferences = await SharedPreferences.getInstance();
    _preferences.setString(key, content);
    log.d('saveString: key $key content $content');
  }

  Future<String> getString(String key) async {
    var _preferences = await SharedPreferences.getInstance();
    var value = _preferences.getString(key) ?? '';
    return value;
  }

//  double _mediaQueryWidth = 411.42857142857144;

  double get mediaQueryWidth {
    return MediaQuery.of(mediaQueryContext).size.width;
  }

  double get mediaQueryHeight {
    return MediaQuery.of(mediaQueryContext).size.height;
  }

  double get mediaQueryShortestSide {
    return MediaQuery.of(mediaQueryContext).size.shortestSide;
  }

  double get mediaQueryLongestSide {
    return MediaQuery.of(mediaQueryContext).size.longestSide;
  }

  Orientation get mediaQueryOrientation {
    return MediaQuery.of(mediaQueryContext).orientation;
  }

  bool get isTablet {
    return mediaQueryShortestSide >= 500;
  }

  double get textScaleFactorFix {
    return 1.0;
  }

  double get textScaleFactor {
    int totalRowButton = layoutButtonCount;
    if (!isTablet || mediaQueryOrientation == Orientation.portrait) {
      return (mediaQueryWidth / 411.42857142857144) * (3 / totalRowButton);
    }
    return (mediaQueryLongestSide / 411.42857142857144) * (3 / totalRowButton);
  }

  int _lastSelectedRoom = 0;

  int get lastSelectedRoom => _lastSelectedRoom;

  set lastSelectedRoom(int val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_lastSelectedRoom != val) {
      _lastSelectedRoom = val;
      notifyListeners();
    }
  }

  String _webSocketConnectionStatus = '';

  String get webSocketConnectionStatus => _webSocketConnectionStatus;

  set webSocketConnectionStatus(String val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_webSocketConnectionStatus != val) {
      _webSocketConnectionStatus = val;
      notifyListeners();
    }
  }

  bool _webSocketConnected = false;

  bool get webSocketConnected => _webSocketConnected;

  set webSocketConnected(bool val) {
    if (_webSocketConnected != val) {
      _webSocketConnected = val;
      if (!val) {
        webSocketDisconnectedTime = DateTime.now();
      }
      notifyListeners();
    }
  }

  bool get showSpin {
    if (gd.webSocketConnected == false &&
        gd.webSocketDisconnectedTime
            .isBefore(DateTime.now().subtract(Duration(seconds: 15)))) {
      return true;
    }
    return false;
  }

//  DateTime webSocketOnDoneTime = DateTime.now();

  DateTime webSocketOnDataTime = DateTime.now();
  DateTime webSocketDisconnectedTime = DateTime.now();

  String _urlTextField = '';

  String get urlTextField => _urlTextField;

  set urlTextField(String val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_urlTextField != val) {
      _urlTextField = val;
      notifyListeners();
    }
  }

  void sendHttpPost(String url, String authCode, BuildContext context) async {
    log.d('httpPost $url '
        '\nauthCode $authCode');
    Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var body = 'grant_type=authorization_code'
        '&code=$authCode&client_id=$url/hasskit';
    http
        .post(url + '/auth/token', headers: headers, body: body)
        .then((response) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        gd.webSocketConnectionStatus =
            'Got response from server with code ${response.statusCode}';

        var bodyDecode = json.decode(response.body);
        var loginData = LoginData.fromJson(bodyDecode);
        loginData.url = url;
//        log.d('bodyDecode $bodyDecode\n'
//            'url ${loginData.url}\n'
//            'longToken ${loginData.longToken}\n'
//            'accessToken ${loginData.accessToken}\n'
//            'expiresIn ${loginData.expiresIn}\n'
//            'refreshToken ${loginData.refreshToken}\n'
//            'tokenType ${loginData.tokenType}\n'
//            'lastAccess ${loginData.lastAccess}\n'
//            '');
        log.d("loginData.url ${loginData.url}");
        log.d("longToken.url ${loginData.longToken}");
        log.d("accessToken.url ${loginData.accessToken}");
        log.d("expiresIn.url ${loginData.expiresIn}");
        log.d("refreshToken.url ${loginData.refreshToken}");
        log.d("tokenType.url ${loginData.tokenType}");
        log.d("lastAccess.url ${loginData.lastAccess}");

        gd.loginDataCurrent = loginData;
        gd.loginDataListAdd(loginData, "sendHttpPost");
        loginDataListSortAndSave("sendHttpPost");
        webSocket.initCommunication();
        gd.webSocketConnectionStatus =
            'Init Websocket Communication to ${loginDataCurrent.getUrl}';
        log.w(gd.webSocketConnectionStatus);
        Navigator.pop(context, gd.webSocketConnectionStatus);
      } else {
        gd.webSocketConnectionStatus =
            'Error response from server with code ${response.statusCode}';
        Navigator.pop(context, gd.webSocketConnectionStatus);
      }
    }).catchError((e) {
      gd.webSocketConnectionStatus = 'Error response from server with code $e';
      Navigator.pop(context, gd.webSocketConnectionStatus);
    });
  }

  Map<String, Entity> entities = {};

////  List<Entity> _entities = [];
//  UnmodifiableMapView<String, Entity> get entities {
//    return UnmodifiableMapView(_entities);
//  }

  void socketGetStates(List<dynamic> message) {
    List<String> previousEntitiesList = entities.keys.toList();

    for (dynamic mess in message) {
      Entity entity = Entity.fromJson(mess);
      if (entity == null || entity.entityId == null) {
        log.e('socketGetStates entity.entityId');
        continue;
      }

      if (entity.entityId.contains("zone.")) {
        LocationZone locationZone = LocationZone.fromJson(mess);
        bool addNewLocationZone = true;
        for (var loc in locationZones) {
          if (loc.friendlyName == locationZone.friendlyName) {
            addNewLocationZone = false;
            break;
          }
        }

        if (addNewLocationZone) {
          print(
              "locationZones.add locationZone friendly_name ${locationZone.friendlyName} latitude ${locationZone.latitude} longitude ${locationZone.longitude} radius ${locationZone.radius}");
          locationZones.add(locationZone);
        }
      }

      if (entity.entityId.contains("water_heater.")) {
        print("\nsocketGetStates water_heater $mess\n");
      }

      if (previousEntitiesList.contains(entity.entityId)) {
        previousEntitiesList.remove(entity.entityId);
      }

      entities[entity.entityId] = entity;
    }

    if (previousEntitiesList.length > 0) {
      for (String entityId in previousEntitiesList) {
        log.e(
            "Remove $entityId from _entities, it's no longer in recent get_states");
        entities.remove(entityId);
      }
    }

//    log.d('socketGetStates total entities ${_entities.length}');
    notifyListeners();
  }

  void socketSubscribeEvents(dynamic message) {
    String entityId;
    try {
      entityId = message['event']['data']['new_state']["entity_id"];
    } catch (e) {
      log.e("socketSubscribeEvents $e");
      entityId = null;
    }

    if (entityId == null || entityId == "" || entityId == "null") {
      return;
    }

    eventEntityUpdate(entityId);

    entities[entityId] = Entity.fromJson(message['event']['data']['new_state']);
    entities[entityId].oldState =
        jsonEncode(message['event']['data']['old_state']);
    entities[entityId].newState =
        jsonEncode(message['event']['data']['new_state']);

    if (entities[entityId].entityId.contains("vacuum.")) {
      log.w(
          "\n socketSubscribeEvents $entityId message ${message['event']['data']['new_state']}");
      if (!entities.containsKey(entityId)) {
        log.e("_entities.containsKey($entityId");
      }
    }

//    if (baseSetting.notificationDevices.contains(entityId)) {
////      print("baseSetting.notificationDevices $entityId");
//      var oldState = jsonEncode(message['event']['data']['old_state']["state"]);
//      var newState = jsonEncode(message['event']['data']['new_state']["state"]);
//
//      if (oldState == null ||
//          oldState.toLowerCase().contains("unavailable") ||
//          oldState.toLowerCase().contains("unknown")) {
//        print("1 showNotificationWithNoBody $entityId oldState unavailable");
//      } else if (newState == null ||
//          newState.toLowerCase().contains("unavailable") ||
//          newState.toLowerCase().contains("unknown")) {
//        print("2 showNotificationWithNoBody $entityId newState unavailable");
//      } else if (newState == oldState) {
//        print(
//            "3 showNotificationWithNoBody $entityId newState == oldState $newState");
//      } else {
//        var title = gd.textToDisplay(gd.entities[entityId].getOverrideName);
//        var body = gd.textToDisplay(
//            "${gd.entities[entityId].getStateDisplayTranslated(mediaQueryContext)}");
//        var uniqueNumber = gd.entities.keys.toList().indexOf(entityId);
//        if (uniqueNumber == null) uniqueNumber = 0;
//        print(
//            "\nshowNotificationWithNoBody\n$entityId oldState $oldState newState $newState");
//
//        LocalNotification.showNotificationWithNoBody(
//            title + ": " + body, entityId);
//      }
//    }

    notifyListeners();
  }

  String _eventsEntities;
  String get eventsEntities => _eventsEntities;
  set eventsEntities(String val) {
    if (val != _eventsEntities) {
      _eventsEntities = val;
      notifyListeners();
    }
  }

  Map<String, String> _eventEntity = {};
  String eventEntity(String val) {
    if (_eventEntity[val] == null) {
      return "";
    }
    return _eventEntity[val];
  }

  void eventEntityUpdate(String val) {
    _eventEntity[val] = val + random.nextInt(100).toString();
    notifyListeners();
  }

  bool isEntityNameValid(String entityId) {
    if (entityId == null) {
//      log.d('isEntityNameValid entityName null');
      return false;
    }

    if (!entityId.contains('.')) {
//      log.d('isEntityNameValid $entityId not valid');
      return false;
    }
    return true;
  }

  String processEntityId(String entityId) {
    if (entityId == null) {
      log.e('processEntityId String entityId null');
      return null;
    }

    String entityIdOriginal = entityId;
    entityId = entityId.split(',').first;

    if (!entityId.contains('.')) {
      log.e('processEntityId $entityIdOriginal not valid');
      return null;
    }

    entityId = entityId.replaceAll('{entity: ', '');
    entityId = entityId.replaceAll('}', '');

    return entityId;
  }

  Map<String, CameraInfo> cameraInfos = {};
  List<String> cameraInfosActive = [];
  cameraInfoGet(String entityId) {
    if (!cameraInfos.containsKey(entityId)) {
      cameraInfos[entityId] = CameraInfo(
        entityId: entityId,
        updatedTime: DateTime.now().subtract(Duration(days: 1)),
        requestingTime: DateTime.now().subtract(Duration(days: 1)),
        currentImage: AssetImage("assets/images/loader.png"),
        previousImage: AssetImage("assets/images/loader.png"),
      );
    }
    return cameraInfos[entityId];
  }

  Future<void> cameraInfosUpdate(String entityId) async {
    CameraInfo cameraInfo = gd.cameraInfoGet(entityId);

    if (cameraInfo.requestingTime.isAfter(DateTime.now())) {
//      log.d("updateImage $entityId requestingTime.isAfter");
      return;
    }

//    log.d("CameraInfo.updateImage $entityId");
    cameraInfo.requestingTime = DateTime.now().add(Duration(seconds: 10));
    final url = gd.currentUrl +
        gd.entities[entityId].entityPicture +
        "&time=" +
        DateTime.now().millisecondsSinceEpoch.toString();
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
//        log.d(
//            "CameraInfo.updateImage $entityId response.statusCode == 200 url $url");
        cameraInfo.previousImage = cameraInfo.currentImage;
        cameraInfo.currentImage = NetworkImage(url);
        cameraInfo.updatedTime = DateTime.now();
        notifyListeners();
      } catch (e) {
        log.w("CameraInfo.updateImage $entityId catch $e");
      }
    } else {
      log.w(
          "CameraInfo.updateImage $entityId error response.statusCode ${response.statusCode}");
    }
  }

  ThemeData get currentTheme {
    return ThemeInfo.themesData[deviceSetting.themeIndex];
  }

  List<LoginData> loginDataList = [];

  int get loginDataListLength {
    return loginDataList.length;
  }

  LoginData loginDataHassKit = LoginData(
    url: "http://hasskit.duckdns.org:8123",
    accessToken: "",
    longToken:
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiIyMDVhM2M3N2JjYjg0ZjBlYjI3MzZmNGJiNGUyZWI3OSIsImlhdCI6MTU3ODk4MzQxNCwiZXhwIjoxNjEwNTE5NDE0fQ.jkw-hk8UG0yK_6UHKdkY6kUkIfK4702FqKfRa5JsCk4",
    expiresIn: 1800,
    refreshToken: "",
    tokenType: "Bearer",
    lastAccess: 1573693868837,
  );

  LoginData loginDataCurrent = LoginData();

  String _loginDataListString;

  String get loginDataListString => _loginDataListString;

  set loginDataListString(val) {
    _loginDataListString = val;

    if (_loginDataListString != null && _loginDataListString.length > 0) {
      List<dynamic> loginDataListString = jsonDecode(_loginDataListString);
      loginDataList = [];
      for (var loginData in loginDataListString) {
        LoginData newLoginData = LoginData(
          url: loginData['url'],
          longToken: loginData['longToken'],
          accessToken: loginData['accessToken'],
          expiresIn: loginData['expiresIn'],
          refreshToken: loginData['refreshToken'],
          tokenType: loginData['tokenType'],
          lastAccess: loginData['lastAccess'],
        );
        log.d('loginDataListAdd url ${newLoginData.url}');

        loginDataListAdd(newLoginData, "loginDataListString");
      }
      log.d('loginDataList.length ${loginDataList.length}');
    } else {
      log.w('CAN NOT FIND loginDataList');
    }

    if (gd.loginDataList.length > 0) {
      loginDataCurrent = gd.loginDataList[0];
      if (gd.autoConnect && gd.webSocketConnectionStatus != "Connected") {
        log.w('Auto connect to ${loginDataCurrent.getUrl}');
        webSocket.initCommunication();
      }
    }
  }

  void loginDataListAdd(LoginData loginData, String from) {
    log.d('LoginData.loginDataListAdd ${loginData.url} from $from');
    var loginDataOld = loginDataList
        .firstWhere((rec) => rec.getUrl == loginData.url, orElse: () => null);
    if (loginDataOld == null) {
      loginDataList.add(loginData);
      log.d('loginDataListAdd ${loginData.url}');
    } else {
      loginDataOld.url = loginData.url;
      loginDataOld.accessToken = loginData.accessToken;
      loginDataOld.longToken = loginData.longToken;
      loginDataOld.expiresIn = loginData.expiresIn;
      loginDataOld.refreshToken = loginData.refreshToken;
      loginDataOld.tokenType = loginData.tokenType;
      loginDataOld.lastAccess = DateTime.now().toUtc().millisecondsSinceEpoch;
      log.e('loginDataListAdd ALREADY HAVE ${loginData.url}');
    }
    notifyListeners();
  }

  void loginDataListSortAndSave(String debug) {
    try {
      if (loginDataList != null && loginDataList.length > 0) {
        loginDataList.sort((a, b) => b.lastAccess.compareTo(a.lastAccess));
        gd.saveString('loginDataList', jsonEncode(loginDataList));
        log.d('loginDataList.length ${loginDataList.length}');
      } else {
        gd.saveString('loginDataList', jsonEncode(loginDataList));
      }
      notifyListeners();
    } catch (e) {
      log.w("loginDataListSortAndSave $e");
    }
  }

  Future<void> loginDataListDelete(LoginData loginData) async {
    log.d('LoginData.loginDataListDelete ${loginData.url}');
    var url = loginData.url.replaceAll(".", "-");
    url = url.replaceAll("/", "-");
    url = url.replaceAll(":", "-");
    var _preferences = await SharedPreferences.getInstance();
    print("_preferences.remove deviceSetting $url");
    _preferences.remove("deviceSetting $url");
    print("_preferences.remove settingMobileApp $url");
    _preferences.remove("settingMobileApp $url");

    if (loginData != null) {
      loginDataList.remove(loginData);
      log.d('loginDataList.remove ${loginData.url}');
    } else {
      log.e('loginDataList.remove Can not find ${loginData.url}');
    }
    loginDataListSortAndSave("loginDataListDelete");
  }

  get socketUrl {
    String recVal = loginDataCurrent.url;
    recVal = recVal.replaceAll('http', 'ws');
    recVal = recVal + '/api/websocket';
    return recVal;
  }

  int _socketId = 0;

  get socketId => _socketId;

  set socketId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_socketId != value) {
      _socketId = value;
      notifyListeners();
    }
  }

  void socketIdIncrement() {
    socketId = socketId + 1;
  }

  int _subscribeEventsId = 0;

  get subscribeEventsId => _subscribeEventsId;

  set subscribeEventsId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_subscribeEventsId != value) {
      _subscribeEventsId = value;
      notifyListeners();
    }
  }

  int _longTokenId = 0;

  get longTokenId => _longTokenId;

  set longTokenId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_longTokenId != value) {
      _longTokenId = value;
      notifyListeners();
    }
  }

  int _getStatesId = 0;

  get getStatesId => _getStatesId;

  set getStatesId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_getStatesId != value) {
      _getStatesId = value;
      notifyListeners();
    }
  }

//  int _loveLaceConfigId = 0;
//
//  get loveLaceConfigId => _loveLaceConfigId;
//
//  set loveLaceConfigId(int value) {
//    if (value == null) {
//      throw new ArgumentError();
//    }
//    if (_loveLaceConfigId != value) {
//      _loveLaceConfigId = value;
//      notifyListeners();
//    }
//  }

  bool _useSSL = false;

  get useSSL => _useSSL;

  set useSSL(bool value) {
    if (value != true && value != false) {
      throw new ArgumentError();
    }
    if (_useSSL != value) {
      _useSSL = value;
      notifyListeners();
    }
  }

  bool _autoConnect = true;

  get autoConnect => _autoConnect;

  set autoConnect(bool value) {
    if (value != true && value != false) {
      throw new ArgumentError();
    }
    if (_autoConnect != value) {
      _autoConnect = value;
      notifyListeners();
    }
  }

  bool _webViewLoading = false;

  bool get webViewLoading {
    return _webViewLoading;
  }

  set webViewLoading(bool value) {
    if (value != true && value != false) {
      throw new ArgumentError();
    }
    if (_webViewLoading != value) {
      _webViewLoading = value;
      notifyListeners();
    }
  }

//  bool _showLoading = false;
//  bool get showLoading {
//    return _showLoading;
//  }
//
//  set showLoading(bool value) {
//    if (value != true && value != false) {
//      throw new ArgumentError();
//    }
//    if (_showLoading != value) {
//      _showLoading = value;
//      notifyListeners();
//    }
//  }

  String trimUrl(String url) {
    url = url.trim();
    if (url.substring(url.length - 1, url.length) == '/') {
      url = url.substring(0, url.length - 1);
      log.w('$url contain last /');
    }
    return url;
  }

  List<Room> roomList = [];
  List<Room> roomListDefault = [
    Room(
      name: 'Home',
      imageIndex: 17,
      row1: [],
      row1Name: "Group 1",
      row2: [],
      row2Name: "Group 2",
      row3: [],
      row3Name: "Group 3",
      row4: [],
      row4Name: "Group 4",
    ),
    Room(
      name: 'Living Room',
      imageIndex: 18,
      row1: [],
      row1Name: "Group 1",
      row2: [],
      row2Name: "Group 2",
      row3: [],
      row3Name: "Group 3",
      row4: [],
      row4Name: "Group 4",
    ),
    Room(
      name: 'Kitchen',
      imageIndex: 19,
      row1: [],
      row1Name: "Group 1",
      row2: [],
      row2Name: "Group 2",
      row3: [],
      row3Name: "Group 3",
      row4: [],
      row4Name: "Group 4",
    ),
    Room(
      name: 'Bedroom',
      imageIndex: 20,
      row1: [],
      row1Name: "Group 1",
      row2: [],
      row2Name: "Group 2",
      row3: [],
      row3Name: "Group 3",
      row4: [],
      row4Name: "Group 4",
    ),
  ];

  List<Room> roomListHassKit = [
    Room(
      name: 'Demo Home',
      imageIndex: 17,
      tempEntityId: "sensor.netatmo_netatmo_living_room_temperature",
      row1: [
        "fan.acorn_fan",
        "climate.air_conditioner_1",
        "cover.cover_06",
        "alarm_control_panel.home_alarm",
        "cover.cover_03",
        "fan.living_room_ceiling_fan",
        "light.light_01",
        "lock.lock_9",
        "light.gateway_light_7c49eb891797",
        "sensor.speedtest_download",
        "sensor.speedtest_ping",
        "sensor.speedtest_upload",
      ],
      row1Name: "Group 1",
      row2: [
        "camera.camera_1",
        "camera.camera_2",
        "WebView1",
      ],
      row2Name: "Group 2",
      row3: [
        "switch.socket_sonoff_s20",
        "switch.tuya_neo_coolcam_10a",
      ],
      row3Name: "Group 3",
      row4: [
        "climate.air_conditioner_2",
        "climate.air_conditioner_3",
        "climate.air_conditioner_4",
        "climate.air_conditioner_5",
        "fan.kaze_fan",
        "fan.lucci_air_fan",
        "fan.super_fan",
      ],
      row4Name: "Group 4",
    ),
    Room(
      name: 'Living Room',
      imageIndex: 18,
      tempEntityId: "sensor.netatmo_netatmo_living_room_temperature",
      row1: [
        "climate.air_conditioner_2",
        "climate.air_conditioner_3",
        "cover.cover_01",
        "cover.cover_02",
        "cover.cover_04",
        "fan.kaze_fan",
        "light.light_03",
        "light.light_02",
        "fan.lucci_air_fan",
        "camera.camera_1",
        "sensor.netatmo_netatmo_living_room_temperature",
        "sensor.netatmo_netatmo_living_room_co2",
        "sensor.netatmo_netatmo_living_room_humidity",
        "sensor.netatmo_netatmo_living_room_noise",
        "sensor.netatmo_netatmo_living_room_pressure",
      ],
      row1Name: "Group 1",
      row2: [],
      row2Name: "Group 2",
      row3: [],
      row3Name: "Group 3",
      row4: [],
      row4Name: "Group 4",
    ),
    Room(
      name: 'Kitchen',
      imageIndex: 19,
      tempEntityId: "sensor.netatmo_netatmo_living_room_temperature",
      row1: [
        "camera.camera_2",
        "switch.aeotec_motion_26",
        "climate.air_conditioner_4",
        "climate.air_conditioner_5",
        "light.light_04",
        "light.light_05",
        "cover.cover_07",
        "cover.cover_08",
        "fan.super_fan",
        "cover.cover_09",
      ],
      row1Name: "Group 1",
      row2: [],
      row2Name: "Group 2",
      row3: [],
      row3Name: "Group 3",
      row4: [],
      row4Name: "Group 4",
    ),
    Room(
      name: 'Bedroom',
      imageIndex: 20,
      tempEntityId: "sensor.netatmo_netatmo_living_room_temperature",
      row1: [
        "climate.air_conditioner_2",
        "cover.cover_07",
        "cover.cover_08",
        "switch.socket_sonoff_s20",
        "switch.tuya_neo_coolcam_10a",
        "WebView1",
      ],
      row1Name: "Group 1",
      row2: [],
      row2Name: "Group 2",
      row3: [],
      row3Name: "Group 3",
      row4: [],
      row4Name: "Group 4",
    ),
  ];

  void roomListClear() {
    roomList.clear();
    roomList = [];
    notifyListeners();
  }

  int get roomListLength {
    if (roomList.length - 1 < 0) {
      return 0;
    }
    return roomList.length - 1;
  }

  String getRoomName(int roomIndex) {
    if (roomList.length > roomIndex && roomList[roomIndex].name != null) {
      return roomList[roomIndex].name;
    }
    return 'HassKit';
  }

  void roomEntitySort(
    int roomIndex,
    int rowNumber,
    String oldEntityId,
    String newEntityId,
  ) {
    log.w('roomEntitySwap oldEntityId $oldEntityId newEntityId $newEntityId');
    var entitiesRef;
    if (rowNumber == 1) {
      entitiesRef = gd.roomList[roomIndex].row1;
    } else if (rowNumber == 2) {
      entitiesRef = gd.roomList[roomIndex].row2;
    } else if (rowNumber == 3) {
      entitiesRef = gd.roomList[roomIndex].row3;
    } else {
      entitiesRef = gd.roomList[roomIndex].row4;
    }

    int oldIndex = entitiesRef.indexOf(oldEntityId);
    int newIndex = entitiesRef.indexOf(newEntityId);
    String removedString = entitiesRef.removeAt(oldIndex);
    entitiesRef.insert(newIndex, removedString);
    notifyListeners();
    roomListSave(true);
  }

  AssetImage getRoomImage(int roomIndex) {
    if (roomList.length > roomIndex &&
        roomList[roomIndex] != null &&
        roomList[roomIndex].imageIndex != null) {
      return AssetImage(backgroundImage[roomList[roomIndex].imageIndex]);
    }
    return AssetImage(backgroundImage[4]);
  }

  List<String> backgroundImage = [
    'assets/background_images/Dark_Blue.jpg',
    'assets/background_images/Dark_Green.jpg',
    'assets/background_images/Light_Blue.jpg',
    'assets/background_images/Light_Green.jpg',
    'assets/background_images/Orange.jpg',
    'assets/background_images/Red.jpg',
    'assets/background_images/Blue_Gradient.jpg',
    'assets/background_images/Green_Gradient.jpg',
    'assets/background_images/Yellow_Gradient.jpg',
    'assets/background_images/White_Gradient.jpg',
    'assets/background_images/Black_Gradient.jpg',
    'assets/background_images/Light_Pink.jpg',
    'assets/background_images/Abstract_1.jpg',
    'assets/background_images/Abstract_2.jpg',
    'assets/background_images/Abstract_3.jpg',
    'assets/background_images/Abstract_4.jpg',
    'assets/background_images/Abstract_5.jpg',
    'assets/background_images/Van_Gogh_10.jpg',
    'assets/background_images/Van_Gogh_11.jpg',
    'assets/background_images/Van_Gogh_12.jpg',
    'assets/background_images/Van_Gogh_13.jpg',
    'assets/background_images/Van_Gogh_14.jpg',
    'assets/background_images/Blue_Galaxy.png',
    'assets/background_images/World_1.png',
    'assets/background_images/World_2.png',
  ];

  setRoomBackgroundImage(Room room, int backgroundImageIndex) {
    if (room.imageIndex != backgroundImageIndex) {
      room.imageIndex = backgroundImageIndex;
      notifyListeners();
    }
    roomListSave(true);
  }

  setRoomName(Room room, String name) {
    log.w('setRoomName room.name ${room.name} name $name');
    if (room.name != name) {
      room.name = name;
      notifyListeners();
    }
    roomListSave(true);
  }

  setRoomBackgroundAndName(Room room, int backgroundImageIndex, String name) {
    setRoomBackgroundImage(room, backgroundImageIndex);
    setRoomName(room, name);
  }

  deleteRoom(int roomIndex) async {
    log.w('deleteRoom roomIndex $roomIndex');
    if (roomList.length > roomIndex) {
      pageController.animateToPage(
        roomIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      roomList.removeAt(roomIndex);
      pageController.jumpToPage(roomIndex - 1);
      notifyListeners();
    }
    roomListSave(true);
  }

  PageController pageController;

  addRoom(int fromPageIndex) async {
    log.w('addRoom');
    var millisecondsSinceEpoch =
        DateTime.now().millisecondsSinceEpoch.toString();
    millisecondsSinceEpoch = millisecondsSinceEpoch.substring(
        millisecondsSinceEpoch.length - 4, millisecondsSinceEpoch.length);
    var newRoom = Room(
      name: 'Room ' + millisecondsSinceEpoch,
      imageIndex: random.nextInt(gd.backgroundImage.length),
      row1: [],
      row2: [],
      row3: [],
      row4: [],
    );

    roomList.insert(fromPageIndex + 1, newRoom);
    pageController.animateToPage(
      fromPageIndex,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );

    roomListSave(true);
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }

  swapRoom(int oldRoomIndex, int newRoomIndex) {
    if (oldRoomIndex == newRoomIndex) {
      log.e('oldRoomIndex==newRoomIndex');
      return;
    }

    log.w('swapRoom oldRoomIndex $oldRoomIndex newRoomIndex $newRoomIndex');

    Room oldRoom = roomList[oldRoomIndex];
    roomList.remove(oldRoom);
    roomList.insert(newRoomIndex, oldRoom);

    pageController.animateToPage(newRoomIndex - 1,
        duration: Duration(milliseconds: 500), curve: Curves.ease);

    roomListSave(true);
    notifyListeners();
  }

  Timer _roomListSaveTimer;

  void roomListSave(bool saveFirebase) {
    notifyListeners();
    _roomListSaveTimer?.cancel();
    _roomListSaveTimer = null;
    _roomListSaveTimer = Timer(Duration(seconds: 5), () {
      roomListSaveActually(saveFirebase);
    });
  }

  void roomListSaveActually(bool saveFirebase) {
    log.d("roomListSaveActually $saveFirebase");
    _roomListSaveTimer?.cancel();
    _roomListSaveTimer = null;
    try {
      var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
      url = url.replaceAll("/", "-");
      url = url.replaceAll(":", "-");
      gd.saveString('roomList $url', jsonEncode(roomList));
      if (saveFirebase) roomListSaveFirebase();
      log.w('roomListSave $url roomList.length ${roomList.length}');
    } catch (e) {
      log.w("roomListSave $e");
    }
  }

  void roomListSaveFirebase() async {
    var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
    url = url.replaceAll("/", "-");
    url = url.replaceAll(":", "-");
    if (gd.firebaseUser != null) {
      log.w(
          'roomListSaveFirebase roomListSave $url roomList.length ${roomList.length}');

      Firestore.instance
          .collection('UserData')
          .document('${gd.firebaseUser.uid}')
          .updateData(
        {
          'roomList $url': jsonEncode(roomList),
        },
      );
    }
  }

  String _roomListString;

  String get roomListString => _roomListString;

  set roomListString(val) {
    _roomListString = val;

    if (_roomListString != null && _roomListString.length > 0) {
      log.w('FOUND _roomListString $_roomListString');
//        List<dynamic> roomListJson = jsonDecode(_roomListString);

      roomList.clear();
      roomList = [];

      var roomListJson = jsonDecode(_roomListString);

      log.w("roomListJson $roomListJson");

      for (var roomJson in roomListJson) {
        Room room = Room.fromJson(roomJson);
        log.d('addRoom ${room.name}');
        roomList.add(room);
      }
      log.d('loginDataList.length ${roomList.length}');
    }
//      else if(currentUrl)
//        {
//
//        }
    else {
      log.w('CAN NOT FIND roomList adding default data');
      roomList.clear();
      roomList = [];
      for (var room in roomListDefault) {
        roomList.add(room);
      }

      notifyListeners();
    }
  }

  var emptySliver = SliverFixedExtentList(
    itemExtent: 0,
    delegate: SliverChildListDelegate(
      [],
    ),
  );

  String textToDisplay(String text) {
    text = text.replaceAll('_', ' ');
    text = text.replaceAll('  ', ' ');

    var splits = text.split(" ");
    var recVal = "";
    for (int i = 0; i < splits.length; i++) {
      var split = splits[i];
      if (split.length > 1) {
        recVal = recVal + split[0].toUpperCase() + split.substring(1) + " ";
      } else if (split.length > 0) {
        recVal = recVal + split[0].toUpperCase() + " ";
      } else {
        recVal = recVal + '???' + " ";
      }
    }
    return recVal.trim();
//    if (text.length > 1) {
//      return text[0].toUpperCase() + text.substring(1);
//    } else if (text.length > 0) {
//      return text[0].toUpperCase();
//    } else {
//      return '???';
//    }
  }

//  Map<String, String> toggleStatusMap = {};

  void toggleStatus(Entity entity) {
//    toggleStatusMap[entity.entityId] = random.nextInt(10).toString();
//    log.d("toggleStatusMap ${toggleStatusMap.values.toList()}");
    if (entity.entityType != EntityType.lightSwitches &&
        entity.entityType != EntityType.scriptAutomation &&
        entity.entityType != EntityType.climateFans &&
        entity.entityType != EntityType.mediaPlayers &&
        entity.entityType != EntityType.group) {
      return;
    }

    eventEntity(entity.entityId);
    delayGetStatesTimer(5);
    entity.toggleState();
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  Map<String, bool> clickedStatus = {};
  bool getClickedStatus(String entityId) {
    if (clickedStatus[entityId] != null) return clickedStatus[entityId];
    return false;
  }

  void setState(Entity entity, String state, String message) {
    entity.state = state;
    delayGetStatesTimer(5);
    webSocket.send(message);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void setFanSpeed(Entity entity, String speed, String message) {
    delayGetStatesTimer(5);
    entity.speed = speed;
    entity.state = "on";
    webSocket.send(message);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void setFanOscillating(Entity entity, bool oscillating, String message) {
    delayGetStatesTimer(5);
    entity.oscillating = oscillating;
    webSocket.send(message);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void sendSocketMessage(message) {
//    log.d("sendSocketMessage $outMsg");
    webSocket.send(message);
    HapticFeedback.mediumImpact();
    gd.delayGetStatesTimer(5);
  }

  Timer _sendSocketMessageDelay;

  void sendSocketMessageDelay(outMsg, int delay) {
    _sendSocketMessageDelay?.cancel();
    _sendSocketMessageDelay = null;
    _sendSocketMessageDelay = Timer(Duration(seconds: delay), () {
      sendSocketMessage(outMsg);
    });
  }

  Timer _delayGetStates;

  void delayGetStatesTimer(int seconds) {
    _delayGetStates?.cancel();
    _delayGetStates = null;

//    _delayGetStates = Timer(Duration(seconds: seconds), delayGetStates);
    _delayGetStates = Timer(Duration(seconds: seconds), httpApiStates);
  }

  void delayGetStates() {
    var outMsg = {'id': gd.socketId, 'type': 'get_states'};
    var message = jsonEncode(outMsg);
    webSocket.send(message);
    gd.webSocketConnectionStatus = 'Sending get_states';
    log.w('delayGetStates!');
  }

  List<String> get entitiesInRoomsExceptDefault {
    List<String> recVal = [];
    for (int i = 0; i < roomList.length - 2; i++) {
      recVal = recVal + roomList[i].row2;
    }
    return recVal;
  }

  void removeEntityInRoom(String entityId, int roomIndex, String friendlyName,
      BuildContext context) {
    log.w('removeEntityInRoom $entityId roomIndex $roomIndex');
    if (gd.roomList[roomIndex].row2.contains(entityId)) {
      gd.roomList[roomIndex].row2.remove(entityId);
      notifyListeners();
      Fluttertoast.showToast(
          msg: "Removed $friendlyName from ${roomList[roomIndex].name}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
          textColor: Theme.of(context).textTheme.title.color,
          fontSize: 14.0);
      roomListSave(true);
    }
    delayCancelEditModeTimer(300);
  }

  void showEntityInRoom(String entityId, int roomIndex, String friendlyName,
      BuildContext context) {
    log.w('showEntityInRoom $entityId roomIndex $roomIndex');
    if (!gd.roomList[roomIndex].row2.contains(entityId)) {
      gd.roomList[roomIndex].row2.add(entityId);
      notifyListeners();
      Fluttertoast.showToast(
          msg: "Added $friendlyName to ${roomList[roomIndex].name}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
          textColor: Theme.of(context).textTheme.title.color,
          fontSize: 14.0);
      roomListSave(true);
    }
    delayCancelEditModeTimer(300);
  }

  IconData climateModeToIcon(String text) {
    text = text.toLowerCase();
    if (text.contains('off')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:power');
    }
    if (text.contains('cool')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:snowflake');
    }
    if (text.contains('heat')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:weather-sunny');
    }
    if (text.contains('fan')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:fan');
    }
    return MaterialDesignIcons.getIconDataFromIconName('mdi:thermometer');
  }

  Color climateModeToColor(String text) {
    text = text.toLowerCase();
    if (text.contains('off')) {
      return ThemeInfo.colorBottomSheetReverse.withOpacity(0.75);
    }
    if (text.contains('heat')) {
      return Colors.red;
    }
    if (text.contains('cool')) {
      return Colors.green;
    }
    return Colors.amber;
  }

  ViewMode _viewMode = ViewMode.normal;

  get viewMode => _viewMode;

  set viewMode(ViewMode viewMode) {
    if (viewMode == ViewMode.edit) {
      delayCancelEditModeTimer(300);
    }
    if (viewMode == ViewMode.sort) {
      delayCancelSortModeTimer(300);
    }
    if (_viewMode != viewMode) {
      _viewMode = viewMode;
      notifyListeners();
    }
  }

  Timer _delayCancelSortMode;

  void delayCancelSortModeTimer(int seconds) {
    _delayCancelSortMode?.cancel();
    _delayCancelSortMode = null;

    _delayCancelSortMode =
        Timer(Duration(seconds: seconds), delayCancelSortMode);
  }

  void delayCancelSortMode() {
    viewMode = ViewMode.normal;
    log.w('delayCancelSortMode!');
  }

  void toggleSortMode() {
    if (viewMode == ViewMode.sort) {
      viewMode = ViewMode.normal;
    } else {
      viewMode = ViewMode.sort;
    }
    notifyListeners();
  }

  Timer _delayCancelEditMode;

  void delayCancelEditModeTimer(int seconds) {
    _delayCancelEditMode?.cancel();
    _delayCancelEditMode = null;

    _delayCancelEditMode =
        Timer(Duration(seconds: seconds), delayCancelEditMode);
  }

  void delayCancelEditMode() {
    viewMode = ViewMode.normal;
    log.w('delayCancelEditMode!');
  }

  void toggleEditMode() {
    if (viewMode == ViewMode.edit) {
      viewMode = ViewMode.normal;
    } else {
      viewMode = ViewMode.edit;
    }
    notifyListeners();
  }

  String entityTypeCombined(String entityId) {
    entityId = entityId.split('.').first;
    if (entityId.contains('fan.') || entityId.contains('climate.')) {
      return 'climateFans';
    } else if (entityId.contains('camera.')) {
      return 'cameras';
    } else if (entityId.contains('media_player.')) {
      return 'mediaPlayers';
    } else if (entityId.contains('script.') ||
        entityId.contains('automation.')) {
      return 'scriptAutomation';
    } else if (entityId.contains('light.') ||
        entityId.contains('switch.') ||
        entityId.contains('cover.') ||
        entityId.contains('input_boolean.') ||
        entityId.contains('lock.') ||
        entityId.contains('vacuum.')) {
      return 'lightSwitches';
    } else {
      return 'accessories';
    }
  }

  double mapNumber(
      double x, double inMin, double inMax, double outMin, double outMax) {
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }

  int colorCap(int x, int inMin, int inMax) {
    if (x < inMin) {
      return inMin;
    }
    if (x > inMax) {
      return inMax;
    }
    return x;
  }

//  List<String> requireSlideToOpen = [];

  void requireSlideToOpenAddRemove(String entityId) {
    if (gd.entitiesOverride[entityId] != null &&
        gd.entitiesOverride[entityId].openRequireAttention != null &&
        gd.entitiesOverride[entityId].openRequireAttention == true) {
      gd.entitiesOverride[entityId].openRequireAttention = false;
    } else {
      var entitiesOverride = gd.entitiesOverride[entityId];
      if (entitiesOverride == null) entitiesOverride = new EntityOverride();
      entitiesOverride.openRequireAttention = true;
      gd.entitiesOverride[entityId] = entitiesOverride;
    }
    notifyListeners();
    entitiesOverrideSave(true);
  }

  DeviceSetting deviceSetting = DeviceSetting(
    phoneLayout: 3,
    tabletLayout: 69,
    shapeLayout: 1,
    themeIndex: 1,
    lastArmType: "arm_away",
    settingLocked: false,
    settingPin: "0000",
    lockOut: "",
    failAttempt: 0,
    backgroundPhoto: [],
  );

  String _deviceSettingString;

  String get deviceSettingString => _deviceSettingString;

  set deviceSettingString(val) {
    _deviceSettingString = val;

    if (_deviceSettingString != null && _deviceSettingString.length > 0) {
      log.w('FOUND deviceSetting _deviceSettingString $_deviceSettingString');

      val = jsonDecode(val);
      deviceSetting = DeviceSetting.fromJson(val);
    } else {
      log.w('CAN NOT FIND deviceSetting adding default data');
      deviceSetting.phoneLayout = 3;
      deviceSetting.tabletLayout = 69;
      deviceSetting.shapeLayout = 1;
      deviceSetting.themeIndex = 1;
      deviceSetting.lastArmType = "arm_away";
      deviceSetting.settingLocked = false;
      deviceSetting.settingPin = "0000";
      deviceSetting.lockOut = "";
      deviceSetting.failAttempt = 0;
      deviceSetting.backgroundPhoto = [];
    }

    notifyListeners();
  }

  void deviceSettingSave() {
    log.d("deviceSettingSave");

    try {
      var jsonDeviceSetting = {
        'phoneLayout': deviceSetting.phoneLayout,
        'tabletLayout': deviceSetting.tabletLayout,
        'shapeLayout': deviceSetting.shapeLayout,
        'themeIndex': deviceSetting.themeIndex,
        'lastArmType': deviceSetting.lastArmType,
        'settingLocked': deviceSetting.settingLocked,
        'settingPin': deviceSetting.settingPin,
        'lockOut': deviceSetting.lockOut,
        'failAttempt': deviceSetting.failAttempt,
        'backgroundPhoto': deviceSetting.backgroundPhoto,
      };

      var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
      url = url.replaceAll("/", "-");
      url = url.replaceAll(":", "-");

      gd.saveString('deviceSetting $url', jsonEncode(jsonDeviceSetting));
      log.w('save deviceSetting $url $jsonDeviceSetting');
    } catch (e) {
      log.w("deviceSettingSave $e");
    }
    notifyListeners();
  }

  BaseSetting baseSetting = BaseSetting(notificationDevices: [], colorPicker: [
    "0xffEEEEEE",
    "0xffEF5350",
    "0xffFFCA28",
    "0xff66BB6A",
    "0xff42A5F5",
    "0xffAB47BC",
  ]);

  String _baseSettingString;

  String get baseSettingString => _baseSettingString;

  set baseSettingString(val) {
    _baseSettingString = val;

    if (_baseSettingString != null && _baseSettingString.length > 0) {
      log.w('FOUND _baseSettingString $_baseSettingString');

      val = jsonDecode(val);
      baseSetting = BaseSetting.fromJson(val);
    } else {
      log.w('CAN NOT FIND baseSetting adding default data');
      baseSetting.notificationDevices = [];
      baseSetting.colorPicker = [
        "0xffEEEEEE",
        "0xffEF5350",
        "0xffFFCA28",
        "0xff66BB6A",
        "0xff42A5F5",
        "0xffAB47BC",
      ];
    }
    notifyListeners();
  }

  Timer _baseSettingSaveTimer;

  void baseSettingSave(bool saveFirebase) {
    notifyListeners();
    _baseSettingSaveTimer?.cancel();
    _baseSettingSaveTimer = null;
    _baseSettingSaveTimer = Timer(Duration(seconds: 5), () {
      baseSettingSaveActually(saveFirebase);
    });
  }

  void baseSettingSaveActually(bool saveFirebase) {
    log.d("baseSettingSaveActually $saveFirebase");

    try {
      var jsonBaseSetting = {
        'notificationDevices': baseSetting.notificationDevices,
        'colorPicker': baseSetting.colorPicker,
        'webView1Url': baseSetting.webView1Url,
        'webView2Url': baseSetting.webView2Url,
        'webView3Url': baseSetting.webView3Url,
      };

      var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
      url = url.replaceAll("/", "-");
      url = url.replaceAll(":", "-");

      gd.saveString('baseSetting $url', jsonEncode(jsonBaseSetting));
      log.w('save baseSetting $url $jsonBaseSetting');

      if (saveFirebase) baseSettingSaveFirebase();
    } catch (e) {
      log.w("baseSettingSave $e");
    }
    notifyListeners();
  }

  BaseSetting baseSettingHassKit = BaseSetting(
    colorPicker: [
      "0xffEEEEEE",
      "0xffEF5350",
      "0xffFFCA28",
      "0xff66BB6A",
      "0xff42A5F5",
      "0xffAB47BC",
    ],
    notificationDevices: [
      "fan.acorn_fan",
      "climate.air_conditioner_1",
      "cover.cover_06",
      "cover.cover_03",
      "light.light_01",
      "lock.lock_9",
      "light.gateway_light_7c49eb891797",
      "switch.socket_sonoff_s20",
      "switch.tuya_neo_coolcam_10a",
      "climate.air_conditioner_2",
      "climate.air_conditioner_3",
      "climate.air_conditioner_4",
      "climate.air_conditioner_5",
      "fan.kaze_fan",
      "fan.lucci_air_fan",
      "fan.super_fan",
    ],
  );

  void baseSettingSaveFirebase() {
    if (gd.firebaseUser != null) {
      var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
      url = url.replaceAll("/", "-");
      url = url.replaceAll(":", "-");

      var jsonBaseSetting = baseSetting.toJson();

      log.w('baseSettingSaveFirebase $url');
      Firestore.instance
          .collection('UserData')
          .document('${gd.firebaseUser.uid}')
          .updateData(
        {
          'baseSetting $url': jsonEncode(jsonBaseSetting),
        },
      );
    }
  }

  Map<String, EntityOverride> entitiesOverride = {};
  String _entitiesOverrideString;

  String get entitiesOverrideString => _entitiesOverrideString;

  set entitiesOverrideString(val) {
    if (_entitiesOverrideString != val) {
      _entitiesOverrideString = val;

      if (_entitiesOverrideString != null &&
          _entitiesOverrideString.length > 0) {
        log.w('FOUND _entitiesOverrideString $_entitiesOverrideString');
        entitiesOverride = {};

        Map<String, dynamic> entitiesOverrideJson =
            jsonDecode(entitiesOverrideString);

        for (var entityOverrideJson in entitiesOverrideJson.keys) {
          var entitiesOverrideId = entityOverrideJson;
          var entitiesOverrideIdList = entitiesOverrideJson[entitiesOverrideId];
          entitiesOverride[entitiesOverrideId] =
              EntityOverride.fromJson(entitiesOverrideIdList);
        }
        log.d('entitiesOverride.length ${entitiesOverride.length}');
      } else {
        log.w('CAN NOT FIND entitiesOverride');
        entitiesOverride = {};
      }

      notifyListeners();
    }
  }

  Timer _entitiesOverrideSaveTimer;

  void entitiesOverrideSave(bool saveFirebase) {
    notifyListeners();
    _entitiesOverrideSaveTimer?.cancel();
    _entitiesOverrideSaveTimer = null;
    _entitiesOverrideSaveTimer = Timer(Duration(seconds: 5), () {
      entitiesOverrideSaveActually(saveFirebase);
    });
  }

  void entitiesOverrideSaveActually(bool saveFirebase) {
    log.d("entitiesOverrideSaveActually $saveFirebase");

    try {
      Map<String, EntityOverride> entitiesOverrideClean = {};

      for (var key in gd.entitiesOverride.keys) {
        var entityOverrideClean = gd.entitiesOverride[key];
        if (entityOverrideClean.friendlyName != null &&
                entityOverrideClean.friendlyName.length > 0 ||
            entityOverrideClean.icon != null &&
                entityOverrideClean.icon.length > 0 ||
            entityOverrideClean.openRequireAttention != null &&
                entityOverrideClean.openRequireAttention == true) {
          entitiesOverrideClean[key] = entityOverrideClean;
        }
      }
      entitiesOverride = entitiesOverrideClean;
      gd.saveString('entitiesOverride', jsonEncode(entitiesOverride));
      log.w('save entitiesOverride.length ${entitiesOverride.length}');
      if (saveFirebase) entitiesOverrideSaveFirebase();
    } catch (e) {
      log.w("entitiesOverrideSave $e");
    }
    notifyListeners();
  }

  void entitiesOverrideSaveFirebase() {
    if (gd.firebaseUser != null) {
      log.w(
          'entitiesOverrideSaveFirebase entitiesOverride.length ${entitiesOverride.length}');

      Firestore.instance
          .collection('UserData')
          .document('${gd.firebaseUser.uid}')
          .updateData(
        {
          'entitiesOverride': jsonEncode(entitiesOverride),
        },
      );
    }
  }

  List<String> iconsOverride = [
//    "",
//    "mdi:account",
//    "mdi:air-conditioner",
//    "mdi:air-filter",
//    "mdi:air-horn",
//    "mdi:air-purifier",
//    "mdi:airplay",
//    "mdi:alert",
//    "mdi:alert-outline",
//    "mdi:battery-80",
//    "mdi:balloon",
//    "mdi:bed-empty",
//    "mdi:bed-king",
//    "mdi:bed-queen",
//    "mdi:blinds",
//    "mdi:blur",
//    "mdi:blur-linear",
//    "mdi:blur-off",
//    "mdi:blur-radial",
//    "mdi:brightness-5",
//    "mdi:brightness-7",
//    "mdi:camera",
//    "mdi:candle",
//    "mdi:candycane",
//    "mdi:cast",
//    "mdi:ceiling-light",
//    "mdi:check-outline",
//    "mdi:checkbox-blank-circle-outline",
//    "mdi:checkbox-marked-circle",
//    "mdi:desk-lamp",
//    "mdi:dip-switch",
//    "mdi:doorbell-video",
//    "mdi:door-closed",
//    "mdi:fan",
//    "mdi:fire",
//    "mdi:flash",
//    "mdi:floor-lamp",
//    "mdi:flower",
//    "mdi:food-fork-drink",
//    "mdi:garage",
//    "mdi:gauge",
//    "mdi:group",
//    "mdi:home",
//    "mdi:home-automation",
//    "mdi:home-outline",
//    "mdi:hotel",
//    "mdi:lamp",
//    "mdi:lava-lamp",
//    "mdi:leaf",
//    "mdi:light-switch",
//    "mdi:lightbulb",
//    "mdi:lightbulb-off",
//    "mdi:lightbulb-off-outline",
//    "mdi:lightbulb-outline",
//    "mdi:lighthouse",
//    "mdi:lighthouse-on",
//    "mdi:lock",
//    "mdi:music-note",
//    "mdi:music-note-off",
//    "mdi:page-layout-sidebar-right",
//    "mdi:pine-tree",
//    "mdi:power",
//    "mdi:power-cycle",
//    "mdi:power-off",
//    "mdi:power-on",
//    "mdi:power-plug",
//    "mdi:power-plug-off",
//    "mdi:power-settings",
//    "mdi:power-sleep",
//    "mdi:power-socket",
//    "mdi:power-socket-au",
//    "mdi:power-socket-eu",
//    "mdi:power-socket-uk",
//    "mdi:power-socket-us",
//    "mdi:power-standby",
//    "mdi:radiator",
//    "mdi:robot-vacuum",
//    "mdi:script-text",
//    "mdi:server-network",
//    "mdi:server-network-off",
//    "mdi:shield-check",
//    "mdi:silverware-fork-knife",
//    "mdi:snowflake",
//    "mdi:speaker",
//    "mdi:square",
//    "mdi:square-outline",
//    "mdi:stairs",
//    "mdi:theater",
//    "mdi:thermometer",
//    "mdi:thermostat",
//    "mdi:timer",
//    "mdi:toggle-switch",
//    "mdi:toggle-switch-off",
//    "mdi:toggle-switch-off-outline",
//    "mdi:toggle-switch-outline",
//    "mdi:toilet",
//    "mdi:track-light",
//    "mdi:vibrate",
//    "mdi:video-switch",
//    "mdi:walk",
//    "mdi:wall-sconce",
//    "mdi:wall-sconce-flat",
//    "mdi:wall-sconce-variant",
//    "mdi:water",
//    "mdi:water-off",
//    "mdi:water-percent",
//    "mdi:weather-partly-cloudy",
//    "mdi:webcam",
//    "mdi:white-balance-incandescent",
//    "mdi:white-balance-iridescent",
//    "mdi:white-balance-sunny",
//    "mdi:window-closed",
//    "mdi:window-shutter",
  ];

  IconData mdiIcon(String iconString) {
    try {
      return MaterialDesignIcons.getIconDataFromIconName(iconString);
    } catch (e) {
      log.e("mdiIcon $e");
      return MaterialDesignIcons.getIconDataFromIconName("help-box");
    }
  }

  String getNulString(String input) {
    try {
      return input;
    } catch (e) {
      return "";
    }
  }

  int getNullInt(int input) {
    if (input == null) {
      return 0;
    }
    return input;
  }

  AppLifecycleState _lastLifecycleState;

  AppLifecycleState get lastLifecycleState => _lastLifecycleState;

  set lastLifecycleState(AppLifecycleState val) {
    if (_lastLifecycleState != val) {
      _lastLifecycleState = val;
      notifyListeners();
    }
  }

  FirebaseUser _firebaseUser;
  FirebaseUser get firebaseUser => _firebaseUser;
  set firebaseUser(FirebaseUser val) {
    if (_firebaseUser != val) {
      log.e("_firebaseUser != val _firebaseUser $_firebaseUser val $val");
      _firebaseUser = val;
      getSettings("_firebaseUser != null");
      createFirebaseDocument();
      getStreamData();
      notifyListeners();
    }
  }

  void createFirebaseDocument() async {
    if (_firebaseUser != null) {
      log.d(
          "_firebaseUser uid ${_firebaseUser.uid} email ${_firebaseUser.email} "
          "photoUrl ${_firebaseUser.photoUrl} phoneNumber ${_firebaseUser.phoneNumber} displayName ${_firebaseUser.displayName}");

      Firestore.instance
          .collection('UserData')
          .document('${gd.firebaseUser.uid}')
          .get()
          .then(
        (DocumentSnapshot ds) {
          // use ds as a snapshot
//            log.d("ds.exists ${ds.exists}");
          if (!ds.exists) {
            Firestore.instance
                .collection('UserData')
                .document('${gd.firebaseUser.uid}')
                .setData(
              {
                'created': DateTime.now(),
              },
            );
          }
        },
      );
    }
  }

  Future<void> assignFirebaseUser(
      GoogleSignInAccount googleSignInAccount) async {
    try {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      gd.firebaseUser = authResult.user;
    } catch (error) {
      print(error);
    }
  }

  GoogleSignInAccount _googleSignInAccount;
  GoogleSignInAccount get googleSignInAccount => _googleSignInAccount;

  set googleSignInAccount(GoogleSignInAccount googleSignInAccount) {
    if (_googleSignInAccount != googleSignInAccount) {
      _googleSignInAccount = googleSignInAccount;
      log.w("_firebaseCurrentUser != firebaseCurrentUser");

      if (googleSignInAccount != null) {
        log.w("get the FirebaseUser");
        assignFirebaseUser(googleSignInAccount);
      } else {
        firebaseUser = null;
      }
      log.e("googleSignInAccount notifyListeners");
      notifyListeners();
    }
  }

  Stream<DocumentSnapshot> snapshots;

  getStreamData() async {
    if (firebaseUser != null) {
      gd.snapshots = Firestore.instance
          .collection('UserData')
          .document("${firebaseUser.uid}")
          .snapshots();

      if (gd.snapshots != null) {
        await for (var documents in gd.snapshots) {
          if (firebaseUser != null && documents.data != null) {
            log.d("getStreamData streamData ${documents.data.length}");

            var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
            url = url.replaceAll("/", "-");
            url = url.replaceAll(":", "-");

            if (documents.data["entitiesOverride"] != null &&
                documents.data["entitiesOverride"].toString().length > 0) {
              log.w(
                  "getStreamData entitiesOverride.length ${documents.data["entitiesOverride"].toString().length}");
              gd.entitiesOverrideString = documents.data["entitiesOverride"];
            }

            if (documents.data["baseSetting $url"] != null &&
                documents.data["baseSetting $url"].toString().length > 0) {
              log.w(
                  "getStreamData baseSetting.length ${documents.data["baseSetting $url"].toString().length}");
              gd.baseSettingString = documents.data["baseSetting $url"];
            }

            if (documents.data["roomList $url"] != null &&
                documents.data["roomList $url"].toString().length > 0) {
              log.w(
                  "getStreamData roomList.length ${documents.data["roomList $url"].toString().length}");
              gd.roomListString = documents.data["roomList $url"];
            }
          }
        }
      }
    } else {
      gd.snapshots = null;
    }
  }

  getSettings(String reason) async {
    log.e("getSettings FROM $reason");
    //NO URL return empty data

    if (loginDataList.length < 1) {
      loginDataList.add(loginDataHassKit);
      loginDataCurrent = loginDataHassKit;
    }

    if (!gd.autoConnect ||
        gd.currentUrl == "" ||
        gd.loginDataCurrent.url == null ||
        !isURL(gd.loginDataCurrent.url, protocols: ['http', 'https'])) {
      log.e("getSettings gd.autoConnect");
      gd.roomList = [];
      gd.entitiesOverride = {};
      return;
    }

    var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
    url = url.replaceAll("/", "-");
    url = url.replaceAll(":", "-");

    //force the trigger reset
    log.w(
        "force the trigger reset settingMobileAppString load settingMobileApp $url");
    gd.settingMobileAppString = "";
    gd.settingMobileAppString = await gd.getString('settingMobileApp $url');
    gd.locationZones.clear();
    gd.locationUpdateTime = DateTime.now().subtract(Duration(days: 1));

    //force the trigger reset
    log.w(
        "force the trigger reset deviceSettingString load deviceSetting $url");
    gd.deviceSettingString = "";
    gd.deviceSettingString = await gd.getString('deviceSetting $url');

    //no firebase return load disk data
    if (gd.firebaseUser == null) {
      log.e("gd.firebaseUser == null");

      //force the trigger reset
      log.w(
          "force the trigger reset entitiesOverrideString load entitiesOverride");
      gd.entitiesOverrideString = "";
      gd.entitiesOverrideString = await gd.getString('entitiesOverride');

      //force the trigger reset
      log.w("force the trigger reset baseSettingString load baseSetting $url");
      gd.baseSettingString = "";
      gd.baseSettingString = await gd.getString('baseSetting $url');
      if (gd.baseSettingString == null || gd.baseSettingString.length < 1) {
        log.w(
            "gd.baseSettingString == null || gd.baseSettingString.length < 1");
        if (gd.currentUrl == "http://hasskit.duckdns.org:8123") {
          log.w(
              "gd.baseSettingString currentUrl == http://hasskit.duckdns.org:8123");
          gd.baseSettingString = jsonEncode(gd.baseSettingHassKit);
        }
      }
      //force the trigger reset
      log.w("force the trigger reset roomListString load roomList $url");
      gd.roomListString = "";
      gd.roomListString = await gd.getString('roomList $url');
      if (gd.roomListString == null || gd.roomListString.length < 1) {
        if (gd.currentUrl == "http://hasskit.duckdns.org:8123") {
          gd.roomListString = jsonEncode(gd.roomListHassKit);
        } else {
          gd.roomListString = jsonEncode(gd.roomListDefault);
        }
      }
      return;
    }

    log.e("gd.firebaseCurrentUser != null");

    downloadCloudData();
  }

  void downloadCloudData() async {
    log.w("getCloudData");
    Firestore.instance
        .collection('UserData')
        .document('${gd.firebaseUser.uid}')
        .get()
        .then(
      (DocumentSnapshot ds) {
        log.w("downloadCloudData gd.firebaseCurrentUser != null ds.exists");
        var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
        url = url.replaceAll("/", "-");
        url = url.replaceAll(":", "-");

        if (ds["entitiesOverride"] != null &&
            ds["entitiesOverride"].toString().length > 10) {
          //force the trigger reset
          log.w(
              "downloadCloudData entitiesOverride ${ds["entitiesOverride"].toString().length}");
          gd.entitiesOverrideString = ds["entitiesOverride"].toString();
        }

        if (ds['baseSetting $url'] != null &&
            ds['baseSetting $url'].toString().length > 10) {
          log.w(
              "downloadCloudData baseSetting ${ds["baseSetting $url"].toString().length}");
          gd.baseSettingString = ds["baseSetting $url"].toString();
        } else if (gd.currentUrl == "http://hasskit.duckdns.org:8123") {
          log.w(
              "downloadCloudData baseSettingString currentUrl == http://hasskit.duckdns.org:8123");
          gd.baseSettingString = jsonEncode(gd.baseSettingHassKit);
        }

        if (ds['roomList $url'] != null &&
            ds['roomList $url'].toString().length > 10) {
          log.w(
              "downloadCloudData roomList ${ds["roomList $url"].toString().length}");
          gd.roomListString = ds["roomList $url"].toString();
        } else if (gd.currentUrl == "http://hasskit.duckdns.org:8123") {
          log.w(
              "downloadCloudData roomListString currentUrl == http://hasskit.duckdns.org:8123");
          gd.roomListString = jsonEncode(gd.roomListHassKit);
        }
      },
    );

    await Future.delayed(const Duration(milliseconds: 5000));

    roomListSave(false);
    entitiesOverrideSave(false);
    baseSettingSave(false);
  }

  void uploadCloudData() async {
    baseSettingSaveFirebase();
    roomListSaveFirebase();
    entitiesOverrideSaveFirebase();
  }

  void deleteCloudData() async {
    var adaRef = Firestore.instance
        .collection('UserData')
        .document('${gd.firebaseUser.uid}');
    await adaRef.delete();
    createFirebaseDocument();
  }

  String _currentUrl = "";
  String get currentUrl => _currentUrl;
  set currentUrl(String val) {
    if (val != _currentUrl) {
      _currentUrl = val;
      if (_currentUrl != "") {
        getSettings("currentUrl");
      }
      notifyListeners();
    }
  }

  int _cameraStreamId = 0;

  int get cameraStreamId => _cameraStreamId;

  set cameraStreamId(int val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_cameraStreamId != val) {
      _cameraStreamId = val;
      notifyListeners();
    }
  }

  String _cameraStreamUrl = "";

  String get cameraStreamUrl => _cameraStreamUrl;

  set cameraStreamUrl(String val) {
    if (_cameraStreamUrl != val) {
      _cameraStreamUrl = val;
      notifyListeners();
    }
  }

  void requestCameraStream(String entityId) {
    try {
      if (gd.cameraStreamId == 0 && gd.cameraStreamUrl == "") {
        gd.cameraStreamId = gd.socketId;
        var outMsg = {
          "id": gd.cameraStreamId,
          "type": "camera/stream",
          "format": "hls",
          "entity_id": entityId,
        };

        var message = jsonEncode(outMsg);
        webSocket.send(message);
        log.d("requestCameraStream ${jsonEncode(outMsg)}");
      }
    } catch (e) {
      log.e("requestCameraStream $entityId $e");
    }
  }

  List<Sensor> sensors = [];
  List<Location> locations = [];

  String classDefaultIcon(String deviceClass) {
    deviceClass = deviceClass.replaceAll(".", "");
    switch (deviceClass) {
      case "alarm_control_panel":
        return "mdi:shield";
      case "automation":
        return "mdi:home-automation";
      case "binary_sensor":
        return "mdi:run";
      case "camera":
        return "mdi:webcam";
      case "climate":
        return "mdi:thermostat";
      case "cover":
        return "mdi:garage-open";
      case "fan":
        return "mdi:fan";
      case "input_number":
        return "mdi:pan-vertical";
      case "light":
        return "mdi:lightbulb-on";
      case "lock":
        return "mdi:lock-open";
      case "media_player":
        return "mdi:theater";
      case "person":
        return "mdi:account";
      case "sun":
        return "mdi:white-balance-sunny";
      case "switch":
        return "mdi:toggle-switch";
      case "timer":
        return "mdi:timer";
      case "vacuum":
        return "mdi:robot-vacuum";
      case "weather":
        return "mdi:weather-partlycloudy";
      default:
        return "";
    }
  }

  List<Entity> get activeDevicesOn {
    List<Entity> entities = [];
    for (String notificationDevice in baseSetting.notificationDevices) {
      if (gd.entities[notificationDevice] != null &&
          gd.entities[notificationDevice].isStateOn) {
        entities.add(gd.entities[notificationDevice]);
      }
    }
    return entities;
  }

  bool activeDevicesSupportedType(String entityId) {
    if (entityId.contains("light.") ||
        entityId.contains("switch.") ||
        entityId.contains("cover.") ||
        entityId.contains("lock.") ||
        entityId.contains("fan.") ||
        entityId.contains("climate.") ||
        entityId.contains("group.") ||
        entityId.contains("media_player.") ||
        entityId.contains("device_tracker.") ||
        entityId.contains("person.") ||
        entityId.contains("input_boolean.") ||
        entityId.contains("binary_sensor.") ||
        entityId.contains("alarm_control_panel.")) {
      return true;
    }
    return false;
  }

  bool _activeDevicesShow = false;

  bool get activeDevicesShow => _activeDevicesShow;

  set activeDevicesShow(bool val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_activeDevicesShow != val) {
      _activeDevicesShow = val;
      if (activeDevicesShow) activeDevicesOffTimer(60);
      notifyListeners();
    }
  }

  Timer _activeDevicesOffTimer;

  void activeDevicesOffTimer(int seconds) {
    _activeDevicesOffTimer?.cancel();
    _activeDevicesOffTimer = null;

    log.d("entitiesStatusShowTimer delay");

    _activeDevicesOffTimer =
        Timer(Duration(seconds: seconds), activeDevicesShowOff);
  }

  void activeDevicesShowOff() {
    gd.activeDevicesShow = false;
  }

  ScrollController viewNormalController = ScrollController();

  Color stringToColor(String colorString) {
//    String valueString =
//        colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    try {
      colorString = colorString.replaceAll("0x", "");
      colorString = colorString.replaceAll("0X", "");
      colorString = colorString.toUpperCase(); // kind of hacky..
      colorString = colorString.replaceAll("COLOR(", "");
      colorString = colorString.replaceAll(")", "");
      int value = int.parse(colorString, radix: 16);
      Color color = Color(value);
      return color;
    } catch (e) {
      log.d("stringToColor $colorString ");
      log.d("stringToColor $e");
      return Colors.grey;
    }
  }

  String colorToString(Color color) {
    String colorString = color.toString();
    colorString = colorString.toUpperCase();
    colorString = colorString.replaceAll("COLOR(0X", "");
    colorString = colorString.replaceAll(")", "");
    log.d("colorToString ${color.toString()} $colorString");
    return colorString;
  }

  List<String> webViewPresets = [
    "https://embed.windy.com",
    "https://www.yahoo.com/news/weather",
    "https://livescore.com",
  ];

  int webViewSupportMax = 3;

//  var localeData;

  void httpApiStates() async {
    var client = new http.Client();

    var url = gd.currentUrl + "/api/states";
    Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ${gd.loginDataCurrent.longToken}',
    };

    log.d("httpApiStates $url");

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
//        log.w("httpApiStates response.statusCode ${response.statusCode}");
        var jsonResponse = jsonDecode(response.body);
//        log.d("httpApiStates jsonResponse $jsonResponse");
        socketGetStates(jsonResponse);
      } else {
        log.e(
            "httpApiStates Request $url ailed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("httpApiStates e $e");
    } finally {
      client.close();
    }

    if (configVersion != "") return;

    client = new http.Client();
    url = gd.currentUrl + "/api/config";
    log.d("httpApiStates api/config $url");

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("jsonResponse $url $jsonResponse");
        configVersion = jsonResponse['version'];
        configLocationName = jsonResponse['location_name'];
        configUnitSystem =
            Map<String, dynamic>.from(jsonResponse['unit_system']);
        configComponent = List<String>.from(jsonResponse['components']);

        print("configComponent $configComponent");
        print("configLocationName $configLocationName");
        print("configUnitSystem $configUnitSystem");
        print(
            "configUnitSystem['temperature'] ${configUnitSystem['temperature']}");
        print("configVersion $configVersion");
        MobileAppHelper mobileAppHelper = MobileAppHelper();
        mobileAppHelper.check("httpApiStates api/config $url");
      } else {
        log.e(
            "httpApiStates Request $url failed with status: ${response.statusCode}");
      }
    } finally {
      client.close();
    }
  }

  BuildContext mediaQueryContext;
  int get layoutCameraCount {
    if (!isTablet) return 1;

    if (deviceSetting.tabletLayout == 36) {
      if (gd.mediaQueryOrientation == Orientation.portrait) {
        return 1;
      }
      return 2;
    }

    if (deviceSetting.tabletLayout == 69) {
      if (gd.mediaQueryOrientation == Orientation.portrait) {
        return 2;
      }
      return 3;
    }
    if (deviceSetting.tabletLayout == 912) {
      if (gd.mediaQueryOrientation == Orientation.portrait) {
        return 3;
      }
      return 4;
    }
    return deviceSetting.tabletLayout ~/ 3;
  }

  int get layoutButtonCount {
    if (!isTablet) return deviceSetting.phoneLayout;
    if (deviceSetting.tabletLayout == 36) {
      if (gd.mediaQueryOrientation == Orientation.portrait) {
        return 3;
      }
      return 6;
    }
    if (deviceSetting.tabletLayout == 69) {
      if (gd.mediaQueryOrientation == Orientation.portrait) {
        return 6;
      }
      return 9;
    }
    if (deviceSetting.tabletLayout == 912) {
      if (gd.mediaQueryOrientation == Orientation.portrait) {
        return 9;
      }
      return 12;
    }
    return deviceSetting.tabletLayout;
  }

  /// Returns a formatted date string.
  String dateToString(DateTime date) =>
      date.day.toString().padLeft(2, '0') +
      '/' +
      date.month.toString().padLeft(2, '0') +
      '/' +
      date.year.toString();

  double get buttonRatio {
    if (deviceSetting.shapeLayout == 2) return 8 / 5;
    return 1;
  }

  bool fileExists(String url) {
    if (url == null || url.length < 1) {
      return false;
    }
    return FileSystemEntity.typeSync(url) != FileSystemEntityType.notFound;
  }

  String getRoomBackgroundPhoto(int roomIndex) {
    String imageUrl;
    for (var backgroundPhotoString in gd.deviceSetting.backgroundPhoto) {
      if (backgroundPhotoString.contains("[$roomIndex]")) {
        imageUrl = backgroundPhotoString.split("[$roomIndex]").last;
        break;
      }
    }

    if (fileExists(imageUrl)) {
      return imageUrl;
    }
    return null;
  }

  double roundTo05(double input) {
    var inputToInt = input.toInt();
    var decVal = input - inputToInt;
    if (decVal > 0.75) {
      return (inputToInt + 1).toDouble();
    } else if (decVal > 0.25) {
      return inputToInt + 0.5;
    }
    return inputToInt.toDouble();
  }

  String firebaseMessagingToken = "";
  String firebaseMessagingTitle = "";
  String firebaseMessagingBody = "";

  SettingMobileApp settingMobileApp = SettingMobileApp(
    deviceName: "",
    cloudHookUrl: "",
    remoteUiUrl: "",
    secret: "",
    webHookId: "",
    trackLocation: true,
  );

  String _settingMobileAppString;

  String get settingMobileAppString => _settingMobileAppString;

  set settingMobileAppString(val) {
    _settingMobileAppString = val;

    if (_settingMobileAppString != null && _settingMobileAppString.length > 0) {
      log.w(
          'FOUND settingMobileApp _settingMobileAppString $_settingMobileAppString');

      val = jsonDecode(val);
      settingMobileApp = SettingMobileApp.fromJson(val);
    } else {
      log.w('CAN NOT FIND settingMobileApp adding default data');
      settingMobileApp.deviceName = "";
      settingMobileApp.cloudHookUrl = "";
      settingMobileApp.remoteUiUrl = "";
      settingMobileApp.secret = "";
      settingMobileApp.webHookId = "";
      settingMobileApp.trackLocation = true;
    }

    notifyListeners();
  }

  void settingMobileAppSave() {
    log.d("settingMobileAppSave");

    try {
      String settingMobileAppEncoded = jsonEncode(settingMobileApp.toJson());
      var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
      url = url.replaceAll("/", "-");
      url = url.replaceAll(":", "-");

      gd.saveString('settingMobileApp $url', settingMobileAppEncoded);
      log.w('save settingMobileApp $settingMobileAppEncoded');
    } catch (e) {
      log.w("settingMobileAppSave $e");
    }
    notifyListeners();
  }

  DateTime locationUpdateTime = DateTime.parse("2020-01-01 00:00:00");

  double _locationLatitude = 51.48;
  double get locationLatitude => _locationLatitude;
  set locationLatitude(val) {
    if (_locationLatitude != val) {
      _locationLatitude = val;
      notifyListeners();
    }
  }

  double _locationLongitude = 0;
  double get locationLongitude => _locationLongitude;
  set locationLongitude(val) {
    if (_locationLongitude != val) {
      _locationLongitude = val;
      notifyListeners();
    }
  }

  //Update have 5 min cooldown
  int _locationUpdateInterval = 5;
  int get locationUpdateInterval => _locationUpdateInterval;
  set locationUpdateInterval(val) {
    if (_locationUpdateInterval != val) {
      _locationUpdateInterval = val;
      notifyListeners();
    }
  }

//  0.05 = 50 meter default to 0.1 = 100 meter
  double _locationUpdateMinDistance = 0.1;
  double get locationUpdateMinDistance => _locationUpdateMinDistance;
  set locationUpdateMinDistance(val) {
    if (_locationUpdateMinDistance != val) {
      _locationUpdateMinDistance = val;
      notifyListeners();
    }
  }

  bool _locationShowAdvancedSetting = false;
  bool get locationShowAdvancedSetting => _locationShowAdvancedSetting;
  set locationShowAdvancedSetting(val) {
    if (_locationShowAdvancedSetting != val) {
      _locationShowAdvancedSetting = val;
      notifyListeners();
    }
  }

  String _locationUpdateFail = "";
  String get locationUpdateFail => _locationUpdateFail;
  set locationUpdateFail(val) {
    if (_locationUpdateFail != val) {
      _locationUpdateFail = val;
      notifyListeners();
    }
  }

  String _locationUpdateSuccess = "";
  String get locationUpdateSuccess => _locationUpdateSuccess;
  set locationUpdateSuccess(val) {
    if (_locationUpdateSuccess != val) {
      _locationUpdateSuccess = val;
      notifyListeners();
    }
  }

  String get mobileAppState {
    if (entities["device_tracker.${gd.settingMobileApp.deviceName}"] == null) {
      return "...";
    }
    return entities["device_tracker.${gd.settingMobileApp.deviceName}"].state;
  }

  List<LocationZone> locationZones = [];
  DateTime locationRecordTime = DateTime.parse("2020-01-01 00:00:00");

  double getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1); // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(lat1)) *
            Math.cos(deg2rad(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  double deg2rad(deg) {
    return deg * (Math.pi / 180);
  }

  Map<String, dynamic> configUnitSystem = {};
  String configVersion = "";
  String configLocationName = "";
  List<String> configComponent = [];

  String _connectivityStatus = "";
  String get connectivityStatus => _connectivityStatus;
  set connectivityStatus(val) {
    if (_connectivityStatus != val) {
      print("_connectivityStatus $_connectivityStatus val $val");
      _connectivityStatus = val;
      if (_connectivityStatus == "ConnectivityResult.mobile" ||
          _connectivityStatus == "ConnectivityResult.wifi") {
        gd.locationUpdateTime = DateTime.now().subtract(Duration(days: 1));
        GeoLocatorHelper.updateLocation(
            "connectivityStatus $_connectivityStatus");
      }
      notifyListeners();
    }
  }
}
