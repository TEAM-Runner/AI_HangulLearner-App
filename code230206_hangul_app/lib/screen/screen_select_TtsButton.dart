import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screen_select_dicButton.dart';
import 'screen_select_modifyButton.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'dart:async';


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
  Map<int, int> _wordToSentenceIndexMap = {}; // 단어 인덱스와 문장 인덱스 매핑. 단어에서 문장 인덱스 알아내기 위해
  int _toggleSwitchvalue = 1; // tts 속도를 지정하는 토글 스위치 인덱스
  List<String> _TTSWordArray = []; // TTS로 읽을 단어들을 저장하는 리스트

  int _currentSentenceIndex = -1; // 현재 문장의 인덱스 표시 (처음 아무것도 선택X -> -1)
  final FlutterTts _tts = FlutterTts(); // tts
  List _ttsSpeed = [0.2, 0.3, 0.5]; // tts 속도 저장 리스트. 느림 - 보통 - 빠름
  int _ttsSpeedindex = 1; // _ttsSpeed 리스트의 인덱스 저장

  List<bool> isSelected = [];// 노란색 highlight를 표시할 것인지 판단하는 bool 리스트

  StreamController<List<bool>> _streamController = StreamController<List<bool>>.broadcast();
  // StreamController _streamController = StreamController();
  Stream get stream => _streamController.stream;

  // 초기화
  _SelectTtsButtonScreenState(this._text) {
    _textWordArray = _text.split('\n').expand((line) => line.split(' ')).toList();
    _textSentenceArray = _text.split(RegExp('[.!?]')); // 문장 리스트 -> '.', '?', '!' 문장 단위로 split

    _tts.setLanguage('kor'); // tts - 언어 한국어
    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedindex]); // tts - 읽기 속도. 기본 보통 속도
    FindWordToSentenceIndex findWordToSentenceIndex = FindWordToSentenceIndex(_text, _textWordArray, _textSentenceArray);
    _wordToSentenceIndexMap = findWordToSentenceIndex._wordToSentenceIndexMap;
    isSelected = List.generate(_textWordArray.length, (_) => false); // isSelecte를 모두 false로 초기화


    // stream 동기화 관련
    // isSelectedController = StreamController<List<bool>>.broadcast();
    // isSelected[index] = false;
    // isSelectedController.add(isSelected);

  }


  // 단어를 tts로 읽어주는 함수 - 단어를 클릭했을 때 그 단어가 포함된 문장 전체 읽기 위해
  void _speakWord(int index) async {
    int? sentenceIndex = _wordToSentenceIndexMap[index]; // 단어로 문장 인덱스 알아내기

    // _TTSWordArray.clear();
    isSelected = List.generate(_textWordArray.length, (_) => false); // isSelecte를 모두 false로 초기화
    int sentenceFirstWordIndex = -1; // 클릭한 문장의 첫 번째 단어 인덱스
    int sentenceWordLength = 0; // 클릭한 문장의 길이
    bool found = false; // 첫 번재 단어를 찾는 flag

    if (_currentSentenceIndex == -1) {
      isSelected = List.filled(_textWordArray.length, false);
    }
    else {
      _wordToSentenceIndexMap.forEach((key, value) {
        if (value == sentenceIndex && !found) {
          sentenceFirstWordIndex = key;
          found = true; // flag를 true로 세팅
        }
        if (value == sentenceIndex) {
          sentenceWordLength++; // 길이 하나씩 증가시킴
        }
      });
      // print('***  sentenceFirstWordIndex  *** ' + sentenceFirstWordIndex.toString());
      // print('***  sentenceWordLength  *** ' + sentenceWordLength.toString());
    }
    _TTSWordArray.add(sentenceIndex.toString()); // sentenceIndex를 맨 첫번째에 저장

    for (int i = sentenceFirstWordIndex; i < sentenceFirstWordIndex + sentenceWordLength; i++) {
      if (i >= _textWordArray.length) {
        break;
      }
      _TTSWordArray.add(_textWordArray[i]);
    }
    print('***  _TTSWordArray  *** ' + _TTSWordArray.toString());

    if (sentenceIndex != -1) { // 문장 인덱스가 -1이 아니라면
      _speakSentence(_TTSWordArray); // tts 문장 읽어주는 함수 실행
    }
  }

  // 1개 문장을 tts로 읽어주는 함수
  void _speakSentence(List _TTSWordArray) async {
    setState(() {
      // _setIsSelected();
      _setIsSelected_2(-1);
    });
    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedindex]); // tts - 읽기 속도
    _StopSpeakTts();
    await _tts.awaitSpeakCompletion(true); // TTS로 읽는 게 끝날 때까지 기다리기

    int firstKeyIndex = findFirstKeyByValue(_wordToSentenceIndexMap, _currentSentenceIndex);
    _setIsSelected_2(firstKeyIndex);
    // print('***  firstKeyIndex  *** ' + firstKeyIndex.toString());

    // TTS 출력 중 _TTSWordArray가 변경되었는지 확인하는 코드
    // 변경되었다면 while 루프를 멈추고 변경된 코드를 다시 실행
    List<String> originalList = List.from(_TTSWordArray); // _TTSWordArray의 복사본 생성
    print('***  originalList  *** ' + originalList.toString());

    int i = 1; // 맨 앞에 저장된 sentenceIndex는 제외하고 TTS 출력
    while (i < _TTSWordArray.length) {
      print('***  _TTSWordArray.length  *** ' + _TTSWordArray.length.toString());

      // _setIsSelected_2(int._TTSWordArray[0], i);
      await _tts.speak(_TTSWordArray[i]);

      if (!listEquals(originalList, _TTSWordArray)) { // _TTSWordArray가 변경되었다면 처음부터 다시 실행

        firstKeyIndex = findFirstKeyByValue(_wordToSentenceIndexMap, _currentSentenceIndex);
        _setIsSelected_2(firstKeyIndex);
        print('***  !listEquals is called  *** ' + firstKeyIndex.toString());

        i = 1;
        originalList = List.from(_TTSWordArray); // 변경된 _TTSWordArray의 복사본 업데이트

      } else {
        if (i < _TTSWordArray.length - 1){
          _setIsSelected_2(firstKeyIndex+i);

        }
        i++;
      }
    }
  }

  // 모든 문장을 tts로 읽어주는 함수
  void _speakAllSentences() async {
    setState(() {
      _currentSentenceIndex = -1;
      _setIsSelected_2(-1);
    });
    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedindex]); // tts - 읽기 속도
    _StopSpeakTts();
    await _tts.awaitSpeakCompletion(true); // TTS로 읽는 게 끝날 때까지 기다리기

    int firstKeyIndex = 0;
    // int firstKeyIndex = findFirstKeyByValue(_wordToSentenceIndexMap, _currentSentenceIndex);
    _setIsSelected_2(firstKeyIndex);

    int i = 0;
    while (i < _textWordArray.length){
      _setIsSelected_2(i);
      await _tts.speak(_textWordArray[i]); // string을 tts로 읽기 시작
      i++;
    }
    // await _tts.speak(allSentenceString); // string을 tts로 읽기 시작
    print('***  _speakAllSentences : i  *** ' + i.toString());
  }

  // 실행되고 있는 tts를 중단하는 함수
  void _StopSpeakTts() async {
    await _tts.stop();
  }

  // 노란색 highlight 할 단어를 세팅하는 함수
  // void _setIsSelected() {
  //   isSelected = List.generate(_textWordArray.length, (_) => false); // isSelecte를 모두 false로 초기화
  //
  //   if (_currentSentenceIndex == -1){
  //     isSelected = List.filled(_textWordArray.length, false);
  //   } else {
  //     _wordToSentenceIndexMap.forEach((key, value) {
  //       if (value == _currentSentenceIndex) {
  //         isSelected[key] = true;
  //       }
  //     });
  //   }
  // }

  // 문장 번호로 단어 인덱스를 알아내는 함수
  int findFirstKeyByValue(Map<int, int> map, int value) {
    for (var entry in map.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }
    return -1;
  }

  // 노란색 highlight 할 단어를 세팅하는 함수
  void _setIsSelected_2(firstKeyIndex) {
    print('***  _setIsSelected_2 is called  *** ' + firstKeyIndex.toString());

    isSelected = List.generate(_textWordArray.length, (_) => false); // isSelecte를 모두 false로 초기화

    if (firstKeyIndex == -1){
      isSelected = List.generate(_textWordArray.length, (_) => false); // isSelecte를 모두 false로 초기화
    } else {
      isSelected[firstKeyIndex] = true;
      print('***  _setIsSelected_2 : firstKeyIndex  *** ' + firstKeyIndex.toString());
    }

    _streamController.add(isSelected);
  }






  Widget alternativeIconBuilder(BuildContext context, SizeProperties<int> local,
      GlobalToggleProperties<int> global) {
    IconData data = Icons.access_time_rounded;
    switch (local.value) {
      case 0: // TTS 속도 빠르게
        data = Icons.arrow_forward_ios;
        break;
      case 1: // TTS 속도 보통
        data = Icons.play_arrow_outlined;
        break;
      case 2: // TTS 속도 느리게
        data = Icons.arrow_back_ios;
        break;
    }
    return Icon(
      data,
      size: local.iconSize.shortestSide,
    );
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
        title: Text( "I HANGUL",
          style: TextStyle( color: Colors.black, ),),
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
                  labels: ['수정', '사전', '음성'],
                  customTextStyles: [
                    TextStyle(fontSize: width * 0.045),
                    TextStyle(fontSize: width * 0.045),
                    TextStyle(fontSize: width * 0.045),
                  ],
                  radiusStyle: true,
                  onToggle: (index) {
                    _StopSpeakTts();
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
            Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 4.0, // 단어 사이 간격
                    runSpacing: 4.0, // 문장 사이 간격

                    children: _textWordArray.asMap().entries.map((word) {
                      int index = word.key;
                      String wordValue = word.value;
                      int? sentenceIndex = _wordToSentenceIndexMap[index]; // 단어의 인덱스에 따라 문장의 인덱스를 가져와 저장

                      return StreamBuilder(
                        stream: _streamController.stream,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          List<bool> isSelected = snapshot.data ?? List.generate(_textWordArray.length, (_) => false);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // _StopSpeakTts();
                                _TTSWordArray.clear();
                                _currentSentenceIndex = sentenceIndex!;
                              });
                              _speakWord(index);
                            },
                            child: Container(
                              padding: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                color: isSelected[index] ? Colors.yellow : null,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                wordValue,
                                style: TextStyle(fontSize: width * 0.045),
                              ),
                            ),
                          );
                        },
                      );

                    }).toList(),
                  ),
                )
            ),
            // Expanded(
            //   child: Container(),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(),
                ),
                Container(
                  // margin: EdgeInsets.only(bottom: height * 0.04),
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _TTSWordArray.clear();
                        // _currentSentenceIndex = sentenceIndex!;
                      });
                      _speakAllSentences();
                    },
                    child: Icon(Icons.volume_up_outlined, color: Colors.black,),
                    backgroundColor: Color(0xFFC0EB75),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),

                // 정지 버튼 - 수정 필요
                // Container(
                //   // margin: EdgeInsets.only(bottom: height * 0.04),
                //   child: FloatingActionButton(
                //     onPressed: () {
                //       _TTSWordArray.clear();
                //       _StopSpeakTts();
                //       // _tts.stop();
                //     },
                //     child: Icon(Icons.stop, color: Colors.black,),
                //     backgroundColor: Color(0xFFC0EB75),
                //   ),
                // ),
                // Expanded(
                //   child: Container(),
                // ),

                AnimatedToggleSwitch<int>.size(
                  textDirection: TextDirection.rtl,
                  current: _toggleSwitchvalue,
                  values: const [0, 1, 2],
                  // iconOpacity: 0.2,
                  // indicatorSize: const Size.fromWidth(100),
                  customIconBuilder: (context, local, global) {
                    switch (_toggleSwitchvalue) {
                      case 0: // TTS 속도 느리게
                        _ttsSpeedindex = 2;
                        break;
                      case 1: // TTS 속도 보통
                        _ttsSpeedindex = 1;
                        break;
                      case 2: // TTS 속도 빠르게
                        _ttsSpeedindex = 0;
                        break;
                      default: // 기본 - TTS 속도 보통
                        _ttsSpeedindex = 1;
                        break;
                    }
                    print('***  _ttsSpeedindex  *** ' + _ttsSpeedindex.toString());

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        alternativeIconBuilder(context, local, global),
                      ],
                    );
                  },
                  borderColor: Color(0xFFC0EB75),
                  colorBuilder: (i) => i.isEven ? Color(0xFFC0EB75) : Color(0xFFC0EB75),
                  onChanged: (i) => setState(() =>
                  _toggleSwitchvalue = i,
                  ),
                ),

                Expanded(
                  child: Container(),
                ),
              ],
            ),

            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

}


// 단어 리스트의 인덱스에서 문장 리스트의 인덱스를 알아내는 클래스
// 단어를 클릭했을 때 그 단어가 위치한 문장을 알려줌
// 문장 단위의 TTS 재생을 위해 필요
class FindWordToSentenceIndex {
  final String _text; // 이전 화면에서 받아온 텍스트
  List<String> _textWordArray = []; // 단어를 저장하는 리스트
  List<String> _textSentenceArray = []; // 문장을 저장하는 리스트
  Map<int, int> _wordToSentenceIndexMap = {};
  // Map<int, int> get wordToSentenceIndexMap => _wordToSentenceIndexMap;

  FindWordToSentenceIndex(this._text, this._textWordArray, this._textSentenceArray){
    int sentenceIndex = 0;
    int wordIndex = 0;

    for (int i = 0; i < _textWordArray.length; i++) {
      _wordToSentenceIndexMap[i] = sentenceIndex;
      wordIndex += _textWordArray[i].length + 1; // 공백문자 포함 위해 +1
      if (wordIndex >= _textSentenceArray[sentenceIndex].length) {
        sentenceIndex++;
        wordIndex = 0;
      }
    }
    print('***  _wordToSentenceIndexMap  *** ' + _wordToSentenceIndexMap.toString());
  }

}