import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../webview/webview_base.dart';
import '../util/empty_app_bar.dart';
import '../model/webtab.dart';
import 'tablist_bloc.dart';

class TabListState extends State<TabListWidget> {

  var previewContainer = new GlobalKey();
  TabListBloc _tabListBloc = TabListBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print("dispose");
    widget._tabListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    imageCache.clear(); // 중요. 캐시를 안지우면 이전에 캡쳐한 탭 이미지가 계속 뜸

    // 탭 리스트를 DB에서 읽은 뒤 setState
    if (!_tabListBloc.isReadAllDb) {
      _tabListBloc.getAllWebTabInDb(this).then((_) {
        _tabListBloc.isReadAllDb = true; // setState 로 인해 또 호출되는 것을 방지
        _tabListBloc.initBoxDecorationList();
        setState(() {
          _tabListBloc.startBoxDecorationAnimation(this);
        });
      });
    }

    return WillPopScope(
      child: Scaffold(
        backgroundColor: TabListBloc.baseColor,
        appBar: EmptyAppBar(),
        body: Column(
          children: <Widget>[
            _tabGridView(),
            Divider(),
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

  Widget _tabGridView() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(4.0),
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 0.6),
        itemCount: _tabListBloc.getTabList().length,
        itemBuilder: (context, i) {
          WebTab webTab = _tabListBloc.getTabList()[i];
          return _tabTile(i, webTab, context);
        },
      ),
    );
  }

  Widget _tabTile(int index, WebTab webTab, BuildContext context) {
    return AnimatedContainer(
      foregroundDecoration: _tabListBloc.getBoxDecoration(index),
      duration: Duration(milliseconds: TabListBloc.durationOfAnimationMilli),
      child: Card(
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: _tabInfoWidget(webTab),
              ),
              Center(
                child: _tabImageWidget(webTab),
              ),
              _removeTabButton(webTab),
            ],
          ),
          onTap: () => _onTabTap(context, webTab),
        ),
      ),
    );
  }

  Widget _removeTabButton (WebTab webTab){
    return Expanded(
      child: GestureDetector(
        child: Icon(
          Icons.delete_forever,
          size: 18,
          color: Colors.green,
        ),
        onTap: () {
          setState(() {
            widget._tabListBloc.removeTab(webTab.id);
          });
        },
      ),
    );
  }

  void _onTabTap(BuildContext context, WebTab webTab) {
    widget._flutterWebViewPlugin.reloadUrl(webTab.url);
    widget._flutterWebViewPlugin.show();
    nowTabId = webTab.id;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Widget _tabInfoWidget(WebTab webTab) {
    const int _urlMaxLength = 25;
    final _urlLength = webTab.url.length > _urlMaxLength ? _urlMaxLength : webTab.url.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        /*
        // Tab id
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: Text(
            "${webTab.id}",
            style: TextStyle(fontSize: 12),
          ),
        ),
        */
        Text(
          "${webTab.url.substring(8, _urlLength)}",
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _tabImageWidget(WebTab webTab) {
    final tabImageFilePath = widget._tabListBloc.getTabImageFilePath(webTab.id);
    if (tabImageFilePath == null) {
      _loadTabImage(webTab);
      return Image.asset("assets/notfound.png");
    } else {
      print("image path : $tabImageFilePath");
      return Image.file(File(tabImageFilePath), fit: BoxFit.fitWidth,);
    }
  }

  void _loadTabImage(WebTab webTab) {
    getApplicationDocumentsDirectory().then((var dir) {
      setState(() {
        final tabImageFilePath =
            dir.path + "/screenshot" + webTab.getTabIdToThreeWords + ".jpg";
        print("app doc dir : $tabImageFilePath");
        widget._tabListBloc.setTabImageFilePath(webTab.id, tabImageFilePath);
      });
    });
  }

  Widget _addTabButtonTile() {
    return ListTile(
      title: Icon(
        Icons.add,
        color: Colors.white,
      ),
      onTap: () {
        var newTab = widget._tabListBloc.addNewTab();
        WebTab.insertWebTab(newTab);
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
