import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/material_design_icons.dart';
import 'general_data.dart';
import 'theme_info.dart';
import 'package:hasskit/helper/locale_helper.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
//    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class GoogleSign extends StatefulWidget {
  @override
  _GoogleSignState createState() => _GoogleSignState();
}

class _GoogleSignState extends State<GoogleSign> {
  @override
  void initState() {
    super.initState();
//    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
//      setState(() {
//        gd.firebaseCurrentUser = account;
//      });
//    });
//    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: <Widget>[
                  gd.googleSignInAccount != null
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(gd.googleSignInAccount.photoUrl),
                          backgroundColor: Colors.transparent,
                          radius: 44,
                        )
                      : CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/images/google_cloud.png"),
                          backgroundColor: Colors.transparent,
                          radius: 44,
                        ),
                  gd.googleSignInAccount != null
                      ? Text(gd.googleSignInAccount.displayName ?? '')
                      : Text(Translate.getString("google_sync.use", context)),
//                  Text(_currentUser.email ?? ''),
//                  Text('Using Cloud Sync Data'),
                  gd.googleSignInAccount != null
                      ? GoogleLoggedIn()
                      : GoogleLoggedOut(),
                  gd.googleSignInAccount != null
                      ? GoogleCloudAction()
                      : Container(),
                  Text(
                    Translate.getString("google_sync.info", context),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Row(
            children: <Widget>[
              Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:logout")),
              SizedBox(width: 4),
              Text(Translate.getString("google_sync.sign_out", context)),
            ],
          ),
          onPressed: _handleSignOut,
        ),
      ],
    );
  }

  Future<void> _handleSignOut() async {
    googleSignIn.disconnect();
  }
}

class GoogleCloudAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () {
            Flushbar flush;
            flush = Flushbar<bool>(
              title: Translate.getString("google_sync.force_download", context),
              message: Translate.getString("google_sync.sync_problem", context),
              duration: Duration(seconds: 3),
              shouldIconPulse: true,
              icon: Icon(
                Icons.warning,
                color: ThemeInfo.colorIconActive,
              ),
              mainButton: FlatButton(
                onPressed: () {
                  gd.downloadCloudData();
                  flush.dismiss(true);
                },
                child: Text(
                  Translate.getString("global.ok", context),
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            )..show(context);
          },
          child: Icon(
            MaterialDesignIcons.getIconDataFromIconName("mdi:cloud-download"),
            color: ThemeInfo.colorIconActive.withOpacity(0.5),
          ),
        ),
        SizedBox(width: 12),
        InkWell(
          onTap: () {
            Flushbar flush;
            flush = Flushbar<bool>(
              title: Translate.getString("google_sync.force_upload", context),
              message: Translate.getString("google_sync.sync_problem", context),
              duration: Duration(seconds: 3),
              shouldIconPulse: true,
              icon: Icon(
                Icons.warning,
                color: ThemeInfo.colorIconActive,
              ),
              mainButton: FlatButton(
                onPressed: () {
                  gd.uploadCloudData();
                  flush.dismiss(true);
                },
                child: Text(
                  Translate.getString("global.ok", context),
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            )..show(context);
          },
          child: Icon(
            MaterialDesignIcons.getIconDataFromIconName("mdi:cloud-upload"),
            color: ThemeInfo.colorIconActive.withOpacity(0.5),
          ),
        ),
        SizedBox(width: 12),
        InkWell(
          onTap: () {
            Flushbar flush;
            flush = Flushbar<bool>(
              title: Translate.getString("google_sync.force_reset", context),
              message: Translate.getString("google_sync.sync_problem", context),
              duration: Duration(seconds: 3),
              shouldIconPulse: true,
              icon: Icon(
                Icons.warning,
                color: ThemeInfo.colorIconActive,
              ),
              mainButton: FlatButton(
                onPressed: () {
                  gd.deleteCloudData();
                  flush.dismiss(true);
                },
                child: Text(
                  Translate.getString("global.ok", context),
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            )..show(context);
          },
          child: Icon(
            MaterialDesignIcons.getIconDataFromIconName("mdi:cloud-alert"),
            color: ThemeInfo.colorIconActive.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class GoogleLoggedOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: _handleSignIn,
          child: Row(
            children: <Widget>[
              Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:login")),
              SizedBox(width: 4),
              Text(Translate.getString("google_sync.sign_in", context)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignIn() async {
    try {
      log.d("googleSignIn.signIn()");
      await googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }
}
