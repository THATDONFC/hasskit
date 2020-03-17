import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';
import 'theme_info.dart';

class HassKitReview extends StatefulWidget {
  @override
  _HassKitReviewState createState() => new _HassKitReviewState();
}

class _HassKitReviewState extends State<HassKitReview> {
  @override
  initState() {
    super.initState();
    AppReview.getAppID.then((onValue) {
      setState(() {
        appID = onValue;
      });
      print("App ID " + appID);
    });
  }

  String appID = "";
  String output = "";

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
//          new ListTile(
//            leading: new Icon(Icons.info),
//            title: new Text('App ID'),
//            subtitle: new Text(appID),
//            onTap: () {
//              AppReview.getAppID.then((onValue) {
//                setState(() {
//                  output = onValue;
//                });
//                print(onValue);
//              });
//            },
//          ),

          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: new Icon(
                    Icons.shop,
                  ),
                  title: new Text('View Store Page'),
                  onTap: () {
                    AppReview.storeListing.then((onValue) {
                      setState(() {
                        output = onValue;
                      });
                      print(onValue);
                    });
                  },
                ),
                Divider(),
                ListTile(
                  leading: new Icon(
                    Icons.star,
                  ),
                  title: new Text('Request Review'),
                  onTap: () {
                    AppReview.requestReview.then((onValue) {
                      setState(() {
                        output = onValue;
                      });
                      print(onValue);
                    });
                  },
                ),
                new Divider(),
                new ListTile(
                  leading: new Icon(
                    Icons.note_add,
                  ),
                  title: new Text('Write a New Review'),
                  onTap: () {
                    AppReview.writeReview.then((onValue) {
                      setState(() {
                        output = onValue;
                      });
                      print(onValue);
                    });
                  },
                ),
              ],
            ),
          ),
//          new ListTile(
//            title: new Text(output),
//          ),
        ],
      ),
    );
  }
}
