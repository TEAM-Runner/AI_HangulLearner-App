import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:example/image_scan.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';


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

  @override
  void initState() {
    super.initState();
    //获取相机列表
    // Get camera list
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    //初始化,并返回Future
    //initialize controller, returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      //Use a FutureBuilder to display a loading spinner
      body: FutureBuilder<void>(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // 确保相机初始化
            await _initializeControllerFuture;

            //保存文件
            final image = await _controller.takePicture();
            ImageGallerySaver.saveFile(image.path);


            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(
        children: <Widget>[
          Image.file(File(imagePath)),
          Center(
            child: Row(children: <Widget>[
            ElevatedButton.icon(onPressed: ()=> Navigator.pop(context),
              icon: Icon(Icons.redo), label: Text('다시'),
            ),
            SizedBox(width: 20,),
            ElevatedButton.icon(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageScanPage())),
              icon: Icon(Icons.done), label: Text('선택'),
            ),
          ]),),
        ],
      )
    );
  }
}