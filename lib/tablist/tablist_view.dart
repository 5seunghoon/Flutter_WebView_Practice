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
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, i) {
                  WebTab webTab = _tabListBloc.getTabList()[i];
                  return _tabTile(webTab);
                },
                itemCount: _tabListBloc.getTabList().length,
              ),
            ),
            _addTabButtonTile()
          ],
        ),
      ),
      onWillPop: () {
        widget._flutterWebViewPlugin.show();
        return Future(() => true);
      },
    );
  }

  Widget _tabTile(WebTab webTab) {
    return Card(
      child: ListTile(
        title: Text("url : ${webTab.url}, id : ${webTab.id}"),
        trailing: IconButton(
          icon: Icon(
            Icons.remove,
            color: Colors.green,
          ),
          onPressed: () {
            setState(() {
              widget._tabListBloc.removeTab(webTab.id);
            });
          },
        ),
        onTap: () {
          widget._flutterWebViewPlugin.reloadUrl(webTab.url);
          widget._flutterWebViewPlugin.show();
          nowTabId = webTab.id;
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _addTabButtonTile() {
    return ListTile(
      title: IconButton(
        icon: Icon(
          Icons.add,
          color: Colors.green,
        ),
      ),
      onTap: () {
        var newTab = widget._tabListBloc.addNewTab();
        widget._flutterWebViewPlugin.reloadUrl(newTab.url);
        widget._flutterWebViewPlugin.show();
        nowTabId = newTab.id;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
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
