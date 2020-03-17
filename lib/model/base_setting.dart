import 'package:flutter/material.dart';

const List<String> baseSettingDefaultColor = [
  "0xffEEEEEE",
  "0xffEF5350",
  "0xffFFCA28",
  "0xff66BB6A",
  "0xff42A5F5",
  "0xffAB47BC",
//  Color(0xffEEEEEE), //EEEEEE Gray
//  Color(0xffEF5350), //EF5350 Red
//  Color(0xffFFCA28), //FFCA28 Amber
//  Color(0xff66BB6A), //66BB6A Green
////    Color(0xff26C6DA), //26C6DA Cyan
//  Color(0xff42A5F5), //42A5F5 Blue
//  Color(0xffAB47BC), //AB47BC Purple
];

class BaseSetting {
  List<String> notificationDevices;
  List<String> colorPicker;
  String webView1Url = "https://embed.windy.com";
  String webView2Url = "https://www.yahoo.com/news/weather";
  String webView3Url = "https://livescore.com";

  BaseSetting({
    @required this.notificationDevices,
    @required this.colorPicker,
    this.webView1Url,
    this.webView2Url,
    this.webView3Url,
  });

  Map<String, dynamic> toJson() => {
        'notificationDevices': notificationDevices,
        'colorPicker': colorPicker,
        'webView1Url': webView1Url,
        'webView2Url': webView2Url,
        'webView3Url': webView3Url,
      };

  factory BaseSetting.fromJson(Map<String, dynamic> json) {
    return BaseSetting(
      notificationDevices: json['notificationDevices'] != null
          ? List<String>.from(json['notificationDevices'])
          : [],
      colorPicker: json['colorPicker'] != null
          ? List<String>.from(json['colorPicker'])
          : [
              "0xffEEEEEE",
              "0xffEF5350",
              "0xffFFCA28",
              "0xff66BB6A",
              "0xff42A5F5",
              "0xffAB47BC",
            ],
      webView1Url: json['webView1Url'] != null
          ? json['webView1Url']
          : "https://embed.windy.com",
      webView2Url: json['webView2Url'] != null
          ? json['webView2Url']
          : "https://www.yahoo.com/news/weather",
      webView3Url: json['webView3Url'] != null
          ? json['webView3Url']
          : "https://livescore.com",
    );
  }

  String getWebViewUrl(String webViewId) {
    print("getWebViewUrl $webViewId");
    switch (webViewId) {
      case "WebView1":
        return webView1Url;
      case "WebView2":
        return webView2Url;
      case "WebView3":
        return webView3Url;
      default:
        return webView1Url;
    }
  }
}
