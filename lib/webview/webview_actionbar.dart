import 'package:flutter/material.dart';

import 'webview_base.dart';

class WebviewActionbar extends StatefulWidget {
  static String urlString = "http://www.naver.com";

  final _flutterWebViewPlugin = FlutterWebviewPlugin();

  final _urlTextEditController = TextEditingController(text: urlString);

  static final double appBarHeight = 54.0;
  double _animationAppBarHeight = appBarHeight;
  double _prevYDirection = 0.0;

  @override
  State<StatefulWidget> createState() => WebviewActionbarState();
}

class WebviewActionbarState extends State<WebviewActionbar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    _setUrlChangeListener();
    _setScrollListener();

    return _scrollRemoveAnimation(_appBarWidget());
  }

  void _setUrlChangeListener() {
    widget._flutterWebViewPlugin.onUrlChanged.listen((String url) {
      widget._urlTextEditController.text = url;
      print("url on change : $url");
    });
  }

  void _setScrollListener() {
    widget._flutterWebViewPlugin.onScrollYChanged.listen((double y) {
      setState(() {
        if (widget._prevYDirection < y) {
          // scroll down
          widget._animationAppBarHeight = 0.0;
        } else if (widget._prevYDirection > y) {
          // scroll up
          widget._animationAppBarHeight = WebviewActionbar.appBarHeight;
        }
        widget._prevYDirection = y;
      });
    });
  }

  Widget _scrollRemoveAnimation(Widget childWidget) {
    /// 스크롤시 앱바가 사라지게 하는 애니메이션을 설정하는 부분
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: widget._animationAppBarHeight,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white),
      child: ClipRect(
        child: Align(alignment: Alignment.bottomCenter, child: childWidget),
      ),
    );
  }

  Widget _appBarWidget() {
    /// 앱 바 본체 위젯
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            IconButton(
              padding: EdgeInsets.all(0.0),
              icon: Icon(
                Icons.trip_origin,
                color: Colors.green,
              ),
              onPressed: () {
                WebviewActionbar.urlString = "http://www.naver.com";
                widget._urlTextEditController.text = WebviewActionbar.urlString;
                widget._flutterWebViewPlugin
                    .reloadUrl(WebviewActionbar.urlString);
              },
            ),
            Expanded(
              child: TextField(
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                ),
                controller: widget._urlTextEditController,
                keyboardType: TextInputType.url,
                onSubmitted: (String str) {
                  widget._flutterWebViewPlugin.reloadUrl(str);
                  widget._urlTextEditController.text = str;
                },
              ),
            ),
            IconButton(
              padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                widget._flutterWebViewPlugin
                    .reloadUrl(WebviewActionbar.urlString);
              },
            )
          ],
        ),
      ),
    );
  }
}
