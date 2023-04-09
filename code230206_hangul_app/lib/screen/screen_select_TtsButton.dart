import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screen_select_dicButton.dart';
import 'screen_select_modifyButton.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

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

  int _currentSentenceIndex = -1; // 현재 문장의 인덱스 표시 (처음 아무것도 선택X -> -1)
  final FlutterTts _tts = FlutterTts(); // tts
  List _ttsSpeed = [0.2, 0.3, 0.5]; // tts 속도 저장 리스트. 느림 - 보통 - 빠름
  int _ttsSpeedindex = 1; // _ttsSpeed 리스트의 인덱스 저장

  List<bool> isSelected = [];// 노란색 highlight를 표시할 것인지 판단하는 bool 리스트


  // 초기화
  _SelectTtsButtonScreenState(this._text) {
    _textWordArray = _text.split(' '); // 단어 리스트 -> ' ' 공백문자 단위로 split
    _textSentenceArray = _text.split('. '); // 문장 리스트 -> '.' 온점 단위로 split

    _tts.setLanguage('kor'); // tts - 언어 한국어
    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedindex]); // tts - 읽기 속도. 기본 보통 속도
    FindWordToSentenceIndex findWordToSentenceIndex = FindWordToSentenceIndex(_text, _textWordArray, _textSentenceArray);
    _wordToSentenceIndexMap = findWordToSentenceIndex._wordToSentenceIndexMap;
    isSelected = List.generate(_textWordArray.length, (_) => false); // isSelecte를 모두 false로 초기화

  }


  // 단어를 tts로 읽어주는 함수 - 단어를 클릭했을 때 그 단어가 포함된 문장 전체 읽기 위해
  void _speakWord(int index) async {
    // String word = _textWordArray[index]; // 현재 읽을 단어 = 단어 리스트[매개변수 인덱스]

    // 단어로 문장 인덱스 알아내기
    int? sentenceIndex = _wordToSentenceIndexMap[index];

    if (sentenceIndex != -1) { // 문장 인덱스가 -1이 아니라면
      _speakSentence(sentenceIndex!); // tts 문장 읽어주는 함수 실행
    }
  }

  // 1개 문장을 tts로 읽어주는 함수
  void _speakSentence(int index) async {
    setState(() {
      _currentSentenceIndex = index; // index를 매개변수로 받아서 현재 인덱스에 저장
      _setIsSelected();

    });
    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedindex]); // tts - 읽기 속도
    _StopSpeakTts();
    // await _tts.stop(); // 실행되고 있는 tts 중단
    await _tts.speak(_textSentenceArray[_currentSentenceIndex]); // index위치의 문장 tts로 읽기 시작
  }

  // 모든 문장을 tts로 읽어주는 함수
  void _speakAllSentences() async {
    setState(() {
      _currentSentenceIndex = -1;
      _setIsSelected();
    });
    // _setIsSelected();
    // _currentSentenceIndex = -1;
    final allSentenceString = _textSentenceArray.join('. '); // 모든 텍스트를 string에 저장
    _tts.setSpeechRate(_ttsSpeed[_ttsSpeedindex]); // tts - 읽기 속도

    _StopSpeakTts();
    // await _tts.stop(); // 실행되고 있는 tts 중단
    await _tts.speak(allSentenceString); // string을 tts로 읽기 시작
    print('***  _wordToSentenceIndexMap  *** ' + _wordToSentenceIndexMap.toString());

  }

  // 실행되고 있는 tts를 중단하는 함수
  void _StopSpeakTts() async {
    await _tts.stop();
  }

  // 노란색 highlight 할 단어를 세팅하는 함수
  void _setIsSelected() {
    isSelected = List.generate(_textWordArray.length, (_) => false); // isSelecte를 모두 false로 초기화

    if (_currentSentenceIndex == -1){
      isSelected = List.filled(_textWordArray.length, false);
    } else {
      _wordToSentenceIndexMap.forEach((key, value) {
        if (value == _currentSentenceIndex) {
          isSelected[key] = true;
        }
      });
    }

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

                      // 선택한 단어가 포함된 문장 노란색으로 highlight 표시
                      // isSelected[index] = _currentSentenceIndex != -1 && sentenceIndex != null && sentenceIndex == _currentSentenceIndex;

                      return GestureDetector(
                        onTap: () {
                          _speakWord(index);
                          setState(() {
                            _currentSentenceIndex = sentenceIndex!;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: isSelected[index] ? Colors.yellow : null,
                            // color: isSelected[index] ? Colors.yellow : null,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(wordValue, style: TextStyle(fontSize: width * 0.045),),

                        ),
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
                      _speakAllSentences();
                    },
                    child: Icon(Icons.volume_up_outlined, color: Colors.black,),
                    backgroundColor: Color(0xFFC0EB75),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),

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
    // print('***  _wordToSentenceIndexMap  *** ' + _wordToSentenceIndexMap.toString());
  }

}
