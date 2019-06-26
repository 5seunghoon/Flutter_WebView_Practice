import 'package:flutter/material.dart';

import 'webview_base.dart';

class WebviewActionbar extends StatelessWidget {
  static String urlString = "http://www.naver.com";

  final _flutterWebViewPlugin = FlutterWebviewPlugin();

  final _urlTextEditController = TextEditingController(text: urlString);

  @override
  Widget build(BuildContext context) {
    _flutterWebViewPlugin.onUrlChanged.listen((String url) {
      _urlTextEditController.text = url;
      print("url on change : $url");
    });

    return Container(
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
                      urlString = "http://www.naver.com";
                      _urlTextEditController.text = urlString;
                      _flutterWebViewPlugin.reloadUrl(urlString);
                    },
                  ),
                  Flexible(
                    child: TextField(
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                      controller: _urlTextEditController,
                      keyboardType: TextInputType.url,
                      onSubmitted: (String str) {
                        _flutterWebViewPlugin.reloadUrl(str);
                        _urlTextEditController.text = str;
                      },
                    ),
                    flex: 1,
                  ),
                  IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      _flutterWebViewPlugin.reloadUrl(urlString);
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
