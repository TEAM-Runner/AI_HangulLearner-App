// *** 카메라 스크린 ***
// 카메라 화면, 촬영 버튼이 있는 스크린

// (1) 촬영 기능
// 촬영 버튼 클릭 -> screen_Camera_result.dart로 연결됨

// (2) 글자 인식 기능
// 사진의 글자를 google mlkit로 인식함
// 인식한 결과(문장)을 screen_Camera_result 스크린에 넘겨줌

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as Path;
import 'screen_Camera_result.dart';

class TakePictureScreen extends StatefulWidget {

  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  //글자인식 결과
  final textRecogizer = TextRecognizer(script: TextRecognitionScript.korean);

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    textRecogizer.close(); // 글자인식 관련
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Size screenSize = MediaQuery
        .of(context)
        .size;
    double width = screenSize.width;
    double height = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.black,

      body: Column(
        children: [
          // Padding(
          //   padding: EdgeInsets.all(width * 0.05),
          // ),
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Padding(
            padding: EdgeInsets.all(width * 0.01),
          ),
          FloatingActionButton(
              onPressed: _scanImage,
              child: Icon(Icons.camera_alt_outlined),
              backgroundColor: const Color(0xff252525))
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   // Provide an onPressed callback.
      //   onPressed: _scanImage,
      //   child: const Icon(Icons.camera_alt_outlined),
      //   backgroundColor: Colors.black,
      // ),
    );
  }

  Future<void> _scanImage() async{

    // final String testtext = '저 멀리 깊고 푸른 바다 속에, 물고기 한 마리가 살고 있었습니다. 그 물고기는 보통 물고기가 아니라 온 바다에서 가장 아름다운 물고기였습니다. 파랑, 초록, 자줏빛 바늘 사이사이에 반짝반짝 빛나는 은빛 비늘이 박혀 있었거든요. 다른 물고기들도 그 물고기의 아름다운 모습에 감탄했습니다. 물고기들은 그 물고기를 무지개 물고기라고 불렀습니다. 물고기들은 무지개 물고기에게 말을 붙였습니다.';
    // final String testtext = '아이린은 양털 장화를 신고, 빨간 모자와 목도리를 두르고, 두꺼운 외투를 입고, 벙어리장갑을 꼈습니다. 그런 다음 엄마의 뜨거운 이마에 여섯 번이나 입을 맞추고, 한번 더 맞추었습니다. 아이린은 엄마의 이불이 잘 덮였나 확인하고 나서 커다란 옷 상자를 들고 살며시 밖으로 나왔습니다. 그리고 문을 꼭 닫았습니다.';

    if (_controller == null) return;

    final navigator = Navigator.of(context);
    try{
      final pictureFile = await _controller!.takePicture();
      final file = File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecogizer.processImage(inputImage);

      await navigator.push(
        // 기본 코드
          MaterialPageRoute(builder: (context) => ResultScreen(text: recognizedText.text))

        // // 테스트용 코드
        // MaterialPageRoute(builder: (context) => ResultScreen(text: testtext))

      );
    } catch (e) {
      // 테스트용 코드
      // await navigator.push(
      //     MaterialPageRoute(builder: (context) => ResultScreen(text: testtext))
      // );
      // 기본 코드
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred when scanning text')));
    }
  }
}