// *** main.dart 파일 ***
// 페이지 간 이동을 위한 routes 정의

// 페이지 순서
// 어플 실행: main.dart
// [1](메인 홈 스크린) screen_home.dart 스크린 보여짐

// (1) 글자인식 기능-> (메인 홈 스크린: 카메라 버튼 클릭) screen_Camera.dart로 이동 -> (카메라 스크린: 촬영 버튼 클릭) screen_Camera_result.dart로 이동
//    (1-1) -> (카메라 결과 스크린: 사전 버튼 클릭) screen_dic.dart로 이동 -> (사전 스크린: 단어 버튼 클릭) screen_dic_oepn.dart로 이동
//    (1-2) -> (카메라 결과 스크린: 음성 버튼 클릭) screen_tts.dart로 이동

// (2) 학습 게임 기능 -> 아직 X


import 'package:code230206_hangul_app/screen/screen_tts.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'screen/screen_home.dart';
import 'package:camera/camera.dart';
import 'screen/screen_Camera.dart';
import 'screen/screen_dic.dart';
import 'screen/screen_tts.dart';
import 'screen/screen_dic_open.dart';

void main() {
  String DicScreenText = '';
  String TTSScreenText = '';
  String DicOpenScreenText= '';
  runApp(MaterialApp(
    title: 'GP App',
    initialRoute: '/',
    routes: {
      '/':(context) => HomeScreen(),
      '/DicScreen':(context) => DicScreen(DicScreenText: DicScreenText),
      '/TTSScreen':(context) => TTSScreen(TTSScreenText: TTSScreenText),
      '/DicOpenScreen':(context) => DicOpenScreen(DicOpenScreenText: DicOpenScreenText),
    },
  ));
}
