import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/helper/web_socket.dart';
import 'package:hasskit/helper/device_info.dart';
import 'package:hasskit/view/page_view_builder.dart';
import 'package:hasskit/view/setting_page.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'helper/general_data.dart';
import 'helper/google_sign.dart';
import 'helper/logger.dart';
import 'package:rxdart/subjects.dart';

import 'helper/material_design_icons.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification(
      {@required this.id,
      @required this.title,
      @required this.body,
      @required this.payload});
}

Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
    didReceiveLocalNotificationSubject.add(ReceivedNotification(
        id: id, title: title, body: body, payload: payload));
  });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });

  runApp(
    EasyLocalization(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => GeneralData(),
//            builder: (context) => GeneralData(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    gd = Provider.of<GeneralData>(context, listen: false);
    var data = EasyLocalizationProvider.of(context).data;

    return EasyLocalizationProvider(
      data: data,
      child: Selector<GeneralData, ThemeData>(
        selector: (_, generalData) => generalData.currentTheme,
        builder: (_, currentTheme, __) {
          return MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
              EasylocaLizationDelegate(
                  locale: data.locale, path: 'assets/langs')
            ],
            locale: data.savedLocale,
            supportedLocales: [
              Locale('en', 'US'), //MUST BE FIRST FOR DEFAULT LANGUAGE
              Locale('bg', 'BG'),
              Locale('de', 'DE'),
              Locale('el', 'GR'),
              Locale('es', 'ES'),
              Locale('fr', 'FR'),
              Locale('he', 'IL'),
              Locale('hu', 'HU'),
              Locale('it', 'IT'),
              Locale('nl', 'NL'),
              Locale('pl', 'PL'),
              Locale('pt', 'PT'),
              Locale('ru', 'RU'),
              Locale('sv', 'SE'),
              Locale('uk', 'UA'),
              Locale('vi', 'VN'),
              Locale('zh', 'CN'),
              Locale('zh', 'TW'),
            ],
            debugShowCheckedModeBanner: false,
            theme: currentTheme,
            title: 'HassKit',
            home: HomeView(),
          );
        },
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  bool showLoading = true;
  Timer timer0;
  Timer timer1;
  Timer timer5;
  Timer timer10;
  Timer timer15;
  Timer timer30;
  Timer timer60;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(
      () {
        gd.lastLifecycleState = state;

        if (gd.lastLifecycleState == AppLifecycleState.resumed) {
          log.w("didChangeAppLifecycleState ${gd.lastLifecycleState}");
          log.w("Reset gd.locationUpdateTime");
          gd.locationUpdateTime = DateTime.now();

          if (gd.autoConnect) {
            {
              if (gd.webSocketConnectionStatus != "Connected") {
                webSocket.initCommunication();
                log.w(
                    "didChangeAppLifecycleState webSocket.initCommunication()");
              } else {
                var outMsg = {"id": gd.socketId, "type": "get_states"};
                var outMsgEncoded = json.encode(outMsg);
                webSocket.send(outMsgEncoded);
                log.w(
                    "didChangeAppLifecycleState webSocket.send $outMsgEncoded");
              }
            }
          }
        }
      },
    );
  }

  Future<void> localNotification(String title, String body) async {
    print("_showNotification");
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print("\n\ngd.firebaseMessagingToken\n$token\n\n");
      gd.firebaseMessagingToken = token;
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        if (Platform.isIOS) {
          gd.firebaseMessagingTitle = message["aps"]["alert"]["title"];
          gd.firebaseMessagingBody = message["aps"]["alert"]["body"];
        } else {
          gd.firebaseMessagingTitle = message["notification"]["title"];
          gd.firebaseMessagingBody = message["notification"]["body"];
        }
        localNotification(gd.firebaseMessagingTitle, gd.firebaseMessagingBody);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        gd.firebaseMessagingTitle = message["notification"]["title"];
        gd.firebaseMessagingBody = message["notification"]["body"];
        localNotification(gd.firebaseMessagingTitle, gd.firebaseMessagingBody);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        gd.firebaseMessagingTitle = message["notification"]["title"];
        gd.firebaseMessagingBody = message["notification"]["body"];
        localNotification(gd.firebaseMessagingTitle, gd.firebaseMessagingBody);
      },
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    firebaseCloudMessagingListeners();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    WidgetsBinding.instance.addObserver(this);
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        log.w("googleSignIn.onCurrentUserChanged");
        gd.googleSignInAccount = account;
      });
    });
    googleSignIn.signInSilently();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    timer0 = Timer.periodic(
        Duration(milliseconds: 200), (Timer t) => timer200Callback());
    timer1 =
        Timer.periodic(Duration(seconds: 1), (Timer t) => timer1Callback());
    timer5 =
        Timer.periodic(Duration(seconds: 5), (Timer t) => timer5Callback());
    timer10 =
        Timer.periodic(Duration(seconds: 10), (Timer t) => timer10Callback());
    timer15 =
        Timer.periodic(Duration(seconds: 15), (Timer t) => timer15Callback());
    timer30 =
        Timer.periodic(Duration(seconds: 30), (Timer t) => timer30Callback());
    timer60 =
        Timer.periodic(Duration(seconds: 60), (Timer t) => timer60Callback());

    initStateAsync();
  }

  initStateAsync() async {
    log.w("mainInitState showLoading $showLoading");
    log.w("mainInitState...");
    log.w("mainInitState START await loginDataInstance.loadLoginData");
    log.w("mainInitState...");
    log.w("mainInitState gd.loginDataListString");

//    await Future.delayed(const Duration(milliseconds: 500));
    gd.loginDataListString = await gd.getString('loginDataList');
    await gd.getSettings("mainInitState");
    deviceInfo.getDeviceInfo();
    gd.userBackgroundPathUpdate();
  }

  timer200Callback() {}

  timer1Callback() {
    for (String entityId in gd.cameraInfosActive) {
      gd.cameraInfosUpdate(entityId);
    }
  }

  timer5Callback() {}

  timer10Callback() {
    if (gd.webSocketConnectionStatus != "Connected" && gd.autoConnect) {
      webSocket.initCommunication();
    }
  }

  timer15Callback() {
//    GeoLocatorHelper.updateLocation("timer15Callback");
  }

  timer30Callback() {
    if (gd.webSocketConnectionStatus == "Connected") {
      gd.delayGetStatesTimer(5);
//      use http
//      var outMsg = {"id": gd.socketId, "type": "get_states"};
//      var outMsgEncoded = json.encode(outMsg);
//      webSocket.send(outMsgEncoded);
    }
  }

  timer60Callback() {}

  _afterLayout(_) async {
//    await Future.delayed(const Duration(milliseconds: 1000));

    showLoading = false;
    log.w("showLoading $showLoading");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    gd.mediaQueryContext = context;
    if (gd.isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    if (showLoading) return Container();
    log.w(
        "gd.isTablet ${gd.isTablet} gd.mediaQueryShortestSide ${gd.mediaQueryShortestSide} gd.mediaQueryLongestSide ${gd.mediaQueryLongestSide} orientation ${gd.mediaQueryOrientation}");
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.viewMode} | " +
          "${Localizations.localeOf(context).languageCode} | " +
          "${generalData.deviceSetting.settingLocked} | " +
          "${generalData.deviceSetting.launchIndex} | " +
          "${generalData.deviceSetting.phoneLayout} | " +
          "${generalData.deviceSetting.tabletLayout} | " +
          "${generalData.deviceSetting.shapeLayout} | " +
          "${generalData.mediaQueryHeight} | " +
          "${generalData.webSocketConnectionStatus} | " +
          "${generalData.roomList.length} | ",
      builder: (context, data, child) {
        return Scaffold(
          body: ModalProgressHUD(
            inAsyncCall: showLoading,
            opacity: 1,
            progressIndicator: SpinKitThreeBounce(
              size: 40,
              color: ThemeInfo.colorIconActive.withOpacity(0.5),
            ),
            color: ThemeInfo.colorBackgroundDark,
            child: CupertinoTabScaffold(
              tabBar: CupertinoTabBar(
                backgroundColor: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                onTap: (int) {
                  log.d("CupertinoTabBar onTap $int");
                  gd.viewMode = ViewMode.normal;
                },
                // currentIndex: 0,
                currentIndex: gd.deviceSetting.launchIndex,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
                        "mdi:home-automation")),
                    title: Text(
                      gd.getRoomName(0),
                      maxLines: 1,
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: ThemeInfo.colorBottomSheetReverse),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      MaterialDesignIcons.getIconDataFromIconName(
                          "mdi:view-carousel"),
                    ),
                    title: Text(
//                  gd.getRoomName(gd.lastSelectedRoom + 1),
                      Translate.getString("global.rooms", context),
                      maxLines: 1,
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: ThemeInfo.colorBottomSheetReverse),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
                        "mdi:settings")),
                    title: Text(
                      Translate.getString("global.settings", context),
                      maxLines: 1,
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: ThemeInfo.colorBottomSheetReverse),
                    ),
                  ),
                ],
              ),
              tabBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return CupertinoTabView(
                      builder: (context) {
                        return CupertinoPageScaffold(
//                          child: DeviceInfo(),
                          child: SinglePage(roomIndex: 0),
//                          child: HassKitReview(),
                        );
                      },
                    );
                  case 1:
                    return CupertinoTabView(
                      builder: (context) {
                        return CupertinoPageScaffold(
                          child: PageViewBuilder(),
                        );
                      },
                    );
                  case 2:
                    return CupertinoTabView(
                      builder: (context) {
                        return CupertinoPageScaffold(
                          child: SettingPage(),
                        );
                      },
                    );
                  default:
                    return CupertinoTabView(
                      builder: (context) {
                        return CupertinoPageScaffold(
                          child: SinglePage(roomIndex: 0),
                        );
                      },
                    );
                }
              },
            ),
          ),
        );
      },
    );
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    print("_updateConnectionStatus $result");
    gd.connectivityStatus = result.toString();
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
      default:
    }
  }
}
