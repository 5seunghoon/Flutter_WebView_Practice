import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'main/main_view.dart';
import 'tablist/tablist_view.dart';

void main() => runApp(WebViewPracticeApp());

final routes = {"/tablist": (BuildContext context) => TabListWidget()};

class WebViewPracticeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainWebViewScaffoldWidget(),
      routes: routes,
    );
  }
}
