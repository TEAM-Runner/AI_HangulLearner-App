import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// A screen that allows users to take a picture using a given camera.
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

}