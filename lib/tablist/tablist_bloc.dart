import 'package:flutter/material.dart';

import '../webview/webview_base.dart';
import '../model/webtab.dart';

class TabListBloc {
  static final TabListBloc _instance = TabListBloc._internal();
  static int termOfAnimationMilli = 100;
  static int durationOfAnimationMilli = 200;

  final List<WebTab> _tabList = [];

  int get tabListLength => _tabList.length;
  bool isReadAllDb = false;
  bool isStartAnimation = false;

  final Map<int, String> _tabImageFilePathMap = {};

  List<BoxDecoration> _boxDecorationList = [];

  factory TabListBloc() {
    return _instance;
  }

  TabListBloc._internal();

  void tabImageFilePathMapClear() => _tabImageFilePathMap.clear();

  String getTabImageFilePath(int id) => _tabImageFilePathMap[id];

  void setTabImageFilePath(int id, String path) =>
      _tabImageFilePathMap[id] = path;

  void addExistTab(WebTab tab) {
    bool findSameTab = false;

    _tabList.forEach((var t) {
      if (t.id == tab.id) {
        t.url = tab.url;
        findSameTab = true;
        return;
      }
    });

    if (!findSameTab) _tabList.add(tab);
  }

  WebTab addNewTab() {
    var newId = _tabList.last.id + 1;
    var newUrl = homeUrl;
    var newTab = WebTab(id: newId, url: newUrl);
    _tabList.add(newTab);
    return newTab;
  }

  List<WebTab> getTabList() {
    return _tabList;
  }

  void dispose() {
    isStartAnimation = false;
    isReadAllDb = false;
    _tabList.clear();
    tabImageFilePathMapClear();
    boxDecorationListClear();
  }

  void removeTab(int id) {
    if (_tabList.length == 1) return;
    _tabList.removeWhere((var element) => element.id == id);
    WebTab.deleteWebTab(id);
  }

  Future<Null> getAllWebTabInDb() async {
    List<WebTab> webTabList = await WebTab.getAllWebTabs();
    webTabList.forEach((var webTab) => _tabList.add(webTab));
  }

  BoxDecoration getBoxDecoration(int index) => _boxDecorationList[index];

  void initBoxDecorationList() {
    print("init");
    _boxDecorationList = List.generate(
        _tabList.length, (i) => const BoxDecoration(color: Colors.white));
  }

  void startBoxDecorationAnimation(State state) {
    print("start animation");
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationBoxDecorationListDelayed(0, state);
    });
  }

  void _animationBoxDecorationListDelayed(int index, State state) {
    if (index >= _boxDecorationList.length) return;
    Future.delayed(Duration(milliseconds: termOfAnimationMilli), () {
      _boxDecorationList[index] = const BoxDecoration(color: Color(0x00FFFFFF));

      state.setState(() {});
      _animationBoxDecorationListDelayed(index + 1, state);
    });
  }

  void boxDecorationListClear() => _boxDecorationList.clear();
}
