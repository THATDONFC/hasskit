import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/locale_helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EntityControlCameraVideoPlayer extends StatefulWidget {
  final String entityId;

  const EntityControlCameraVideoPlayer({@required this.entityId});

  @override
  _EntityControlCameraVideoPlayerState createState() =>
      _EntityControlCameraVideoPlayerState();
}

class _EntityControlCameraVideoPlayerState
    extends State<EntityControlCameraVideoPlayer> {
  VideoPlayerController _controller;

  WebViewController webController;
  bool showSpin = true;

  bool initialized = false;
  String streamUrl = "";
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);

//    while (gd.cameraStreamUrl == "") {
//      log.d("WAIT gd.cameraStreamUrl==");
//    }
//
//    log.d("GO gd.cameraStreamUrl==${gd.cameraStreamUrl}");
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) => generalData.cameraStreamUrl,
      builder: (context, data, child) {
        var entity = gd.entities[widget.entityId];
        if (gd.cameraStreamUrl.length > 100 &&
            !initialized &&
            streamUrl != gd.cameraStreamUrl) {
          initVideo(gd.cameraStreamUrl);
        }

        try {
          if (gd.cameraStreamUrl != null && gd.cameraStreamUrl.length > 100) {
            return RotatedBox(
              quarterTurns: gd.isTablet ? 0 : 1,
              child: ModalProgressHUD(
                inAsyncCall: !_controller.value.initialized,
                opacity: 1,
                progressIndicator: SpinKitThreeBounce(
                  size: 40,
                  color: ThemeInfo.colorIconActive.withOpacity(0.5),
                ),
                color: ThemeInfo.colorBackgroundDark,
                child: Container(
                  color: ThemeInfo.colorBackgroundDark,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return RotatedBox(
              quarterTurns: gd.isTablet ? 0 : 1,
              child: ModalProgressHUD(
                inAsyncCall: false,
                opacity: 1,
                progressIndicator: SpinKitThreeBounce(
                  size: 40,
                  color: ThemeInfo.colorIconActive.withOpacity(0.5),
                ),
                color: ThemeInfo.colorBackgroundDark,
                child: Stack(
                  children: <Widget>[
                    Container(
                      color: ThemeInfo.colorBackgroundDark,
                      child: Center(
                        child: AspectRatio(
                            aspectRatio: 1.7,
                            child: WebView(
                              initialUrl: gd.currentUrl + entity.entityPicture,
                              gestureRecognizers: null,
                              javascriptMode: JavascriptMode.unrestricted,
                              initialMediaPlaybackPolicy:
                                  AutoMediaPlaybackPolicy.always_allow,
                              onWebViewCreated:
                                  (WebViewController webViewController) {
                                webController = webViewController;
                              },
                              onPageFinished: (String urlVal) async {
                                setState(() {
                                  showSpin = false;
                                });
                              },
                            )),
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
              ),
            );
          }
        } catch (e) {
          return Container(
            child: Center(
                child: AutoSizeText(
                    "$Translate.getString(\"global.error\", context): $e")),
          );
        }
      },
    );
  }

  void initVideo(String url) {
    initialized = true;
    streamUrl = url;
    _controller = VideoPlayerController.network(
//        'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4'
        streamUrl)
      ..initialize().then(
        (_) {
          log.w("initVideo $streamUrl");
          initialized = true;
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          _controller.play();
          setState(() {});
        },
      );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _controller.dispose();
  }
}
