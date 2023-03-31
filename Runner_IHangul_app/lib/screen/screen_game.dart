import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(ConsonantGame());

class ConsonantGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '초성 게임',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int randomSend = 0;
  final _consonant = ['ㅅㄱ', 'ㅂㄴㄴ', 'ㄸㄱ', 'ㅍㄷ', 'ㅇㄹㅈ'];
  final _words = ['사과', '바나나', '딸기', '포도', '오렌지'];
  String _hint='hint 받기';
  final _hints = ['과일사과', '과일바나나', '과일딸기', '과일포도', '과일오렌지'];
  int timesController=0;
  final _controller = TextEditingController();
  String _currentWord = '';

  @override
  void initState() {
    super.initState();
    getCorrectAnswer();
  }

  void getCorrectAnswer() {
    setState(() {
      randomSend = new Random().nextInt(_consonant.length);
      _currentWord = _consonant[randomSend];
      _controller.clear();
    });
  }

  getWorongAnswer(){
    timesController++;
    if(timesController>=2){
      getCorrectAnswer();
    }
  }

  bool _checkAnswer(String input) {
    return isKorean(input) && _controller.text == _words[randomSend];
  }

  bool isKorean(String str) {
    final regex = RegExp('[\\uAC00-\\uD7AF]+');
    return regex.hasMatch(str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('초성 게임'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _currentWord,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 64),
          TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: '정답을 입력해주세요.'),
            onSubmitted: (input) {
              if (_checkAnswer(input)) {
                getCorrectAnswer();
              } else {
                getWorongAnswer();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('틀렸습니다'),
                    content: Text('다시 시도하세요'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _controller.clear();
                        },
                        child: Text('확인'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          SizedBox(height: 64),
          TextButton(
            onPressed: _setHint(),
            child: Text(
              _hint,
              textScaleFactor: 2,
            ),
          )
        ],
      ),
    );
  }

  _setHint() {
    _hint = _hints[randomSend];
  }
}
