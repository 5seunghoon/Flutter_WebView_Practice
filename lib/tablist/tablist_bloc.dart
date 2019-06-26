import 'dart:async';

class TabListBloc {
  static final TabListBloc _instance = TabListBloc._internal();

  List<String> _urlList = [];

  factory TabListBloc() {
    return _instance;
  }

  TabListBloc._internal();

  void addUrl(String url) {
    print("add url : $url");
    _urlList.add(url);
  }

  List<String> getUrlList() {
    return _urlList;
  }

  void dispose() {}
}
