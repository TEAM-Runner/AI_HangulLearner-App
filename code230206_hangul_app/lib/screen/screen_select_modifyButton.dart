import 'package:flutter/material.dart';
import 'screen_select_dicButton.dart';
import 'screen_select_TtsButton.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SelectModifyButtonScreen extends StatefulWidget {
  late String text;
  late int initialTTSIndex;  //현재 TTS 출력 중인 인덱스 전달(기록용)

  SelectModifyButtonScreen({required this.text, required this.initialTTSIndex});

  @override
  _SelectModifyButtonScreen createState() => _SelectModifyButtonScreen(text);
}

class _SelectModifyButtonScreen extends State<SelectModifyButtonScreen> {
  final String _text; // 이전 화면에서 받아온 텍스트
  TextEditingController _textEditingController = TextEditingController();
  String returnText = '';

  _SelectModifyButtonScreen(this._text) {
    _textEditingController.text = _text;
    returnText = _text;
  }
  @override
  Widget build(BuildContext context) {
    // 스크린 사이즈 정의
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    // TTS 위치 기록
    print("SelectTtsButtonScreen - currentTTSIndex: $currentTTSIndex");


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF3F3F3),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  initialLabelIndex: 0,
                  labels: ['수정', '사전', '음성'],
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
                              SelectModifyButtonScreen(
                                  text: returnText,
                                  initialTTSIndex: currentTTSIndex // 현재 TTS 출력 중인 인덱스 전달(기록용)
                                ),
                        ),
                      );
                    } else if (index == 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectDicButtonScreen(
                                  text: returnText,
                                  initialTTSIndex: currentTTSIndex // 현재 TTS 출력 중인 인덱스 전달(기록용)
                              ),                        ),
                      );
                    } else if (index == 2) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectTtsButtonScreen(
                                  text: returnText,
                                  initialTTSIndex: currentTTSIndex // 현재 TTS 출력 중인 인덱스 전달(기록용)
                              ),                        ),
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
            // SizedBox(height: 16.0),
            Expanded(child:
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(left: 6.0, right: 6.0, bottom: 6.0, top: 0.0),
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      // labelText: 'modify text',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: width * 0.045,
                      height: 2.0,
                      wordSpacing: 2.0,
                    ),
                    maxLines: null,
                    onChanged: (text) {
                      returnText = text;
                      print('***  returnText  *** ' + returnText);
                    },
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
