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
          Padding(
            padding: EdgeInsets.all(width * 0.05),
          ),
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
            padding: EdgeInsets.all(width * 0.02),
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
    if (_controller == null) return;

    final navigator = Navigator.of(context);
    try{
      final pictureFile = await _controller!.takePicture();
      final file = File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecogizer.processImage(inputImage);

      await navigator.push(
          MaterialPageRoute(builder: (context) => ResultScreen(text: recognizedText.text))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred when scanning text')));
    }
  }
}