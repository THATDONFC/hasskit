//import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:hasskit/helper/general_data.dart';
//import 'package:rxdart/rxdart.dart';
//
//final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//    FlutterLocalNotificationsPlugin();
//
//// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
//final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
//    BehaviorSubject<ReceivedNotification>();
//
//final BehaviorSubject<String> selectNotificationSubject =
//    BehaviorSubject<String>();
//
//class ReceivedNotification {
//  final int id;
//  final String title;
//  final String body;
//  final String payload;
//
//  ReceivedNotification(
//      {@required this.id,
//      @required this.title,
//      @required this.body,
//      @required this.payload});
//}
//
//class LocalNotification {
//  static Future<void> showNotification(
//      String title, String body, String payload) async {
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        'your channel id', 'your channel name', 'your channel description',
//        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
//    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//    var platformChannelSpecifics = NotificationDetails(
//        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//
//    var uniqueNumber = gd.entities.keys.toList().indexOf(payload);
//    if (uniqueNumber == null) uniqueNumber = 0;
//    await flutterLocalNotificationsPlugin.show(
//        uniqueNumber, title, body, platformChannelSpecifics,
//        payload: payload);
//    print(
//        "showNotification uniqueNumber $uniqueNumber title $title body $body payload $payload");
//  }
//
//  static Future<void> showNotificationWithNoBody(
//      String title, String payload) async {
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        'your channel id', 'your channel name', 'your channel description',
//        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
//    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//    var platformChannelSpecifics = NotificationDetails(
//        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//    var uniqueNumber = gd.entities.keys.toList().indexOf(payload);
//    if (uniqueNumber == null) uniqueNumber = 0;
//    await flutterLocalNotificationsPlugin.show(
//        uniqueNumber, title, null, platformChannelSpecifics,
//        payload: payload);
//
//    print("uniqueNumber $uniqueNumber title $title payload $payload\n ");
//  }
//
//  static Future<void> cancelNotification() async {
//    await flutterLocalNotificationsPlugin.cancel(0);
//  }
//}
