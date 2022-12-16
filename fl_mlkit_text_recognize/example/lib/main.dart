import 'package:camera/camera.dart';
import 'package:example/camera_scan.dart';
import 'package:example/common/heruko_webview.dart';
import 'package:example/image_scan.dart';
import 'package:example/mlkit_text_recognize.dart';
import 'package:example/take_photo.dart';
import 'package:fl_mlkit_text_recognize/fl_mlkit_text_recognize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPage extends StatefulWidget {
  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  static TextStyle mTextStyle = TextStyle(
    color: Colors.black87,
    fontSize: 40,
    fontFamily: 'D2Coding',
  );
  static var mBackgroundColor =Color.fromRGBO(255, 193, 7, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('아이 한글'),
          backgroundColor: Color.fromRGBO(255, 193, 7, 1),
        ),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: mBackgroundColor,
                  ),
                  child: TextButton(
                    onPressed: takePhoto,
                    child: Text(
                      "카메라",
                      style: mTextStyle,
                    ),
                  ),
                ),
              ),
              const Divider(
                color: Colors.black,
                height: 10,
                thickness: 1,
                indent: 20,
                endIndent: 0,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: mBackgroundColor,
                  ),
                  child: TextButton(
                    onPressed: scanImage,
                    child: Text(
                      "문자식별",
                      style: mTextStyle,
                    ),
                  ),
                ),
              ),
              const Divider(
                color: Colors.black,
                height: 10,
                thickness: 1,
                indent: 20,
                endIndent: 0,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: mBackgroundColor,
                  ),
                  child: TextButton(
                    onPressed: openBrowser,
                    child: Text(
                      "사전",
                      style: mTextStyle,
                    ),
                  ),
                ),
              ),
              const Divider(
                color: Colors.black,
                height: 10,
                thickness: 1,
                indent: 20,
                endIndent: 0,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: mBackgroundColor,
                  ),
                  child: TextButton(
                    onPressed: takePhoto,
                    child: Text(
                      "게임",
                      style: mTextStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  //跳转到take_photo页面
  Future<void> takePhoto() async {
    bool hasPermission = false;
    if (isAndroid) hasPermission = await getPermission(Permission.camera);
    if (isIOS) hasPermission = true;

    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    if (hasPermission) push(TakePictureScreen(camera: firstCamera));
  }
}

void scanImage() {
  push(const ImageScanPage());
}

void openBrowser() {
  push(const Browser(url: "https://www.youtube.com", title: "flutter_WebView"));
  // push(const Browser(url: "https://rocky-eyrie-44345.herokuapp.com/", title: "flutter_WebView"));
}

Future<void> scanCamera() async {
  if (!isMobile) return;
  final bool permission = await getPermission(Permission.camera);
  if (permission) push(const CameraScanPage());
}

Future<void> openCamera() async {
  bool hasPermission = false;
  if (isAndroid) hasPermission = await getPermission(Permission.camera);
  if (isIOS) hasPermission = true;
  if (hasPermission) push(const FlMlKitTextRecognizePage());
}

class ShowCode extends StatelessWidget {
  const ShowCode(this.model, {Key? key, this.expanded = true})
      : super(key: key);
  final AnalysisTextModel? model;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Universal(expanded: expanded, isScroll: expanded, children: <Widget>[
      ShowText('height=', model?.height),
      ShowText('width=', model?.width),
      ShowText('value=', model?.text),
      const Divider(),
      ...model?.textBlocks
              ?.map((TextBlock b) => SizedBox(
                  width: double.infinity, child: ShowText('TextBlock', b.text)))
              .toList() ??
          <Widget>[]
    ]);
  }
}

class AppBarText extends AppBar {
  AppBarText(String text, {Key? key})
      : super(
            key: key,
            elevation: 0,
            title: BText(text,
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            centerTitle: true);
}

class ShowText extends StatelessWidget {
  final dynamic keyName;
  final dynamic value;

  const ShowText(this.keyName, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: value != null &&
            value.toString().isNotEmpty &&
            value.toString() != 'null',
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: RText(textAlign: TextAlign.start, texts: <String>[
              '$keyName: ',
              value.toString()
            ], styles: const <TextStyle>[
              TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1.3),
              TextStyle(color: Colors.black, height: 1.3),
            ])));
  }
}

Future<bool> getPermission(Permission permission) async {
  PermissionStatus status = await permission.status;
  if (status.isGranted) {
    return true;
  } else {
    status = await permission.request();
    if (!status.isGranted) openAppSettings();
    return status.isGranted;
  }
}

class ElevatedText extends StatelessWidget {
  const ElevatedText({Key? key, this.onPressed, required this.text})
      : super(key: key);
  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: Text(text));
}

class ElevatedIcon extends StatelessWidget {
  const ElevatedIcon({Key? key, this.onPressed, required this.icon})
      : super(key: key);
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ElevatedButton(
      onPressed: onPressed, child: Icon(icon, color: Colors.white));
}
