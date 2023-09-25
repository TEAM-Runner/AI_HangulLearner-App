import 'package:flutter/material.dart';
import 'screen_select_dicButton.dart';
import 'screen_select_TtsButton.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SelectModifyButtonScreen extends StatefulWidget {
  late String text;
  late int initialTTSIndex;  //현재 TTS 출력 중인 인덱스 전달(기록용)

  SelectModifyButtonScreen({required this.text, required this.initialTTSIndex});

  @override
  _SelectModifyButtonScreen createState() => _SelectModifyButtonScreen(text, initialTTSIndex);
}

class _SelectModifyButtonScreen extends State<SelectModifyButtonScreen> {
  final String _text; // 이전 화면에서 받아온 텍스트
  int currentTTSIndex; // 현재 TTS 출력 중인 인덱스 기록

  TextEditingController _textEditingController = TextEditingController();
  String returnText = '';
  FocusNode _focusNode = FocusNode(); // 키보드를 화면에 자동으로 보여주기 위해 FocusNode 정의

  _SelectModifyButtonScreen(this._text, this.currentTTSIndex) {
    print("_SelectModifyButtonScreen $_text}");
    _textEditingController.text = _text;
    returnText = _text;
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
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
        title:Image.asset("assets/images/i_hangul.png"),
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
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Color(0xFFC0EB75),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(
                          builder: (context) => SelectTtsButtonScreen(text: returnText, initialTTSIndex: currentTTSIndex,),
                        ),
                      );
                    },
                    icon: Icon(Icons.check, color: Colors.black),
                  ),
                )
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
                      fontSize: 20,
                      height: 2.0,
                      wordSpacing: 1.0,
                    ),
                    maxLines: null,
                    onChanged: (text) {
                      returnText = text;
                      print('***  returnText  *** ' + returnText);
                    },
                    focusNode: _focusNode, // FocusNode를 TextField에 붙이기
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
