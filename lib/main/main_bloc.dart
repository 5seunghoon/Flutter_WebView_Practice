import 'dart:async';

import '../webview/webview_base.dart';

class MainWebViewBloc {
  static final MainWebViewBloc _instance = MainWebViewBloc._internal();
  final _flutterWebViewPlugin = FlutterWebviewPlugin();

  String _nowUrl = "";

  factory MainWebViewBloc() {
    return _instance;
  }

  MainWebViewBloc._internal() {
    _flutterWebViewPlugin.onUrlChanged.listen((String url) {
      _nowUrl = url;
    });
  }

  void setUrl(String url) {
    _nowUrl = url;
    _flutterWebViewPlugin.reloadUrl(_nowUrl);
  }

  String getUrl() {
    return _nowUrl;
  }

  void onUrlChange(Function(String) listen) {
    _flutterWebViewPlugin.onUrlChanged.listen(listen);
  }

  void dispose() {}
}
