// *** main.dart 파일 ***
// 페이지 간 이동을 위한 routes 정의
//
// 페이지 순서
// 어플 실행: main.dart
// [1](메인 홈 스크린) screen_home.dart 스크린 보여짐
//
// (1) 글자인식 기능-> (메인 홈 스크린: 카메라 버튼 클릭) screen_Camera.dart로 이동 -> (카메라 스크린: 촬영 버튼 클릭) screen_Camera_result.dart로 이동
//    (1-1) -> (카메라 결과 스크린: 사전 버튼 클릭) screen_dic.dart로 이동 -> (사전 스크린: 단어 버튼 클릭) screen_dic_oepn.dart로 이동
//    (1-2) -> (카메라 결과 스크린: 음성 버튼 클릭) screen_tts.dart로 이동
//
// (2) 학습 게임 기능 -> 아직 X


import 'package:code230206_hangul_app/screen/screen_splash.dart';
import 'package:code230206_hangul_app/screen/snackBarWidget.dart';
import 'package:flutter/material.dart';
import 'configuration/my_style.dart';
import 'screen/screen_dic.dart';
import 'screen/screen_dic_open.dart';
import 'screen/screen_tts.dart';
import 'screen/screen_auth_Login.dart';
import 'screen/screen_game_result.dart';
import 'screen/screen_game_wrongWordList.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  String DicScreenText = '';
  String TTSScreenText = '';
  String DicOpenScreenText= '';
  List<List<dynamic>>  GameResultScreenText = [];
  List<List<dynamic>>  GameWrongWordListScreenText = [];


  runApp(MaterialApp(
    scaffoldMessengerKey: SnackBarWidget.messengerKey,
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,

    // login, sign up 화면 prefix icon color 위해 추가
    //rgb(169, 227, 75)       #a9e34b
    theme: ThemeData().copyWith(
      colorScheme: ThemeData().colorScheme.copyWith(
        primary: Color(0xa9e34b),
      ),
    ),
    title: 'GP App',
    initialRoute: 'splash',
    routes: {
      '/':(context) => LoginScreen(),
      'splash':(context) => const SpalshScreen(),

      '/DicScreen':(context) => DicScreen(DicScreenText: DicScreenText),
      '/TTSScreen':(context) => TTSScreen(TTSScreenText: TTSScreenText),
      '/DicOpenScreen':(context) => DicOpenScreen(DicOpenScreenText: DicOpenScreenText),
      '/GameResultScreen':(context) => GameResultScreen(GameResultScreenText: GameResultScreenText),
      '/GameWrongWordListScreen':(context) => GameWrongWordListScreen(GameWrongWordListScreenText: GameWrongWordListScreenText),

    },
  ));
}

//
// import 'package:flutter/material.dart';
// // import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
// import 'configuration/hangul_scroll.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.red,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   void _incrementCounter() {}
//
//   // 앞에 ㄷ이런게 하나라도 있어야 뜸
//   List<String> hangulList = [
//     '다',
//     '다람쥐',
//     '마음',
//     '차',
//     '하마',
//     '곰',
//     '아메리카노',
//     '나비',
//     '나이',
//     '날',
//     '독',
//     '독배',
//     '땔감',
//     '로',
//     '라면',
//     '마법',
//     '법사',
//     '법',
//     '보물',
//     '뻘',
//     '속내',
//     '쏙',
//     '공룔',
//     '나이',
//     '슈화',
//     '난',
//     '농',
//     '바디',
//     '마술',
//     '잉',
//     '소리',
//     '한약',
//     '보름',
//     '하이',
//     '타이',
//     '태국',
//     '곰탕',
//     '바리바리',
//     '광',
//     '자연',
//     '이마'
//   ];
//
//   int selectedIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: AlphabetScrollView(
//               list: hangulList.map((e) => AlphaModel(e)).toList(),
//               alignment: LetterAlignment.right,
//               itemExtent: 50,
//               screenHeight: MediaQuery.of(context).size.height, // pass the screenHeight to the AlphabetScrollView widget
//
//               unselectedTextStyle: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.normal,
//                 color: Colors.black,
//               ),
//               selectedTextStyle: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red,
//               ),
//               overlayWidget: (value) => Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Icon(
//                     Icons.star,
//                     size: 50,
//                     color: Colors.red,
//                   ),
//                   Container(
//                     height: 50,
//                     width: 50,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                     ),
//                     alignment: Alignment.center,
//                     child: Text(
//                       '$value',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//               itemBuilder: (_, index, value) {
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 20),
//                   child: ListTile(
//                     title: Text('$value'),
//                     subtitle: Text('Secondary text'),
//                     leading: Icon(Icons.person),
//                     trailing: Radio<bool>(
//                       value: false,
//                       groupValue: selectedIndex != index,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           selectedIndex = index;
//                         });
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           FloatingActionButton(
//             onPressed: _incrementCounter,
//             tooltip: 'Increment',
//             child: Icon(Icons.add),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
