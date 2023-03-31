// *** 메인 화면 스크린 ***
// 어플을 실행했을 때 나오는 메인 홈 화면 스크린
// 카메라, 학습 게임 버튼이 있다

// 카메라 버튼 클릭 -> screen_Camera.dart로 연결됨
// 학습 게임 버튼 틀릭 -> 아직 기능 X

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
            actions: <Widget>[
              new IconButton(
                icon: new Icon(Icons.person_outline_sharp),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
              ),

            ],
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

          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                height: height*0.33,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    makeButton('카메라', 1 , '궁금한 부분을', '촬영하세요', 1),
                    const Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    makeButton('학습게임', 2 , '학습게임으로 단어를', '공부하세요', 2),
                    const Padding(
                      padding: EdgeInsets.all(10),
                    ),

                    // 단어장 기능은 학습게임용 DB를 이용하면 쉽게 만들 수 있을 것 같아 넣어둠
                    // 프로젝트 진행 속도에 따라 생략 가능
                    makeButton('단어장', 3 , '지금까지 공부한', '단어를 복습하세요', 3),
                    const Padding(
                      padding: EdgeInsets.all(10),
                    ),
                  ],
                ),
              ),

              // ElevatedButton(
              //   onPressed: () {
              //     // FirebaseAuth.instance.signOut(); // 임시 로그아웃
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              // },
              //   style: ElevatedButton.styleFrom(
              //       padding: EdgeInsets.all(10),
              //       backgroundColor: Colors.deepPurple),
              //   child: Text('(임시 버튼) 회원 정보 수정', style: TextStyle(fontSize: width * 0.036),),
              // ),
            ],
          )
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
            // screen_game.dart로 연결
            // Navigator.push(context, MaterialPageRoute(builder: (context) => ConsonantGame()));


            // (임시) screen_game_result.dart로 연결
            List<Tuple3<String, String, bool>> gameResultTestList = [
              Tuple3('word1', 'mean1', true),
              Tuple3('word2', 'mean2', false),
              Tuple3('word3', 'mean3', true),
              Tuple3('word4', 'mean4', false),
              Tuple3('word5', 'mean5', true),
              Tuple3('word6', 'mean6', true),
              Tuple3('word7', 'mean7', true),
              Tuple3('word8', 'mean8', true),
              Tuple3('word9', 'mean9', true),
              Tuple3('word10', 'mean10', true),
            ];
            Navigator.pushNamed(context, GameResultScreen.GameResultScreenRouteName, arguments: GameResultScreen(GameResultScreenText: gameResultTestList));

          }
          if (onPressNumber == 3){//(임시)단어장 버튼 클릭
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
