import 'package:flutter/material.dart';

import '../webview/webview_base.dart';
import '../util/empty_app_bar.dart';
import '../model/webtab.dart';
import 'tablist_bloc.dart';

class TabListState extends State<TabListWidget> {
  TabListBloc _tabListBloc = TabListBloc();

  @override
  void dispose() {
    widget._tabListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: EmptyAppBar(),
        body: Center(
            child: ListView.builder(
          itemBuilder: (context, i) {
            WebTab webTab = _tabListBloc.getTabList()[i];
            return ListTile(
              title: Text("url : ${webTab.url}, id : ${webTab.id}"),
            );
          },
          itemCount: _tabListBloc.getTabList().length,
        )),
      ),
      onWillPop: () {
        widget._flutterWebViewPlugin.show();
        return Future(() => true);
      },
    );
  }
}

class TabListWidget extends StatefulWidget {
  final _flutterWebViewPlugin = FlutterWebviewPlugin();
  final _tabListBloc = TabListBloc();

  @override
  State<StatefulWidget> createState() => TabListState();
}
