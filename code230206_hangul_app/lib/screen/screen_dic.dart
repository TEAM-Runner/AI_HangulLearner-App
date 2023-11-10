// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'screen_dic_open.dart';
//
// class DicScreen extends StatefulWidget {
//
//   static const String DicScreenRouteName = "/DicScreen";
//   final String DicScreenText;
//   DicScreen({required this.DicScreenText});
//
//   @override
//   _DicScreen createState() => _DicScreen();
// }
//
// class _DicScreen extends State<DicScreen> {
//   // String testSentence = '저 멀리 깊고 푸른 바다 속에, 물고기 한 마리가 살고 있었습니다. 그 물고기는 보통 물고기가 아니라 온 바다에서 가장 아름다운 물고기였습니다. 파랑, 초록, 자줏빛 바늘 사이사이에 반짝반짝 빛나는 은빛 비늘이 박혀 있었거든요. 다른 물고기들도 그 물고기의 아름다운 모습에 감탄했습니다.';
//
//   var word;
//   @override
//   Widget build(BuildContext context) {
//
//     // 스크린 사이즈 정의
//     Size screenSize = MediaQuery.of(context).size;
//     double width = screenSize.width;
//     double height = screenSize.height;
//
//     final args = ModalRoute.of(context)!.settings.arguments as DicScreen;
//     String testSentence = '${args.DicScreenText}';
//
//     //final String testSentence = this.testSentence;
//     List<String> testSentenceArray = new List<String>.empty(growable: true);
//     List<ElevatedButton> buttonsList = new List<ElevatedButton>.empty(growable: true);
//
//     return SafeArea(
//         child: Scaffold(
//             appBar: AppBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0.0,
//               toolbarHeight: width*0.15,
//               title: Image.asset("assets/images/i_hangul.png"),
//               centerTitle: true,
//               flexibleSpace: Container(
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
//                     gradient: LinearGradient(
//                         colors: [Colors.deepPurpleAccent,Colors.deepPurple],
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter
//                     )
//                 ),
//               ),
//             ),
//             body: SingleChildScrollView(
//               padding: EdgeInsets.all(width * 0.024),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(width * 0.024),
//                   ),
//                   Text(
//                     '궁금한 단어를 클릭하세요',
//                     style: TextStyle(
//                       fontSize: width * 0.045,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(width * 0.024),
//                   ),
//                   Wrap(
//                       children: _buildButtonsWithWords(width, height, testSentence, testSentenceArray, buttonsList)
//                   ),
//                 ],
//               ),
//             )
//         )
//     );
//
//   }
//
//   // 인식한 문장들을 ' '(띄어쓰기) 단위로 나눈 단어 버튼으로 만드는 함수
//   List<Widget> _buildButtonsWithWords(width, height, testSentence, testSentenceArray, buttonsList) {
//     List<String> testSentenceArray = testSentence.split(' ');
//     for (int i = 0; i < testSentenceArray.length; i++) {
//       word = testSentenceArray[i];
//       buttonsList.add(ElevatedButton(
//           onPressed: () {
//             Navigator.pushNamed( // 버튼이 클릭되면 screen_dic_open.dart로 클릭한 단어를 전달함
//                 context,
//                 DicOpenScreen.DicOpenScreenRouteName,
//                 arguments: DicOpenScreen(DicOpenScreenText: testSentenceArray[i]));
//           },
//           child: Text(testSentenceArray[i]),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.deepPurple,
//           )
//       )
//       );
//     }
//     return buttonsList;
//   }
// }
