import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/theme_info.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String subject = "HassKit Notification Setup";
    String shareContent =
        "Setup notify_hasskit then add the following line to .homeassistant/configuration.yaml"
        "\n\nnotify_hasskit:"
        "\n  token:"
        "\n    - \"${gd.firebaseMessagingToken}\""
        "\n\nFor more information, please visite our detail guide:"
        "\nhttps://github.com/tuanha2000vn/hasskit/blob/master/notify_hasskit.md";

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: <Widget>[
                SelectableText(
                  "${gd.firebaseMessagingToken}",
                  toolbarOptions: ToolbarOptions(
                    copy: true,
                    selectAll: true,
                    cut: false,
                    paste: false,
                  ),
                  onTap: () {
                    Share.share(shareContent, subject: subject);
                  },
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    onPressed: () {
                      Share.share(shareContent, subject: subject);
                    },
                    child: Text(
                      "Share",
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: RaisedButton(
                    elevation: 1,
                    onPressed: _launchNotificationGuide,
                    child: Text(
                      "Guide",
                      textScaleFactor: gd.textScaleFactorFix,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _launchNotificationGuide() async {
    const url =
        'https://github.com/tuanha2000vn/hasskit/blob/master/notify_hasskit.md';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
