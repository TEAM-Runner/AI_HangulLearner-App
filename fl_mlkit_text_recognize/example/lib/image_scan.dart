import 'dart:io';

import 'package:example/main.dart';
import 'package:fl_mlkit_text_recognize/fl_mlkit_text_recognize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';



class ImageScanPage extends StatefulWidget {
  const ImageScanPage({Key? key}) : super(key: key);

  @override
  State<ImageScanPage> createState() => _ImageScanPageState();
}

class _ImageScanPageState extends State<ImageScanPage> {
  String? path;
  AnalysisTextModel? model;
  List<String> types =
      RecognizedLanguage.values.builder((item)  => item.toString().replaceAll('RecognizedLanguage.', ''));


  int? selectIndex;

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('이미지로 문자식별'),
        padding: const EdgeInsets.all(20),
        isScroll: true,
        children: <Widget>[
          ElevatedText(onPressed: openGallery, text: 'Select Picture/포토 선택'),
          ElevatedButton(
              onPressed: () {},
              child: DropdownMenuButton.material(
                  itemCount: types.length,
                  iconColor: Colors.white,
                  onChanged: (int index) {
                    selectIndex = index;
                    FlMlKitTextRecognizeController().setRecognizedLanguage(
                        RecognizedLanguage.values[selectIndex!]);
                  },
                  defaultBuilder: (int? index) => BText(index == null
                      ? 'Select Recognized Language\n '
                                '언어선택'
                      : types[index]),
                  itemBuilder: (int index) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      decoration: const BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: Colors.grey))),
                      child: BText(types[index], color: Colors.black)))),
          ElevatedText(onPressed: scanByte, text: 'Scanning \n 식별'),
          ShowText('path', path),
          if (path != null && path!.isNotEmpty)
            Container(
                width: double.infinity,
                height: 300,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 40),
                child: Image.file(File(path!))),
          if (model == null) const ShowText('Unrecognized', 'Unrecognized'),
          ShowCode(model, expanded: false)
        ]);
  }

  Future<void> scanByte() async {
    if (path == null || path!.isEmpty) {
      showToast('Please select a picture');
      return;
    }
    if (selectIndex == null) {
      showToast('Please select recognized language');
      return;
    }
    bool hasPermission = false;
    if (isAndroid) hasPermission = await getPermission(Permission.storage);
    if (isIOS) hasPermission = true;
    if (hasPermission) {
      final File file = File(path!);
      final AnalysisTextModel? data = await FlMlKitTextRecognizeController()
          .scanImageByte(file.readAsBytesSync());
      if (data != null) {
        model = data;
        setState(() {});
      } else {
        showToast('no data');
      }
    }
  }

  Future<void> openGallery() async {
    bool hasPermission = false;
    if (isAndroid) hasPermission = await getPermission(Permission.storage);
    if (isIOS) hasPermission = true;
    if (hasPermission) {
      final String? data = await Curiosity().gallery.openSystemGallery();
      path = data;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    FlMlKitTextRecognizeController().dispose();
  }
}
