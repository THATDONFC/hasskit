import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hasskit/helper/LocaleHelper.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/helper/WebSocket.dart';
import 'package:hasskit/view/PageViewBuilder.dart';
import 'package:hasskit/view/SettingPage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';

import 'helper/GeneralData.dart';
import 'helper/GoogleSign.dart';
import 'helper/Logger.dart';
import 'helper/MaterialDesignIcons.dart';
import 'helper/RateMyApp.dart';

void main() {
  runApp(
    EasyLocalization(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => GeneralData(),
            builder: (context) => GeneralData(),
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
              EasylocaLizationDelegate(
                  locale: data.locale, path: 'assets/langs')
            ],
            locale: data.savedLocale,
            supportedLocales: [
              Locale('en', 'US'), //MUST BE FIRST FOR DEFAULT LANGUAGE
              Locale('bg', 'BG'),
              Locale('el', 'GR'),
              Locale('he', 'IL'),
              Locale('nl', 'NL'),
              Locale('ru', 'RU'),
              Locale('sv', 'SE'),
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
  Timer timer10;
  Timer timer30;
  Timer timer5;
  Timer timer60;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(
      () {
        gd.lastLifecycleState = state;

        if (gd.lastLifecycleState == AppLifecycleState.resumed) {
          log.w("didChangeAppLifecycleState ${gd.lastLifecycleState}");

          if (gd.autoConnect) {
            {
              if (gd.connectionStatus != "Connected") {
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    WidgetsBinding.instance.addObserver(this);
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        log.w("googleSignIn.onCurrentUserChanged");
        gd.googleSignInAccount = account;
      });
    });
    googleSignIn.signInSilently();

    timer0 = Timer.periodic(
        Duration(milliseconds: 200), (Timer t) => timer200Callback());
    timer1 =
        Timer.periodic(Duration(seconds: 1), (Timer t) => timer1Callback());
    timer5 =
        Timer.periodic(Duration(seconds: 5), (Timer t) => timer5Callback());
    timer10 =
        Timer.periodic(Duration(seconds: 10), (Timer t) => timer10Callback());
    timer30 =
        Timer.periodic(Duration(seconds: 30), (Timer t) => timer30Callback());
    timer60 =
        Timer.periodic(Duration(seconds: 60), (Timer t) => timer60Callback());

    mainInitState();

    rateMyApp.init().then(
      (_) {
        print('Minimum days : ' + rateMyApp.minDays.toString());
        print('Minimum launches : ' + rateMyApp.minLaunches.toString());
        print('Base launch : ' + gd.dateToString(rateMyApp.baseLaunchDate));
        print('Launches : ' + rateMyApp.launches.toString());
        print(
            'Do not open again ? ' + (rateMyApp.doNotOpenAgain ? 'Yes' : 'No'));

        print('Are conditions met ? ' +
            (rateMyApp.shouldOpenDialog ? 'Yes' : 'No'));

        if (rateMyApp.shouldOpenDialog) {
          rateMyApp.showRateDialog(
            context,
            title: 'Rate This App',
            message:
                'If you like this app, please take a little bit of your time to review it!\n\nIt really helps us and it shouldn\'t take you more than one minute.',
            rateButton: 'Rate',
            noButton: 'No Thanks',
            laterButton: 'Maybe Later',
            ignoreIOS: false,
            dialogStyle: DialogStyle(),
          );
        }
      },
    );
  }

  mainInitState() async {
    log.w("mainInitState showLoading $showLoading");
    log.w("mainInitState...");
    log.w("mainInitState START await loginDataInstance.loadLoginData");
    log.w("mainInitState...");
    log.w("mainInitState gd.loginDataListString");

//    await Future.delayed(const Duration(milliseconds: 500));
    gd.loginDataListString = await gd.getString('loginDataList');
    await gd.getSettings("mainInitState");
  }

  timer200Callback() {}

  timer1Callback() {
    for (String entityId in gd.cameraInfosActive) {
      gd.cameraInfosUpdate(entityId);
    }
  }

  timer5Callback() {
    //in case websocket fail for no reason.
//    gd.httpApiStates();
  }

  timer10Callback() {
    if (gd.connectionStatus != "Connected" && gd.autoConnect) {
      webSocket.initCommunication();
    }
  }

  timer30Callback() {
    if (gd.connectionStatus == "Connected") {
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
    log.w(
        "gd.isTablet ${gd.isTablet} gd.mediaQueryShortestSide ${gd.mediaQueryShortestSide} gd.mediaQueryLongestSide ${gd.mediaQueryLongestSide} orientation ${gd.mediaQueryOrientation}");
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.viewMode} | " +
          "${Localizations.localeOf(context).languageCode} | " +
          "${generalData.baseSetting.phoneLayout} | " +
          "${generalData.baseSetting.tabletLayout} | " +
          "${generalData.baseSetting.shapeLayout} | " +
          "${generalData.mediaQueryHeight} | " +
          "${generalData.connectionStatus} | " +
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
                currentIndex: 0,
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
//                title: TestWidget(),
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
                          child: SinglePage(roomIndex: 0),
//                          child: AnimationTemp(),
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
}
