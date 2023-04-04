import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuple/tuple.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'screen_game_result.dart';
final quizNumber = 10; // 전체 퀴즈수

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}


class _GameScreenState extends State<GameScreen> {

  // firestore 저장된 단어 가져오기
  late User user;
  late CollectionReference wordsRef;
  List<QueryDocumentSnapshot> starredWords = [];

  // gameWordList의 index 저장
  int index = 0;

  // 게임에 사용할 단어 리스트. bool은 모두 false로 초기화
  List<List<dynamic>> gameWordList = List.generate(quizNumber, (_) => ['', '', false]);

  // 게임에 사용할 기본 단어 리스트. Firestore에 저장된 단어가 10개 이하일 경우 사용
  List<List<dynamic>> gameBasicWordList = [
    ['사과', 'mean1', false],
    ['바나나', 'mean2', false],
    ['딸기', 'mean3', false],
    ['포도', 'mean4', false],
    ['오렌지', 'mean5', false],
    ['배', 'mean6', false],
    ['키위', 'mean7', false],
    ['블루베리', 'mean8', false],
    ['복숭아', 'mean9', false],
    ['오렌지', 'mean10', false],
  ];

  int randomSend = 0;
  String _buttonText = 'hint 받기';
  int timesController = 0;
  final _controller = TextEditingController();

  void _initializeUserRef() {
    user = FirebaseAuth.instance.currentUser!;
    wordsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('words');
  }

  // Firestore에 저장된 단어 starredWords 리스트에 저장
  void _getStarredWords() async {
    final QuerySnapshot querySnapshot = await wordsRef.get();
    setState(() {
      starredWords = querySnapshot.docs;
      _generateGameWordList();
    });
  }

  // gameWordList 세팅. 랜덤으로 10개 저장
  void _generateGameWordList() {
    final random = Random();

    // 저장된 단어가 10개보다 많은 경우 starredWords에서 랜덤으로 단어 가져옴
    // 저장된 단어가 10개보다 적은 경우 gameBasicWordList 사용
    for (int i = 0; i < quizNumber; i++) {
      if (i < starredWords.length) {
        int index = random.nextInt(starredWords.length);
        gameWordList[i] = [
          starredWords[index]['word'],
          starredWords[index]['meaning'],
          false,
        ];
      } else {
        gameWordList[i] = gameBasicWordList[i];
      }
    }
    print('***  gameWordList  *** ' + gameWordList.toString());
    setState(() {});
  }


  // 게임 결과 화면으로 넘어갈 때 계속 RangeError발생
  // RangeError (index): Invalid value: Not in inclusive range 0..9: 10
  void getCorrectAnswer() {
    setState(() {
      gameWordList[index][2] = true;
      _controller.clear();
      _buttonText = 'hint 받기';
      timesController = 0;
      index++;

      if (index >= quizNumber) {
        Navigator.pushReplacementNamed(
            context,
            GameResultScreen.GameResultScreenRouteName,
            arguments: GameResultScreen(GameResultScreenText: gameWordList)
        );
      }
    });
    print('***  getCorrectAnswer_gameWordList  *** ' + gameWordList.toString());
  }

  void getWrongAnswer() {
    if (timesController == 1) {
      setState(() {
        gameWordList[index][2] = false;
        _controller.clear();
        _buttonText = 'hint 받기';
        timesController = 0;
        index++;

        if (index >= quizNumber) {
          Navigator.pushReplacementNamed(
              context,
              GameResultScreen.GameResultScreenRouteName,
              arguments: GameResultScreen(GameResultScreenText: gameWordList)
          );

        }}
      );
    }
    timesController++;

  }

  // 힌트
  void setHint() {
    _buttonText = gameWordList[index][0];
  }

  // 답 체크
  bool _checkAnswer(String input) {
    // index++;
    bool answer =
        isKorean(input) && _controller.text == gameWordList[index][0];
    print('***  answer  *** ' + answer.toString());
    print('***  index  *** ' + index.toString());
    print('***  _controller.text  *** ' + _controller.text.toString());
    print('***  isKorean  *** ' + isKorean(input).toString());
    print('***   ==  *** ' + _controller.text ==
        gameWordList[index][0].toString());
    return answer;
  }

  bool isKorean(String str) {
    final regex = RegExp('[\\uAC00-\\uD7AF]+');
    return regex.hasMatch(str);
  }

  @override
  void initState() {
    super.initState();
    _initializeUserRef();
    _getStarredWords();
  }


  @override
  Widget build(BuildContext context) {
    // 스크린 사이즈 정의
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;

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
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white)),
          width: width * 0.85,
          height: height * 0.7,
          child: Swiper(physics: NeverScrollableScrollPhysics(),
          loop: false,
          itemCount: 11,
          itemBuilder: (BuildContext context, int index) {
            return index < quizNumber
                ? _buildQuizCard(gameWordList, width, height)
                : Container(); // empty container to return nothing
          },
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(List gameWordList, double width, double height) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFFF3F3F3)),
            color: Color(0xFFF3F3F3),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, width*0.024, 0, width*0.024),
            child: Text(
              'Q' + (index+1).toString() + '.',
              style: TextStyle(
                fontSize: width*0.06,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Text(gameWordList[index][0], style: TextStyle(fontSize: 48)),
          Text(gameWordList[index][1], style: TextStyle(fontSize: 20)),
          SizedBox(height: 30),
          TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: '정답을 입력해주세요.', hintStyle: TextStyle(fontSize: 24)),
              textAlign: TextAlign.center,

              onSubmitted: (input) {
                if (_checkAnswer(input)){
                  getCorrectAnswer();
                  showDialog( // true - 정답인 경우
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('정답'),
                        content: Image.asset('assets/images/right.png', width: 100, height: 100,),
                        actions: [TextButton(child: Text('OK'),
                            onPressed: () {
                          Navigator.of(context).pop();
                            })],));
                } else {
                  getWrongAnswer();
                  print('***  timesController  *** ' + timesController.toString());
                  print('***  _controller.text  *** ' + _controller.text);
                  print('***  gameWordList[index].item1  *** ' + gameWordList[index][0]);
                  print('***  index  *** ' + index.toString());

                  showDialog( // false - 오답인 경우
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('틀렸어요'),
                        content: Image.asset('assets/images/wrong.png', width: 100, height: 100,),
                        actions: [TextButton(child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })],));
                }
              }
          ),
          SizedBox(height: 30),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/key_color.png', height: 50, width: 50),
                SizedBox(width: 32),
                TextButton(
                  child: Text(_buttonText, style: TextStyle(fontSize: 32)),
                  onPressed: () => setState(setHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
