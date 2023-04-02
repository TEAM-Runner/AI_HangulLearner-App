import 'package:flutter/material.dart';
import 'screen_select_dicButton.dart';
import 'screen_select_TtsButton.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SelectModifyButtonScreen extends StatefulWidget {
  late String text;

  SelectModifyButtonScreen({required this.text});

  @override
  _SelectModifyButtonScreen createState() => _SelectModifyButtonScreen(text);
}

class _SelectModifyButtonScreen extends State<SelectModifyButtonScreen> {
  late String _text;

  _SelectModifyButtonScreen(String text) {
    _text = text;
  }
  @override
  Widget build(BuildContext context) {

    // 스크린 사이즈 정의
    Size screenSize = MediaQuery
        .of(context)
        .size;
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
                  initialLabelIndex: 0,
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
          ],
        ),
      ),
    );
  }
}