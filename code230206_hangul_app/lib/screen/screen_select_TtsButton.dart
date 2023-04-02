// ************************ 단어 단위로 읽어줌 ************************
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'screen_select_dicButton.dart';
// import 'screen_select_modifyButton.dart';
// import 'package:toggle_switch/toggle_switch.dart';
//
// class SelectTtsButtonScreen extends StatefulWidget {
//   late String text;
//
//   SelectTtsButtonScreen({required this.text});
//
//   @override
//   _SelectTtsButtonScreen createState() => _SelectTtsButtonScreen(text);
// }
//
// class _SelectTtsButtonScreen extends State<SelectTtsButtonScreen> {
//   late String _text;
//   List<String> _textWordArray = []; // 단어 단위로 저장하는 리스트 (dic 화면과 동일하게 tts 화면 표시하기 위해)
//   List<String> _textSentenceArray = []; // 문장 단위로 저장하는 리스트 (문장 단위로 tts 하기 위해)
//   // String? _selectedWord;
//
//   //TTS part
//   final FlutterTts tts = FlutterTts();
//   int currentSentenceIndex = -1; //현재 읽고 있는 문장 index를 기록하는 변수
//
//
//   _SelectTtsButtonScreen(String text) {
//     _text = text;
//     _textWordArray = text.split(' '); // 문장 단위로 나누도록 함
//     _textSentenceArray = text.split('.'); // 문장 단위로 나누도록 함
//     tts.setLanguage('kor');
//     tts.setSpeechRate(0.4);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     // 스크린 사이즈 정의
//     Size screenSize = MediaQuery
//         .of(context)
//         .size;
//     double width = screenSize.width;
//     double height = screenSize.height;
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFFF3F3F3),
//         elevation: 0.0,
//         title: Text(
//           "I HANGUL",
//           style: TextStyle(
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 16.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: Container(),
//                 ),
//                 ToggleSwitch(
//                   initialLabelIndex: 2,
//                   labels: ['수정', 'dic', 'tts'],
//                   customTextStyles: [
//                     TextStyle(fontSize: width * 0.045),
//                     TextStyle(fontSize: width * 0.045),
//                     TextStyle(fontSize: width * 0.045),
//                   ],
//                   radiusStyle: true,
//                   onToggle: (index) {
//                     if (index == 0) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SelectModifyButtonScreen(text: _text),
//                         ),
//                       );
//                     } else if (index == 1) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SelectDicButtonScreen(text: _text),
//                         ),
//                       );
//                     } else if (index == 2) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SelectTtsButtonScreen(text: _text),
//                         ),
//                       );
//                     }
//                   },
//                   minWidth: 90.0,
//                   cornerRadius: 20.0,
//                   activeBgColor: [Color(0xFFC0EB75)],
//                   activeFgColor: Colors.black,
//                   inactiveBgColor: Colors.white,
//                   inactiveFgColor: Colors.black,
//                 ),
//                 Expanded(
//                   child: Container(),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16.0),
//             Wrap(
//               spacing: 4.0,
//               runSpacing: 4.0,
//               children: _textWordArray.asMap().entries.map((word) {
//                 int index = word.key;
//                 String wordValue = word.value;
//
//                 bool isSelected = index == currentSentenceIndex;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       currentSentenceIndex = index;
//                     });
//                     tts.speak(_textWordArray[currentSentenceIndex]);
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(2.0),
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.yellow : null,
//                       borderRadius: BorderRadius.circular(4.0),
//                     ),
//                     child: Text(wordValue, style: TextStyle(fontSize: width * 0.045),),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ************************ 문장 단위로 읽어줌 ************************
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'screen_select_dicButton.dart';
// import 'screen_select_modifyButton.dart';
// import 'package:toggle_switch/toggle_switch.dart';
//
// class SelectTtsButtonScreen extends StatefulWidget {
//   late String text;
//
//   SelectTtsButtonScreen({required this.text});
//
//   @override
//   _SelectTtsButtonScreen createState() => _SelectTtsButtonScreen(text);
// }
//
// class _SelectTtsButtonScreen extends State<SelectTtsButtonScreen> {
//   late String _text;
//   List<String> _textSentenceArray = [];
//   final FlutterTts tts = FlutterTts();
//   int _currentSentenceIndex = -1;
//
//   @override
//   _SelectTtsButtonScreen(String text) {
//     _text = text;
//     _textSentenceArray = _text.split('.');
//     tts.setLanguage('kor');
//     tts.setSpeechRate(0.4);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     // 스크린 사이즈 정의
//     Size screenSize = MediaQuery.of(context).size;
//     double width = screenSize.width;
//     double height = screenSize.height;
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFFF3F3F3),
//         elevation: 0.0,
//         title: Text(
//           "I HANGUL",
//           style: TextStyle(
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 16.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: Container(),
//                 ),
//                 ToggleSwitch(
//                   initialLabelIndex: 2,
//                   labels: ['수정', 'dic', 'tts'],
//                   customTextStyles: [
//                     TextStyle(fontSize: width * 0.045),
//                     TextStyle(fontSize: width * 0.045),
//                     TextStyle(fontSize: width * 0.045),
//                   ],
//                   radiusStyle: true,
//                   onToggle: (index) {
//                     if (index == 0) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SelectModifyButtonScreen(text: _text),
//                         ),
//                       );
//                     } else if (index == 1) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SelectDicButtonScreen(text: _text),
//                         ),
//                       );
//                     } else if (index == 2) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SelectTtsButtonScreen(text: _text),
//                         ),
//                       );
//                     }
//                   },
//                   minWidth: 90.0,
//                   cornerRadius: 20.0,
//                   activeBgColor: [Color(0xFFC0EB75)],
//                   activeFgColor: Colors.black,
//                   inactiveBgColor: Colors.white,
//                   inactiveFgColor: Colors.black,
//                 ),
//                 Expanded(
//                   child: Container(),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16.0),
//             Wrap(
//               spacing: 4.0,
//               runSpacing: 4.0,
//               children: _textSentenceArray.asMap().entries.map((word) {
//                 int index = word.key;
//                 String wordValue = word.value;
//
//                 bool isSelected = index == _currentSentenceIndex;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _currentSentenceIndex = index;
//                     });
//                     tts.speak(_textSentenceArray[_currentSentenceIndex]);
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(2.0),
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.yellow : null,
//                       borderRadius: BorderRadius.circular(4.0),
//                     ),
//                     child: Text(wordValue, style: TextStyle(fontSize: width * 0.045),),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//
//     );
//   }
// }

// 로직
// 1. _textSentenceArray에는 '.'단위로 저장된다.
// 2. _textWordArray 단어를 클릭하면, '.'이 포함된 단어까지 인덱스를 +해서 string에 저장한다.
//    이 string과 일치하는 부분이 있는 textSentenceArray의 인덱스를 선택한다.
// 3. tts로 그 textSentenceArray를 읽어준다.

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screen_select_dicButton.dart';
import 'screen_select_modifyButton.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SelectTtsButtonScreen extends StatefulWidget {
  final String text;

  SelectTtsButtonScreen({required this.text});

  @override
  _SelectTtsButtonScreenState createState() => _SelectTtsButtonScreenState(text);
}

class _SelectTtsButtonScreenState extends State<SelectTtsButtonScreen> {
  final String _text; // 이전 화면에서 받아온 텍스트
  List<String> _textWordArray = []; // 단어를 저장하는 리스트
  List<String> _textSentenceArray = []; // 문장을 저장하는 리스트
  int _currentSentenceIndex = -1; // 현재 문장의 인덱스 표시 (처음 아무것도 선택X -> -1)

  final FlutterTts _tts = FlutterTts(); // tts

  // 초기화
  _SelectTtsButtonScreenState(this._text) {
    _textWordArray = _text.split(' '); // 단어 리스트 -> ' ' 공백문자 단위로 split
    _textSentenceArray = _text.split('. '); // 문장 리스트 -> '.' 온점 단위로 split
    _tts.setLanguage('kor'); // tts - 언어 한국어
    _tts.setSpeechRate(0.5); // tts - 읽기 속도
  }

  // tts 단어 읽어주는 함수 - 단어를 클릭했을 때 그 단어가 포함된 문장 전체 읽기 위해
  void _speakWord(int index) async {
    String word = _textWordArray[index]; // 현재 읽을 단어 = 단어 리스트[매개변수 인덱스]

    // 단어로 문장 인덱스 알아내기 // 여기에서 문제 발생
    int sentenceIndex = _textSentenceArray.indexWhere((sentence) => sentence.contains(word));
    // 문장 인덱스 = 문장 리스트...


    if (sentenceIndex != -1) { // 문장 인덱스가 -1이 아니라면
      _speakSentence(sentenceIndex); // tts 문장 읽어주는 함수 실행
    }
  }

  // tts 문장 읽어주는 함수
  void _speakSentence(int index) async {
    setState(() {
      _currentSentenceIndex = index; // index를 매개변수로 받아서 현재 인덱스에 저장
    });
    await _tts.stop(); // 실행되고 있는 tts 중단
    await _tts.speak(_textSentenceArray[index]); // index위치의 문장 tts로 읽기 시작
  }



  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF3F3F3),
        elevation: 0.0,
        title: Text(
          "I HANGUL",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(),
                ),
                ToggleSwitch(
                  initialLabelIndex: 2,
                  labels: ['수정', 'dic', 'tts'],
                  customTextStyles: [
                    TextStyle(fontSize: width * 0.045),
                    TextStyle(fontSize: width * 0.045),
                    TextStyle(fontSize: width * 0.045),
                  ],
                  radiusStyle: true,
                  onToggle: (index) {
                    if (index == 0) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectModifyButtonScreen(text: _text),
                        ),
                      );
                    } else if (index == 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectDicButtonScreen(text: _text),
                        ),
                      );
                    } else if (index == 2) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectTtsButtonScreen(text: _text),
                        ),
                      );
                    }
                  },
                  minWidth: 90.0,
                  cornerRadius: 20.0,
                  activeBgColor: [Color(0xFFC0EB75)],
                  activeFgColor: Colors.black,
                  inactiveBgColor: Colors.white,
                  inactiveFgColor: Colors.black,
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: _textWordArray.asMap().entries.map((word) {
                int index = word.key;
                String wordValue = word.value;

                bool isSelected = _currentSentenceIndex != -1 && _textSentenceArray[_currentSentenceIndex].contains(wordValue);

                return GestureDetector(
                  onTap: () {
                    _speakWord(index);
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.yellow : null,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(wordValue, style: TextStyle(fontSize: width * 0.045),),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
