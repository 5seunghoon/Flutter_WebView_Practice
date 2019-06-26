import 'dart:async';

import '../model/webtab.dart';

class TabListBloc {
  static final TabListBloc _instance = TabListBloc._internal();

  List<WebTab> _tabList = [];

  factory TabListBloc() {
    return _instance;
  }

  TabListBloc._internal();

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
    return WebTab(99, "");
  }

  List<WebTab> getTabList() {
    return _tabList;
  }

  void dispose() {}
}
