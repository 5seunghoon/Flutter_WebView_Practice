import '../webview/webview_base.dart';
import '../model/webtab.dart';

class TabListBloc {
  static final TabListBloc _instance = TabListBloc._internal();

  List<WebTab> _tabList = [];

  int get tabListLength => _tabList.length;
  bool alreadyReadAllDb = false;

  Map<int, String> _tabImageFilePathMap = {};

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

  void dispose() {}

  void removeTab(int id) {
    if (_tabList.length == 1) return;
    _tabList.removeWhere((var element) => element.id == id);
    WebTab.deleteWebTab(id);
  }

  Future<Null> getAllWebTabInDb() async {
    List<WebTab> webtabs = await WebTab.getAllWebTabs();
    webtabs.forEach((var webtab) => _tabList.add(webtab));
  }
}
