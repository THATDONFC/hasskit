import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';

class EntityControlCameraWebView extends StatefulWidget {
  final String entityId;

  const EntityControlCameraWebView({@required this.entityId});

  @override
  _EntityControlCameraWebViewState createState() =>
      _EntityControlCameraWebViewState();
}

class _EntityControlCameraWebViewState
    extends State<EntityControlCameraWebView> {
  InAppWebViewController webController;
  bool showSpin = true;
  String url = "";
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log.d("build showSpin $showSpin url $url");
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          generalData.cameraStreamUrl + url + showSpin.toString(),
      builder: (context, data, child) {
        log.d("Selector showSpin $showSpin url $url");
        return RotatedBox(
          quarterTurns: 0,
//              Theme.of(context).platform == TargetPlatform.android ? 1 : 0,
          child: Stack(
            children: <Widget>[
              Container(
                color: ThemeInfo.colorBackgroundDark,
                child: gd.cameraStreamUrl.length < 10
                    ? Container()
                    : InAppWebView(
                        initialUrl: gd.cameraStreamUrl,
                        initialHeaders: {},
                        initialOptions: InAppWebViewWidgetOptions(
                            inAppWebViewOptions: InAppWebViewOptions(
                          debuggingEnabled: true,
                        )),
                        onWebViewCreated: (InAppWebViewController controller) {
                          webController = controller;
                        },
                        onLoadStart:
                            (InAppWebViewController controller, String urlVal) {
                          setState(() {
                            log.d("onLoadStart urlVal $urlVal");
//              this.url = url;
                          });
                        },
                        onLoadStop: (InAppWebViewController controller,
                            String urlVal) async {
                          setState(() {
                            log.d("onLoadStop url $urlVal");
                            url = urlVal;
                            showSpin = false;
//              showSpin = false;
//              this.url = url;
                          });
                        },
                        onProgressChanged:
                            (InAppWebViewController controller, int progress) {
                          setState(() {
                            if (progress >= 100) showSpin = false;
//                            log.d("onProgressChanged progress $progress");
                          });
                        },
                      ),
              ),
              showSpin
                  ? Container(
                      color: ThemeInfo.colorBackgroundDark.withOpacity(1),
                      child: SpinKitThreeBounce(
                        size: 40,
                        color: ThemeInfo.colorIconActive.withOpacity(0.5),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }

  void delayedHide() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    showSpin = false;
    setState(() {});
  }
}
