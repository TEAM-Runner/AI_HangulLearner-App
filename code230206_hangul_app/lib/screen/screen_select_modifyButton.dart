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
    String replaceText = _text.replaceAll(".", ".\n").replaceAll("\n ", "\n");
    print("_SelectModifyButtonScreen $replaceText}");
    _textEditingController.text = replaceText;
    returnText = replaceText;
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
      backgroundColor: Color(0xffd9ebe5),
      appBar: AppBar(
        backgroundColor: Color(0xffd9ebe5),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // title:Image.asset("assets/images/i_hangul.png"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Tooltip(
              richMessage: WidgetSpan(
                  child: Column(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: const Text("글자 고치기",
                          style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: const Text("책과 조금 다른 부분이 있다면 글자를 고칠 수 있어요. 글자를 모두 고친 다음 체크 버튼을 눌러 주세요.",
                            style: TextStyle(color: Colors.black, fontSize: 14)),
                      )
                    ],
                  )
              ),
              triggerMode: TooltipTriggerMode.tap,
              showDuration: Duration(seconds: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(
                  color: Color(0xFF74b29e), // Border color
                  width: 1.0, // Border width
                ),
              ),
              child: Icon(Icons.help_outline, color: Colors.black,),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: 40.0,
                    height: 40.0
                ),
                const Expanded(
                  child: Center(
                    child: Text("글자를 고칠 수 있어요",
                        style: TextStyle(
                            color: Color(0xFF74b29e),
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        )
                    ), // Center the text
                  ),
                ),
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Color(0xFF74b29e),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(
                          builder: (context) => SelectTtsButtonScreen(text: returnText, initialTTSIndex: currentTTSIndex,),
                        ),
                      );
                    },
                    icon: Icon(Icons.check, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(child:
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 2),
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        height: 2.0,
                        // wordSpacing: 1.0,
                      ),
                      maxLines: null,
                      onChanged: (text) {
                        returnText = text;
                        print('***  returnText  *** ' + returnText);
                      },
                      focusNode: _focusNode, // FocusNode를 TextField에 붙이기
                    ),
                  ),
                ),
              )
            ),
            SizedBox(height: 16.0),

          ],
        ),
      ),
    );
  }
}
