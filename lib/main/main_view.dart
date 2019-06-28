import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../webview/webview_scaffold.dart';
import '../webview/webview_base.dart';
import '../util/empty_app_bar.dart';
import 'main_bloc.dart';
import '../tablist/tablist_bloc.dart';
import '../model/webtab.dart';

class MainWebViewScaffoldState extends State<MainWebViewScaffoldWidget> {
  @override
  void dispose() {
    widget._mainWebViewBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: homeUrl,
      appBar: EmptyAppBar(),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      bottomNavigationBar: _bottomAppbar(),
    );
  }

  Widget _bottomAppbar() {
    return BottomAppBar(
      child: IconTheme(
        data: IconThemeData(color: Colors.green),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
              onPressed: () {
                widget._flutterWebViewPlugin.goBack();
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                widget._flutterWebViewPlugin.goForward();
              },
            ),
            IconButton(
              icon: const Icon(Icons.autorenew),
              onPressed: () {
                widget._flutterWebViewPlugin.reload();
              },
            ),
            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () {
                print("nowTabId : $nowTabId");
                widget._flutterWebViewPlugin.capture(tabId: nowTabId);

                widget._flutterWebViewPlugin.hide();
                WebTab.insertWebTab(WebTab(
                  id: nowTabId,
                  url: widget._mainWebViewBloc.getUrl(),
                )).then((_) => Navigator.of(context).pushNamed("/tablist"));
                //TabListBloc().addExistTab(WebTab(id: nowTabId, url: widget._mainWebViewBloc.getUrl()));
                //Navigator.of(context).pushNamed("/tablist");
              },
            ),
            IconButton(
              icon: const Icon(Icons.mobile_screen_share),
              onPressed: () {
                print("nowTabId : $nowTabId");
                widget._flutterWebViewPlugin.capture(tabId: nowTabId);
              },
            )
          ],
        ),
      ),
    );
  }
}

class MainWebViewScaffoldWidget extends StatefulWidget {
  final _flutterWebViewPlugin = FlutterWebviewPlugin();
  final MainWebViewBloc _mainWebViewBloc = MainWebViewBloc();

  @override
  State<StatefulWidget> createState() => MainWebViewScaffoldState();
}
