// *** 메인 화면 스크린 ***
// 어플을 실행했을 때 나오는 메인 홈 화면 스크린
// 카메라, 학습 게임 버튼이 있다

// 카메라 버튼 클릭 -> screen_Camera.dart로 연결됨
// 학습 게임 버튼 틀릭 -> 아직 기능 X

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screen_Camera.dart';
import 'dart:ui';
import 'screen_profile.dart';
import 'screen_vacabularyList.dart';
import 'screen_game.dart';
import 'screen_game_result.dart';
import 'screen_game_wrongWordList.dart';
import 'package:tuple/tuple.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'screen_select_dicButton.dart';
import 'text_recognition.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final textRecogizer = TextRecognizer(script: TextRecognitionScript.korean);

  final ImagePicker picker = ImagePicker();
  // final ScanImageProcessor scanImageProcessor = ScanImageProcessor();

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    textRecogizer.close(); // 글자인식 관련
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    // 스크린 사이즈 정의
    Size screenSize = MediaQuery
        .of(context)
        .size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFF3F3F3),
            elevation: 0.0,
            // toolbarHeight: width*0.15,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: ()=> exit(0),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
              ),
            ],
            title: Text(
              "I HANGUL",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            centerTitle: true,
          ),

          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  height: height*1.0,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: <Widget>[
                      makeButton('책 읽어주기', 1 , '궁금한 부분을 찰칵', 1),
                      const Padding(
                        padding: EdgeInsets.all(10),
                      ),

                      makeButton('내가 찾은 단어', 3 , '내가 찾은 단어 알아보기', 3),
                      const Padding(
                        padding: EdgeInsets.all(10),
                      ),

                      makeButton('게임', 2 , '게임으로 실력 향상!', 2),
                      const Padding(
                        padding: EdgeInsets.all(10),
                      ),

                      // Text("추천단어", style: TextStyle(fontSize: width * 0.045),),
                      // //TODO: Recommended Words for Review
                      // Placeholder(),
                      const Padding(
                        padding: EdgeInsets.all(10),
                      ),
                    ],
                  ),
                  )
              ],
            ),
          )
      ),
    );
  }

  // 카메라, 학습게임, 단어장 버튼을 만드는 위젯
  Widget makeButton(String title, int iconNumber, String buttonText, int onPressNumber){
    Size screenSize = MediaQuery
        .of(context)
        .size;
    double width = screenSize.width;
    double height = screenSize.height;


    return Container(
      width: width*0.4,
      child: ElevatedButton(
        onPressed: ()  async {
          if (onPressNumber == 1){ //카메라 버튼 클릭
            final picker = ImagePicker();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("사진을 가져올 방법을 선택하세요", style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold)),
                  backgroundColor: Color(0xFFF3F3F3),
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox.fromSize( // 카메라 선택
                        size: Size(80, 80),
                        child: Material(
                          color: Colors.white, // button color
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              WidgetsFlutterBinding.ensureInitialized();
                              final cameras = await availableCameras();
                              final firstCamera = cameras.first;
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera)),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.camera_alt_outlined, size: 38), // icon
                                ),
                                Text("카메라", style: TextStyle(fontSize: width * 0.036)), // text
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 40.0),

                      SizedBox.fromSize( // 갤러리 선택
                        size: Size(80, 80),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          child: InkWell(
                            // splashColor: Colors.green, // splash color
                            onTap: () async {
                              print("### log ### : onTap");
                              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                final file = File(pickedFile.path);
                                final scanImageProcessor = ScanImageProcessor(
                                  context: context,
                                  onScanSuccess: (text) {
                                    print("Scanned Text: $text");
                                  },
                                  onScanError: (error) {
                                    print("Error: $error");
                                  },
                                );
                                scanImageProcessor.processImage(file, textRecogizer);
                              } else {
                                print("### log ### : else");
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.photo_library, size: 38), // icon
                                ),
                                Text("갤러리", style: TextStyle(fontSize: width * 0.036)), // text
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          if (onPressNumber == 2){ //학습게임 버튼 클릭
            // screen_game.dart로 연결
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameScreen()));
          }
          if (onPressNumber == 3){//단어장 버튼 클릭
            Navigator.push(context, MaterialPageRoute(builder: (context) => VocabularyListScreen()));
          }
        },
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          backgroundColor:
          MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  // side: BorderSide(color: Color(0xFFC0EB75), width: 2.0) // border line color
              )),),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: EdgeInsets.only(top:width*0.12)),
            Text(title, style: TextStyle(fontSize: width * 0.045),),
            Padding(padding: EdgeInsets.only(top:width*0.03)), // <-- Text
            // SizedBox(width: width*0.3,),

            Icon( // <-- Icon
              _choiceIcon(iconNumber),
              size: width*0.1,
            ),

            Padding(padding: EdgeInsets.only(top:width*0.03)),
            Text(buttonText, style: TextStyle(fontSize: width * 0.036),),
            Padding(padding: EdgeInsets.only(top:width*0.12)),

          ],
        ),
      ),
    );
  }

  // 카메라, 학습게임, 단어장 버튼의 아이콘을 리턴하는 함수
  _choiceIcon(int num) {
    switch(num) {
      case 1:
        return Icons.camera_alt_outlined;
      case 2:
        return Icons.videogame_asset_outlined;
      case 3:
        return Icons.book_outlined;
    }
  }
}


