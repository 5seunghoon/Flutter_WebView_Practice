import 'package:flutter/material.dart';

import 'webview_base.dart';

class WebviewActionbar extends StatefulWidget {
  static String urlString = "http://www.naver.com";

  final _flutterWebViewPlugin = FlutterWebviewPlugin();

  final _urlTextEditController = TextEditingController(text: urlString);

  bool _appbarVisible = true;
  double _prevYDirection = 0.0;

  @override
  State<StatefulWidget> createState() => WebviewActionbarState();
}

class WebviewActionbarState extends State<WebviewActionbar> {
  @override
  Widget build(BuildContext context) {
    widget._flutterWebViewPlugin.onUrlChanged.listen((String url) {
      widget._urlTextEditController.text = url;
      print("url on change : $url");
    });
    widget._flutterWebViewPlugin.onScrollYChanged.listen((double y) {
      setState(() {
        if (widget._prevYDirection < y) {
          // scroll down
          widget._appbarVisible = false;
        } else if (widget._prevYDirection > y) {
          // scroll up
          widget._appbarVisible = true;
        }
        widget._prevYDirection = y;
      });
    });

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: AnimatedOpacity(
        opacity: widget._appbarVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 200),
        child: Container(
            width: double.infinity,
            height: 54.0,
            decoration: BoxDecoration(color: Colors.white),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: 54.0,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(
                          Icons.trip_origin,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          WebviewActionbar.urlString = "http://www.naver.com";
                          widget._urlTextEditController.text =
                              WebviewActionbar.urlString;
                          widget._flutterWebViewPlugin
                              .reloadUrl(WebviewActionbar.urlString);
                        },
                      ),
                      Flexible(
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
                        flex: 1,
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
              ),
            )),
      ),
    );
  }
}
