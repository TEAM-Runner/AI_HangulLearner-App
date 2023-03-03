// *** 메인 화면 스크린 ***
// 어플을 실행했을 때 나오는 메인 홈 화면 스크린
// 카메라, 학습 게임 버튼이 있다

// 카메라 버튼 클릭 -> screen_Camera.dart로 연결됨
// 학습 게임 버튼 틀릭 -> 아직 기능 X

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screen_Camera.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          toolbarHeight: width*0.15,
          title: Text("I HANGUL"),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                gradient: LinearGradient(
                    colors: [Colors.deepPurpleAccent,Colors.deepPurple],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter
                )
            ),
          ),

        ),

        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0),
          height: height*0.33,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                makeButton('카메라', 1 , '궁금한 부분을', '촬영하세요', 1),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                makeButton('학습게임', 2 , '학습게임으로 단어를', '공부하세요', 2),
                Padding(
                  padding: EdgeInsets.all(10),
                ),

                // 단어장 기능은 학습게임용 DB를 이용하면 쉽게 만들 수 있을 것 같아 넣어둠
                // 프로젝트 진행 속도에 따라 생략 가능
                makeButton('(임시)단어장', 3 , '지금까지 공부한', '단어를 복습하세요', 3),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
              ],
            )
        ),
      ),
    );
  }

  // 카메라, 학습게임, (임시)단어장 버튼을 만드는 위젯
  Widget makeButton(String title, int iconNunber, String firstString, String secondString, int onPressNumber){
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
            WidgetsFlutterBinding.ensureInitialized();
            final cameras = await availableCameras();
            final firstCamera = cameras.first;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera)),
            );
          }
          if (onPressNumber == 2){ //학습게임 버튼 클릭
          }
          if (onPressNumber == 3){ //(임시)단어장 버튼 클릭
          }
        },
        style: ButtonStyle(

          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          backgroundColor:
          MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.deepPurple, width: 2.0) // border line color
              )),),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: EdgeInsets.only(top:width*0.12)),
            Text(title, style: TextStyle(fontSize: width * 0.045),),
            Padding(padding: EdgeInsets.only(top:width*0.03)), // <-- Text
            SizedBox(width: width*0.3,),

            Icon( // <-- Icon
              // Icons.sticky_note_2_outlined,
              _choiceIcon(iconNunber),
              size: width*0.1,
            ),
            Padding(padding: EdgeInsets.only(top:width*0.03)),
            Text(firstString, style: TextStyle(fontSize: width * 0.036),),
            Text(secondString, style: TextStyle(fontSize: width * 0.036),),
          ],
        ),
      ),
    );
  }

  // 카메라, 학습게임, (임시)단어장 버튼의 아이콘을 리턴하는 함수
  _choiceIcon(int num) {
    switch(num) {
      case 1:
        return Icons.camera_alt_outlined;
      case 2:
        return Icons.sticky_note_2_outlined;
      case 3:
        return Icons.book_outlined;
    }
  }
}
