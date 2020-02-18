import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'package:hasskit/helper/theme_info.dart';

class SliverWebView extends StatelessWidget {
  final List<String> webViews;
  const SliverWebView({@required this.webViews});
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gd.layoutCameraCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 8 / 5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return WebView(
              webViewsId: webViews[index],
            );
          },
          childCount: webViews.length,
        ),
      ),
    );
  }
}

class WebView extends StatefulWidget {
  final String webViewsId;

  const WebView({
    @required this.webViewsId,
  });

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final TextEditingController textController = TextEditingController();
  final Set<Factory> gestureRecognizers = [
    Factory(() => EagerGestureRecognizer()),
  ].toSet();

  InAppWebViewController webController;
  String currentUrl = "https://google.com";
  double opacity = 0.2;
  bool showSpin = true;
  bool showAddress = false;
  bool pinWebView;
  double width;

  @override
  void initState() {
    super.initState();
    currentUrl = gd.baseSetting.getWebViewUrl(widget.webViewsId);
    if (currentUrl == null) currentUrl = "https://embed.windy.com";
    textController.text = currentUrl;
    pinWebView = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
//      width: width,
//      height: ratio * width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: ThemeInfo.colorBackgroundDark.withOpacity(0.5),
              blurRadius: 1.0, // has the effect of softening the shadow
              spreadRadius: 1.0, // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                1.0, // vertical, move down 10
              ),
            ),
          ],
        ),
        padding: EdgeInsets.all(2),

//      child: ClipRRect(
//        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            buildInAppWebView(),
            showSpin
                ? Container(
                    decoration: BoxDecoration(
//                    borderRadius: BorderRadius.circular(12),
                      color: ThemeInfo.colorBackgroundDark.withOpacity(1),
                    ),
                    child: SpinKitThreeBounce(
                      size: 40,
                      color: ThemeInfo.colorIconActive.withOpacity(0.5),
                    ),
                  )
                : Container(),
            Column(
              children: <Widget>[
                Opacity(
                  opacity: showAddress ? 1 : opacity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: showAddress
                          ? ThemeInfo.colorBottomSheet
                          : Colors.transparent,
//                  borderRadius: BorderRadius.only(
//                    topLeft: Radius.circular(12),
//                    topRight: Radius.circular(12),
//                  ),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: <Widget>[
                        webButton(context),
                        reloadButton(context),
                        pintButton(context),
                        Spacer(),
                        presetButtons(),
                      ],
                    ),
                  ),
                ),
                addressAndAspect(),
              ],
            ),
          ],
        ),
//      ),
      ),
    );
  }

  //FUCK WebView/InAppWebView with parent ClipRRect will crash in iOS, take 1 day to figure out.
  Widget buildInAppWebView() {
//    print("buildInAppWebView currentUrl $currentUrl");
    return Container(
      child: InAppWebView(
        initialUrl: currentUrl,
        gestureRecognizers: !pinWebView ? gestureRecognizers : null,
        initialHeaders: {},
        initialOptions: InAppWebViewWidgetOptions(
            inAppWebViewOptions: InAppWebViewOptions(
          debuggingEnabled: true,
        )),
        onWebViewCreated: (InAppWebViewController controller) {
          print("onWebViewCreated currentUrl $currentUrl");
          webController = controller;
        },
        onLoadStart: (InAppWebViewController controller, String url) {
          setState(() {
            print("onLoadStart url $url");
            showSpin = true;
          });
        },
        onLoadStop: (InAppWebViewController controller, String url) async {
          setState(() {
            print("onLoadStop url $url");
            showSpin = false;
          });
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {
          setState(() {
            if (progress > 90) showSpin = false;
//            log.d("onProgressChanged progress $progress");
          });
        },
      ),
    );
  }

  Widget presetButtons() {
    return showAddress
        ? Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    textController.text = gd.webViewPresets[0];
                    changeUrl(textController.text);
                    showAddress = false;
                  });
                },
                child: Container(
                  child: Text(
                    Translate.getString("webview.windy", context),
                    textScaleFactor: gd.textScaleFactorFix,
                  ),
                ),
              ),
              Container(child: Text(" | ")),
              InkWell(
                onTap: () {
                  setState(() {
                    textController.text = gd.webViewPresets[1];
                    changeUrl(textController.text);
                    showAddress = false;
                  });
                },
                child: Container(
                  child: Text(
                    Translate.getString("webview.y_weather", context),
                    textScaleFactor: gd.textScaleFactorFix,
                  ),
                ),
              ),
              Container(child: Text(" | ")),
              InkWell(
                onTap: () {
                  setState(() {
                    textController.text = gd.webViewPresets[2];
                    changeUrl(textController.text);
                    showAddress = false;
                  });
                },
                child: Text(
                  Translate.getString("webview.live_score", context),
                  textScaleFactor: gd.textScaleFactorFix,
                ),
              ),
            ],
          )
        : Container();
  }

  changeUrl(String url) {
    log.d("changeUrl $url");
    setState(() {
      currentUrl = url;
      webController.loadUrl(url: currentUrl);
      showSpin = true;

      if (widget.webViewsId == "WebView1") {
        gd.baseSetting.webView1Url = url;
        gd.baseSettingSave(true);
      }
      if (widget.webViewsId == "WebView2") {
        gd.baseSetting.webView2Url = url;
        gd.baseSettingSave(true);
      }
      if (widget.webViewsId == "WebView3") {
        gd.baseSetting.webView3Url = url;
        gd.baseSettingSave(true);
      }
    });
  }

  Widget addressAndAspect() {
    return showAddress
        ? Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(1),
//                borderRadius: BorderRadius.only(
//                  bottomLeft: Radius.circular(12),
//                  bottomRight: Radius.circular(12),
//                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "https://www.siteadress.com",
                    ),
                    controller: textController,
                    autocorrect: false,
                    autovalidate: true,
                    autofocus: true,
                    maxLines: 3,
                    onChanged: (val) {
                      changeOpacity();
                    },
                    onEditingComplete: () {
                      changeUrl(textController.text);
                    },
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget webButton(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          changeOpacity();
          if (showAddress) changeUrl(textController.text.trim());
          showAddress = !showAddress;
          Fluttertoast.showToast(
              msg: showAddress
                  ? Translate.getString("webview.edit", context)
                  : Translate.getString("webview.saved", context),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
              textColor: Theme.of(context).textTheme.headline6.color,
              fontSize: 14.0);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
              offset: new Offset(0.0, 0.0),
              blurRadius: 1.0,
            )
          ],
        ),
        child: showAddress
            ? Icon(
                MaterialDesignIcons.getIconDataFromIconName("mdi:content-save"))
            : Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:pencil")),
      ),
    );
  }

  Widget reloadButton(BuildContext context) {
    return !showAddress
        ? InkWell(
            onTap: () {
              changeOpacity();
              webController.reload();

              Fluttertoast.showToast(
                  msg: Translate.getString("webview.reload", context),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
                  textColor: Theme.of(context).textTheme.headline6.color,
                  fontSize: 14.0);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                    offset: new Offset(0.0, 0.0),
                    blurRadius: 1.0,
                  )
                ],
              ),
              child: Icon(
                  MaterialDesignIcons.getIconDataFromIconName("mdi:refresh")),
            ),
          )
        : Container();
  }

  Widget pintButton(BuildContext context) {
    return !showAddress
        ? InkWell(
            onTap: () {
              setState(() {
                changeOpacity();
                pinWebView = !pinWebView;
                Fluttertoast.showToast(
                    msg: pinWebView
                        ? Translate.getString("webview.pin", context)
                        : Translate.getString("webview.unpin", context),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    backgroundColor: ThemeInfo.colorIconActive.withOpacity(1),
                    textColor: Theme.of(context).textTheme.headline6.color,
                    fontSize: 14.0);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                    offset: new Offset(0.0, 0.0),
                    blurRadius: 1.0,
                  )
                ],
              ),
              child: pinWebView
                  ? Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:pin"))
                  : Icon(MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:pin-off")),
            ),
          )
        : Container();
  }

  Timer _changeOpacityTimer;

  void changeOpacity() {
    opacity = 1;
    _changeOpacityTimer?.cancel();
    _changeOpacityTimer = null;
    _changeOpacityTimer = Timer(Duration(seconds: 10), () {
      setState(() {
        opacity = 0.2;
      });
    });
  }
}
