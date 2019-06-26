import 'package:flutter/material.dart';

import '../webview/webview_scaffold.dart';
import '../webview/webview_base.dart';
import '../util/empty_app_bar.dart';
import 'main_bloc.dart';
import '../tablist/tablist_bloc.dart';

class MainWebViewScaffoldState extends State<MainWebViewScaffoldWidget> {
  @override
  void dispose() {
    widget._mainWebViewBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget._mainWebViewBloc.homeUrl,
      appBar: EmptyAppBar(),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
        color: Colors.white,
        child: const Center(
          child: Text('Waiting.....'),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
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
              icon : const Icon(Icons.content_copy),
              onPressed: () {
                widget._flutterWebViewPlugin.hide();
                TabListBloc().addUrl(widget._mainWebViewBloc.getUrl());
                Navigator.of(context).pushNamed("/tablist");
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
