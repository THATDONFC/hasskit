import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/hasskit_review.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/google_sign.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/squircle_border.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:hasskit/model/local_language.dart';
import 'package:hasskit/model/login_data.dart';
import 'package:hasskit/view/setting_control/backup_restore.dart';
import 'package:hasskit/view/setting_control/setting_mobile_app.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';
import 'setting_control/setting_lock.dart';
import 'home_assistant_login.dart';
import 'setting_control/server_select_panel.dart';
import 'slivers/sliver_header.dart';

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
          "${generalData.locationUpdateFail} | "
          "${generalData.locationUpdateSuccess} | "
          "${generalData.loginDataCurrent.url} | "
          "${generalData.settingMobileApp.deviceName} | "
          "${generalData.settingMobileApp.trackLocation} | "
          "${generalData.settingMobileApp.webHookId} | "
          "${generalData.mobileAppState} | "
          "${generalData.currentTheme} | "
          "${generalData.webSocketConnectionStatus} | "
          "${generalData.deviceSetting.settingLocked} | "
          "${generalData.deviceSetting.phoneLayout} | "
          "${generalData.deviceSetting.tabletLayout} | "
          "${generalData.deviceSetting.shapeLayout} | "
          "${generalData.loginDataList.length} | "),
      builder: (_, string, __) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(gd.deviceSetting.themeIndex == 1
                  ? gd.backgroundImage[10]
                  : gd.backgroundImage[9]),
              fit: BoxFit.cover,
            ),
//            gradient: LinearGradient(
//                begin: Alignment.topCenter,
//                end: Alignment.bottomCenter,
//                colors: [
//                  gd.deviceSetting.themeIndex != 1 ? Colors.white : Colors.grey,
//                  gd.deviceSetting.themeIndex != 1
//                      ? Colors.grey
//                      : ThemeInfo.colorBackgroundDark,
//                ]),
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
              SliverFixedExtentList(
                itemExtent: 10,
                delegate: SliverChildListDelegate(
                  [Container()],
                ),
              ),
              gd.deviceSetting.settingLocked
                  ? gd.emptySliver
                  : SliverHeaderNormal(
                      icon: Icon(
                        MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:home-assistant"),
                      ),
                      title: Translate.getString(
                          "settings.home_assistant", context),
                    ),
              gd.deviceSetting.settingLocked
                  ? gd.emptySliver
                  : SliverList(
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
                                    prefixText:
                                        gd.useSSL ? "https://" : "http://",
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
                                    Expanded(
                                      child: Text(
                                        Translate.getString(
                                            "settings.use_https", context),
                                        textScaleFactor: gd.textScaleFactorFix,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    RaisedButton(
                                      onPressed: showConnect
                                          ? () {
                                              if (keyboardVisible) {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        new FocusNode());
                                              }

                                              _controller.text =
                                                  _controller.text.trim();
                                              _controller.text = _controller
                                                  .text
                                                  .toLowerCase();
                                              _controller.text = _controller
                                                  .text
                                                  .replaceAll("https://", "");
                                              _controller.text = _controller
                                                  .text
                                                  .replaceAll("http://", "");
                                              if (_controller.text
                                                  .contains("/"))
                                                _controller.text = _controller
                                                    .text
                                                    .split("/")[0];

                                              gd.loginDataCurrent = LoginData(
                                                  url: gd.useSSL
                                                      ? "https://" +
                                                          _controller.text
                                                      : "http://" +
                                                          _controller.text);
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
                                                          .loginDataCurrent
                                                          .getUrl +
                                                      '/auth/authorize?client_id=' +
                                                      gd.loginDataCurrent
                                                          .getUrl +
                                                      "/hasskit"
                                                          '&redirect_uri=' +
                                                      gd.loginDataCurrent
                                                          .getUrl +
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
              gd.deviceSetting.settingLocked
                  ? gd.emptySliver
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ServerSelectPanel(gd.loginDataList[index]),
                        childCount: gd.loginDataList.length,
                      ),
                    ),
              gd.deviceSetting.settingLocked ||
                      gd.currentUrl.contains("hasskit.duckdns.org")
                  ? gd.emptySliver
                  : SliverHeaderNormal(
                      icon: Icon(
                        MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:devices"),
                      ),
                      title: "Mobile App",
                    ),
              gd.deviceSetting.settingLocked ||
                      gd.currentUrl.contains("http://hasskit.duckdns.org")
                  ? gd.emptySliver
                  : SettingMobileAppRegistration(),
              gd.deviceSetting.settingLocked
                  ? gd.emptySliver
                  : SliverHeaderNormal(
                      icon: Icon(
                        MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:cloud-sync"),
                      ),
                      title: Translate.getString("settings.sync", context),
                    ),
              gd.deviceSetting.settingLocked ? gd.emptySliver : GoogleSign(),
              gd.deviceSetting.settingLocked
                  ? gd.emptySliver
                  : SliverHeaderNormal(
                      icon: Icon(
                        MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:backup-restore"),
                      ),
                      title: "Backup & Restore",
                    ),
              gd.deviceSetting.settingLocked ? gd.emptySliver : BackupRestore(),
              SettingLock(),
              SliverHeaderNormal(
                icon: Icon(
                  MaterialDesignIcons.getIconDataFromIconName("mdi:palette"),
                ),
                title: Translate.getString("settings.theme_color", context),
              ),
              ThemeSelector(),
              SliverHeaderNormal(
                icon: Icon(
                  MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:view-dashboard-variant"),
                ),
                title: Translate.getString("settings.layout", context),
              ),
              ShapeSelector(),
              LayoutSelector(),
              SliverHeaderNormal(
                icon: Icon(
                  MaterialDesignIcons.getIconDataFromIconName("mdi:web"),
                ),
                title: Translate.getString("settings.language", context),
              ),
              LocalLanguagePicker(),
//              SliverHeaderNormal(
//                icon: Icon(
//                  MaterialDesignIcons.getIconDataFromIconName("mdi:bell-ring"),
//                ),
//                title: "Notification Token",
//              ),
//              NotificationGuide(),

              SliverHeaderNormal(
                icon: Icon(
                  MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:account-circle"),
                ),
                title: Translate.getString("settings.about", context),
              ),
              HassKitReview(),
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
                            SizedBox(width: 8),
                            Expanded(
                              child: RaisedButton(
                                elevation: 1,
                                onPressed: _launchDiscord,
                                child: Text(
                                  "Discord ",
                                  textScaleFactor: gd.textScaleFactorFix,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: RaisedButton(
                                elevation: 1,
                                onPressed: _launchFacebook,
                                child: Text(
                                  "Facebook",
                                  textScaleFactor: gd.textScaleFactorFix,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: RaisedButton(
                                elevation: 1,
                                onPressed: _launchGitHub,
                                child: Text(
                                  "Github",
                                  textScaleFactor: gd.textScaleFactorFix,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
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
                            "Build: ${_packageInfo.buildNumber}\n"
                            "${gd.configLocationName} - "
                            "Version: ${gd.configVersion}"
//                            "temperature: ${gd.configUnitSystem['temperature']}"
                            "",
                            maxLines: 4,
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

  _launchGitHub() async {
    const url = 'https://github.com/tuanha2000vn/hasskit';
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
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
//      log.d("_packageInfo $_packageInfo");
      _packageInfo = info;
    });
  }
}

class ThemeSelector extends StatefulWidget {
  @override
  _ThemeSelectorState createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  @override
  Widget build(BuildContext context) {
    Widget dark = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:brightness-4")),
        SizedBox(
          width: 4,
          height: 32,
        ),
        Text(
          Translate.getString("theme_selector.dark", context),
          textScaleFactor: gd.textScaleFactorFix,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        )
      ],
    );
    Widget light = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:brightness-5")),
        SizedBox(
          width: 4,
          height: 32,
        ),
        Text(
          Translate.getString("theme_selector.light", context),
          textScaleFactor: gd.textScaleFactorFix,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        )
      ],
    );
    final Map<int, Widget> childrenSegment = <int, Widget>{
      1: dark,
      0: light,
    };
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: CupertinoSlidingSegmentedControl<int>(
              thumbColor: ThemeInfo.colorIconActive,
              backgroundColor: Colors.transparent,
              children: childrenSegment,
              onValueChanged: (int val) {
                setState(() {
                  gd.deviceSetting.themeIndex = val;
                  gd.deviceSettingSave();
                });
              },
              groupValue: gd.deviceSetting.themeIndex,
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
    phoneValue = gd.deviceSetting.phoneLayout;
    tabletValue = gd.deviceSetting.tabletLayout;
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: CupertinoSlidingSegmentedControl<int>(
              thumbColor: ThemeInfo.colorIconActive,
              backgroundColor: Colors.transparent,
//          CupertinoSegmentedControl<int>(
              children: gd.isTablet ? tabletSegment : phoneSegment,
              onValueChanged: (int val) {
                setState(() {
                  if (gd.isTablet) {
                    tabletValue = val;
                    gd.deviceSetting.tabletLayout = val;
                  } else {
                    phoneValue = val;
                    gd.deviceSetting.phoneLayout = val;
                  }
                  gd.deviceSettingSave();
                });
              },
              groupValue: gd.isTablet ? tabletValue : phoneValue,
            ),
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
    Widget widget0 = Container(
      padding: EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gd.deviceSetting.shapeLayout == 0
            ? Colors.white.withOpacity(0.5)
            : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      width: 30,
      height: 30,
    );
    Widget widget1 = Container(
      padding: EdgeInsets.all(4),
      child: Material(
        color: gd.deviceSetting.shapeLayout == 1
            ? Colors.white.withOpacity(0.5)
            : Colors.grey.withOpacity(0.5),
        shape: SquircleBorder(superRadius: 5),
        child: Container(
          alignment: Alignment.center,
          width: 30,
          height: 30,
        ),
      ),
    );
    Widget widget2 = Container(
      padding: EdgeInsets.all(4),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gd.deviceSetting.shapeLayout == 2
              ? Colors.white.withOpacity(0.5)
              : Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        width: 48,
        height: 30,
      ),
    );

    final Map<int, Widget> phoneSegment = <int, Widget>{
      0: widget0,
      1: widget1,
      2: widget2,
    };
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: CupertinoSlidingSegmentedControl<int>(
              thumbColor: ThemeInfo.colorIconActive,
              backgroundColor: Colors.transparent,
              children: phoneSegment,
              onValueChanged: (int val) {
                setState(() {
                  gd.deviceSetting.shapeLayout = val;
                  gd.deviceSettingSave();
                });
              },
              groupValue: gd.deviceSetting.shapeLayout,
            ),
          ),
        ],
      ),
    );
  }
}
