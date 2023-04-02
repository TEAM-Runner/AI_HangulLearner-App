// *** 카메라 결과 스크린 ***
// 사진에서 인식한 글자와 사전 버튼, 음성 버튼을 보여주는 스크린
// 사전 버튼 -> screen_dic.dart로 연결됨
// 음성 버튼 -> screen_tts.dart로 연결됨

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screen_dic.dart';
import 'screen_tts.dart';

class ResultScreen extends StatefulWidget  {
  final String text;
  const ResultScreen({Key? key, required this.text}) : super(key: key);

  @override
  _ResultScreenState  createState() => _ResultScreenState ();
}

class _ResultScreenState  extends State<ResultScreen> {
  late TextEditingController _textFieldController;
  late String _text;

  @override
  void initState() {
    super.initState();
    // _textFieldController.text = widget.text;
    _textFieldController = TextEditingController(text: "${widget.text}");
  }


  @override
  Widget build(BuildContext context) {

    // 스크린 사이즈 정의
    Size screenSize = MediaQuery
        .of(context)
        .size;
    double width = screenSize.width;
    double height = screenSize.height;

    // TextEditingController _textFieldController = TextEditingController();


    //임시 전달 텍스트
    // final String testtext = '저 멀리 깊고 푸른 바다 속에, 물고기 한 마리가 살고 있었습니다. 그 물고기는 보통 물고기가 아니라 온 바다에서 가장 아름다운 물고기였습니다. 파랑, 초록, 자줏빛 바늘 사이사이에 반짝반짝 빛나는 은빛 비늘이 박혀 있었거든요. 다른 물고기들도 그 물고기의 아름다운 모습에 감탄했습니다. 물고기들은 그 물고기를 무지개 물고기라고 불렀습니다. 물고기들은 무지개 물고기에게 말을 붙였습니다.';
    // _textFieldController = TextEditingController(text: _text);

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            toolbarHeight: width*0.15,
            title: Text("I HANGUL"),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                  gradient: LinearGradient(
                      colors: [Colors.deepPurpleAccent,Colors.deepPurple],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter
                  )
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(right: width*0.04, left: width*0.04), //const EdgeInsets.all(width*0.1),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(width * 0.048),
                  ),
                  SizedBox(
                    height: 400, // set the height of the field
                    child: TextFormField(
                      controller: _textFieldController,
                      // initialValue: widget.text,
                      decoration: InputDecoration(
                        labelText: '글자 인식 결과',
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(fontSize: width * 0.045),
                      maxLines: null, // allow the field to expand vertically
                      onChanged: (text) {
                        // handle the text change here
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(width * 0.048),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: width * 0.036),
                    child: Center(
                      child: ButtonTheme(
                        minWidth: width * 0.8,
                        height: height * 0.05,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                            child: Text('사전'),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context,
                                  DicScreen.DicScreenRouteName,
                                  arguments: DicScreen(DicScreenText: _textFieldController.text.trim()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            )
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(width * 0.048),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: width * 0.036),
                    child: Center(
                      child: ButtonTheme(
                        minWidth: width * 0.8,
                        height: height * 0.05,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                            child: Text('음성'),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context,
                                  TTSScreen.TTSScreenRouteName,
                                  arguments: TTSScreen(TTSScreenText: _textFieldController.text.trim()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            )
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


        )
    );
  }
}
