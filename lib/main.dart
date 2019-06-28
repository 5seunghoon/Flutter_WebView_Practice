import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'main/main_view.dart';
import 'tablist/tablist_view.dart';

void main() => runApp(WebViewPracticeApp());

final routes = {"/tablist": (BuildContext context) => TabListWidget()};

class WebViewPracticeApp extends StatelessWidget {

  static const platform = const MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
    print("battery level : $batteryLevel");
  }

  @override
  Widget build(BuildContext context) {
    _getBatteryLevel();

    return MaterialApp(
      title: 'Flutter WebView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainWebViewScaffoldWidget(),
      //home: Text(""),
      routes: routes,
    );
  }
}
