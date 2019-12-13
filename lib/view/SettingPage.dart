import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/GoogleSign.dart';
import 'package:hasskit/helper/LocaleHelper.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/RateMyApp.dart';
import 'package:hasskit/helper/SquircleBorder.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/LocalLanguage.dart';
import 'package:hasskit/model/LoginData.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';

import 'HomeAssistantLogin.dart';
import 'ServerSelectPanel.dart';
import 'slivers/SliverHeader.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _controller = TextEditingController();
  bool showConnect = false;
  bool showCancel = false;
  bool keyboardVisible = false;
  FocusNode addressFocusNode = new FocusNode();

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void dispose() {
    _controller.removeListener(addressListener);
    _controller.removeListener(addressFocusNodeListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _controller.addListener(addressListener);
    _controller.addListener(addressFocusNodeListener);
  }

  addressFocusNodeListener() {
    if (addressFocusNode.hasFocus) {
      keyboardVisible = true;
      log.w(
          "addressFocusNode.hasFocus ${addressFocusNode.hasFocus} $keyboardVisible");
    } else {
      keyboardVisible = false;
      log.w(
          "addressFocusNode.hasFocus ${addressFocusNode.hasFocus} $keyboardVisible");
    }
  }

  addressListener() {
    if (isURL(_controller.text.trim(), protocols: ['http', 'https'])) {
//      log.d("validURL = true isURL ${addressController.text}");
      if (!showConnect) {
        showConnect = true;
        setState(() {});
      }
    } else {
//      log.d("validURL = false isURL ${addressController.text}");
      if (showConnect) {
        showConnect = false;
        setState(() {});
      }
    }

    if (_controller.text.trim().length > 0) {
      if (!showCancel) {
        showCancel = true;
        setState(() {});
      }
    } else {
      if (showCancel) {
        showCancel = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // log.w("Widget build SettingPage");
    // if (gd.loginDataCurrent != null) {
    //   var pretext = gd.useSSL ? "https://" : "http://";
    //   log.w("Remove _controller.text ${_controller.text} "
    //       "url ${gd.loginDataCurrent.url} pretext $pretext");
    //   if (gd.loginDataCurrent.getUrl == pretext + _controller.text) {
    //     _controller.clear();
    //   }
    // }

//    return Consumer<GeneralData>(
//      builder: (context, gd, child) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) => ("${generalData.useSSL} | "
          "${generalData.currentTheme} | "
          "${generalData.connectionStatus} | "
          "${generalData.baseSetting.phoneLayout} | "
          "${generalData.baseSetting.tabletLayout} | "
          "${generalData.baseSetting.shapeLayout} | "
          "${generalData.loginDataList.length} | "),
      builder: (_, string, __) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(gd.backgroundImage[10]),
              fit: BoxFit.cover,
            ),
//        gradient: LinearGradient(
//            begin: Alignment.topCenter,
//            end: Alignment.bottomCenter,
//            colors: [
//              Theme.of(context).primaryColorLight,
//              Theme.of(context).cardColor.withOpacity(0.2)
//            ]),
//        color: Theme.of(context).primaryColorLight,
          ),
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
//                leading: Image(
//                  image: AssetImage(
//                      'assets/images/icon_transparent_border_transparent.png'),
//                ),
                backgroundColor: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                largeTitle: Text(
                  Translate.getString("global.settings", context),
                  style: TextStyle(color: ThemeInfo.colorBottomSheetReverse),
                  textScaleFactor: gd.textScaleFactorFix,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SliverHeaderNormal(
                icon: Icon(
                  MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:home-assistant"),
                ),
                title: Translate.getString("settings.home_assistant", context),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            focusNode: addressFocusNode,
                            controller: _controller,
                            decoration: InputDecoration(
                              prefixText: gd.useSSL ? "https://" : "http://",
                              hintText: 'sample.duckdns.org:8123',
                              labelText: Translate.getString(
                                  "settings.new_connection", context),
                              suffixIcon: Opacity(
                                opacity: showCancel ? 1 : 0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel),
                                  onPressed: () {
                                    _controller.clear();
                                    if (keyboardVisible) {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    }
                                  },
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.url,
                            autocorrect: false,
                            onEditingComplete: () {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                          ),
                          Row(
                            children: <Widget>[
                              Switch.adaptive(
                                  activeColor: ThemeInfo.colorIconActive,
                                  value: gd.useSSL,
                                  onChanged: (val) {
                                    gd.useSSL = val;
                                  }),
                              Text(
                                Translate.getString(
                                    "settings.use_https", context),
                                textScaleFactor: gd.textScaleFactorFix,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Expanded(child: Container()),
                              RaisedButton(
                                onPressed: showConnect
                                    ? () {
                                        if (keyboardVisible) {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                        }

                                        _controller.text =
                                            _controller.text.trim();
                                        _controller.text =
                                            _controller.text.toLowerCase();
                                        _controller.text = _controller.text
                                            .replaceAll("https://", "");
                                        _controller.text = _controller.text
                                            .replaceAll("http://", "");
                                        if (_controller.text.contains("/"))
                                          _controller.text =
                                              _controller.text.split("/")[0];

                                        gd.loginDataCurrent = LoginData(
                                            url: gd.useSSL
                                                ? "https://" + _controller.text
                                                : "http://" + _controller.text);
                                        log.w(
                                            "gd.loginDataCurrent.url ${gd.loginDataCurrent.url}");
                                        //prevent autoConnect hijack gd.loginDataCurrent.url
                                        gd.autoConnect = false;
                                        gd.webViewLoading = true;
                                        showModalBottomSheet(
                                          context: context,
                                          elevation: 1,
                                          backgroundColor:
                                              ThemeInfo.colorBottomSheet,
                                          isScrollControlled: true,
                                          useRootNavigator: true,
                                          builder: (context) =>
                                              HomeAssistantLogin(
                                            selectedUrl: gd
                                                    .loginDataCurrent.getUrl +
                                                '/auth/authorize?client_id=' +
                                                gd.loginDataCurrent.getUrl +
                                                "/hasskit"
                                                    '&redirect_uri=' +
                                                gd.loginDataCurrent.getUrl +
                                                "/hasskit",
                                          ),
                                        );
                                      }
                                    : null,
                                child: Text(
                                  Translate.getString(
                                      "settings.connect", context),
                                  textScaleFactor: gd.textScaleFactorFix,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      ServerSelectPanel(gd.loginDataList[index]),
                  childCount: gd.loginDataList.length,
                ),
              ),
              SliverHeaderNormal(
                icon: Icon(
                  MaterialDesignIcons.getIconDataFromIconName("mdi:cloud-sync"),
                ),
                title: Translate.getString("settings.sync", context),
              ),
              GoogleSign(),
              SliverHeaderNormal(
                icon: Icon(
                  MaterialDesignIcons.getIconDataFromIconName("mdi:palette"),
                ),
                title: Translate.getString("settings.theme_color", context),
              ),
              _ThemeSelector(),
              SliverHeaderNormal(
                icon: Icon(
                  MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:view-dashboard-variant"),
                ),
                title: Translate.getString("settings.layout", context),
              ),
              ShapeSelector(),
              LayoutSelector(),
              rateMyApp.doNotOpenAgain &&
                      Theme.of(context).platform == TargetPlatform.iOS
                  ? gd.emptySliver
                  : SliverList(
                      delegate: SliverChildListDelegate([
                      Container(
                        child: RaisedButton(
                          onPressed: () => rateMyApp
                              .showRateDialog(
                                context,
                                title: 'Rate This App',
                                message:
                                    'If you like this app, please take a little bit of your time to review it!\n\nIt really helps us and it shouldn\'t take you more than one minute.',
                                rateButton: 'Rate',
                                noButton: 'No Thanks',
                                laterButton: 'Maybe Later',
                                ignoreIOS: false,
                                dialogStyle: DialogStyle(),
                              )
                              .then((v) => setState(() {})),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                MaterialDesignIcons.getIconDataFromIconName(
                                    "mdi:star-outline"),
                              ),
                              Icon(
                                MaterialDesignIcons.getIconDataFromIconName(
                                    "mdi:star-outline"),
                              ),
                              Icon(
                                MaterialDesignIcons.getIconDataFromIconName(
                                    "mdi:star-outline"),
                              ),
                              Text(
                                " Rate HassKit ",
                                style: TextStyle(color: Colors.black),
                                textScaleFactor: gd.textScaleFactorFix,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Icon(
                                MaterialDesignIcons.getIconDataFromIconName(
                                    "mdi:star-outline"),
                              ),
                              Icon(
                                MaterialDesignIcons.getIconDataFromIconName(
                                    "mdi:star-outline"),
                              ),
                              Icon(
                                MaterialDesignIcons.getIconDataFromIconName(
                                    "mdi:star-outline"),
                              ),
                            ],
                          ),
                        ),
                        padding: EdgeInsets.all(12),
                      ),
                    ])),
              SliverHeaderNormal(
                icon: Icon(
                  MaterialDesignIcons.getIconDataFromIconName("mdi:web"),
                ),
                title: Translate.getString("settings.language", context),
              ),
              LocalLanguagePicker(),
              SliverHeaderNormal(
                icon: Icon(
                  MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:account-circle"),
                ),
                title: Translate.getString("settings.about", context),
              ),
              Container(
                child: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color:
                                  ThemeInfo.colorBottomSheet.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            Translate.getString("settings.about_info", context),
                            style: Theme.of(context).textTheme.body1,
                            textAlign: TextAlign.justify,
                            textScaleFactor: gd.textScaleFactorFix,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(width: 10),
                            Expanded(
                              child: RaisedButton(
                                onPressed: _launchDiscord,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: Image(
                                        image: AssetImage(
                                            'assets/images/discord-512.png'),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Discord ",
                                      style: TextStyle(color: Colors.black),
                                      textScaleFactor: gd.textScaleFactorFix,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: RaisedButton(
                                onPressed: _launchFacebook,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: Image(
                                        image: AssetImage(
                                            'assets/images/facebook-logo.png'),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Facebook",
                                      style: TextStyle(color: Colors.black),
                                      textScaleFactor: gd.textScaleFactorFix,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color:
                                  ThemeInfo.colorBottomSheet.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
//                        "App Name: ${_packageInfo.appName} - "
//                      "Package: ${_packageInfo.packageName}\n"
                            "Version: ${_packageInfo.version} - "
                            "Build: ${_packageInfo.buildNumber}",
                            style: Theme.of(context).textTheme.body1,
                            textAlign: TextAlign.center,
                            textScaleFactor: gd.textScaleFactorFix,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverSafeArea(
                sliver: gd.emptySliver,
              )
            ],
          ),
        );
      },
    );
  }

  _launchDiscord() async {
    const url = 'https://discord.gg/cqYr52P';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchFacebook() async {
    const fbProtocolUrl = "fb://group/709634206223205";
    const fallbackUrl = 'https://www.facebook.com/groups/709634206223205/';
    try {
      bool launched = await launch(fbProtocolUrl, forceSafariVC: false);

      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false);
    }

//    const url = 'https://www.facebook.com/groups/709634206223205/';
//
//    if (await canLaunch(url)) {
//      await launch(url);
//    } else {
//      throw 'Could not launch $url';
//    }
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
//      log.d("_packageInfo $_packageInfo");
      _packageInfo = info;
    });
  }
}

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: 58,
      delegate: SliverChildListDelegate(
        [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      gd.baseSetting.themeIndex = 1;
                      gd.baseSettingSave(true);
                    },
                    child: Card(
                      elevation: 1,
                      color: Color.fromRGBO(28, 28, 28, 1).withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Image.asset("assets/images/icon_transparent.png"),
                            Expanded(
                              child: Text(
                                Translate.getString(
                                    "theme_selector.dark", context),
                                style: TextStyle(color: Colors.white),
                                textScaleFactor: gd.textScaleFactorFix,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.amber
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      gd.baseSetting.themeIndex = 0;
                      gd.baseSettingSave(true);
                    },
                    child: Card(
                      elevation: 1,
                      color: Color.fromRGBO(255, 255, 255, 1).withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Image.asset("assets/images/icon_transparent.png"),
                            Expanded(
                              child: Text(
                                Translate.getString(
                                    "theme_selector.light", context),
                                style: TextStyle(color: Colors.black),
                                textScaleFactor: gd.textScaleFactorFix,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.amber
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LayoutSelector extends StatefulWidget {
  @override
  _LayoutSelectorState createState() => _LayoutSelectorState();
}

class _LayoutSelectorState extends State<LayoutSelector> {
  final Map<int, Widget> phoneSegment = const <int, Widget>{
    2: Text('2'),
    3: Text('3'),
    4: Text('4'),
  };
  final Map<int, Widget> tabletSegment = const <int, Widget>{
    36: Text('3:6'),
    69: Text('6:9'),
    912: Text('9:12'),
    3: Text('3'),
    6: Text('6'),
    9: Text('9'),
    12: Text('12'),
  };
  int phoneValue;
  int tabletValue;

  @override
  Widget build(BuildContext context) {
    phoneValue = gd.baseSetting.phoneLayout;
    tabletValue = gd.baseSetting.tabletLayout;
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          CupertinoSlidingSegmentedControl<int>(
            thumbColor: ThemeInfo.colorBottomSheetReverse.withOpacity(0.5),
//          CupertinoSegmentedControl<int>(
            padding: EdgeInsets.all(12),
            children: gd.isTablet ? tabletSegment : phoneSegment,
            onValueChanged: (int val) {
              setState(() {
                if (gd.isTablet) {
                  tabletValue = val;
                  gd.baseSetting.tabletLayout = val;
                } else {
                  phoneValue = val;
                  gd.baseSetting.phoneLayout = val;
                }
                gd.baseSettingSave(true);
              });
            },
            groupValue: gd.isTablet ? tabletValue : phoneValue,
          ),
        ],
      ),
    );
  }
}

class ShapeSelector extends StatefulWidget {
  @override
  _ShapeSelectorState createState() => _ShapeSelectorState();
}

class _ShapeSelectorState extends State<ShapeSelector> {
  @override
  Widget build(BuildContext context) {
    Widget widget0 = Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: gd.baseSetting.shapeLayout == 0
                ? ThemeInfo.colorIconActive
                : ThemeInfo.colorIconInActive,
            borderRadius: BorderRadius.circular(4),
          ),
          width: 30,
          height: 30,
        )
      ],
    );
    Widget widget1 = Column(
      children: <Widget>[
        Material(
          color: gd.baseSetting.shapeLayout == 1
              ? ThemeInfo.colorIconActive
              : ThemeInfo.colorIconInActive,
          shape: SquircleBorder(superRadius: 5),
          child: Container(
            alignment: Alignment.center,
            width: 30,
            height: 30,
          ),
        ),
      ],
    );
    Widget widget2 = Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: gd.baseSetting.shapeLayout == 2
                ? ThemeInfo.colorIconActive
                : ThemeInfo.colorIconInActive,
            borderRadius: BorderRadius.circular(4),
          ),
          width: 48,
          height: 30,
        ),
      ],
    );

    final Map<int, Widget> phoneSegment = <int, Widget>{
      0: widget0,
      1: widget1,
      2: widget2,
    };
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          CupertinoSegmentedControl<int>(
            borderColor: Colors.transparent,
            selectedColor: Colors.transparent,
            unselectedColor: Colors.transparent,
            pressedColor: Colors.transparent,
            padding: EdgeInsets.all(12),
            children: phoneSegment,
            onValueChanged: (int val) {
              setState(() {
                gd.baseSetting.shapeLayout = val;
                gd.baseSettingSave(true);
              });
            },
            groupValue: gd.baseSetting.shapeLayout,
          ),
        ],
      ),
    );
  }
}
