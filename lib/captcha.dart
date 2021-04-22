import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Captcha extends StatefulWidget {
  Function callback;
  Captcha(this.callback);

  @override
  State<StatefulWidget> createState() {
    return CaptchaState();
  }
}

class CaptchaState extends State<Captcha> {
  WebViewController webViewController;
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: WebView(
      initialUrl: "https://WorkForce.com/captcha.html",
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: Set.from([
        JavascriptChannel(
            name: 'Captcha',
            onMessageReceived: (JavascriptMessage message) {
              //This is where you receive message from
              //javascript code and handle in Flutter/Dart
              //like here, the message is just being printed
              //in Run/LogCat window of android studio
              //print(message.message);
              widget.callback(message.message);
              Navigator.of(context).pop();
            })
      ]),
      onWebViewCreated: (WebViewController w) {
        webViewController = w;
      },
    ));
  }
}
