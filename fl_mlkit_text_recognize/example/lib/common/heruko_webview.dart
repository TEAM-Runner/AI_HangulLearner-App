import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';



main() async{
  runApp(const MaterialApp(
    // home: Browser(url: "https://rocky-eyrie-44345.herokuapp.com/", title: "12345"),
  ));
}

class Browser extends StatelessWidget{

  const Browser({Key? key,required this.url,required this.title}) : super(key: key);

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("flutter_WebView"),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
        allowsInlineMediaPlayback:true,
      ),
    );
  }
}

