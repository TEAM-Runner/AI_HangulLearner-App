import 'package:code230206_hangul_app/configuration/my_style.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_swiper/card_swiper.dart';
import 'screen_game_result.dart';

final quizNumber = 5; // 전체 퀴즈수

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

  // 게임이 끝나는 시점을 알리는 변수
  bool endGameReady = false;

  // 게임에 사용할 단어 리스트. bool은 모두 false로 초기화
  List<List<dynamic>> gameWordList =
  List.generate(quizNumber, (_) => ['', '', false]);

  // 게임에 사용할 기본 단어 리스트. Firestore에 저장된 단어가 10개 이하일 경우 사용
  List<List<dynamic>> gameBasicWordList = [
    ['필통', '연필이나 볼펜, 지우개 따위의 필기도구를 넣어 가지고 다니는 작은 통', false],
    ['연필', '흑연과 점토를 재료로 심을 나무판 속에 넣어 만든 필기도구', false],
    ['지우개', '글씨나 그림 따위를 지우는 데 쓰는 물건', false],
    ['분필', '칠판에 글씨를 쓰는 데 사용하는 필기구', false],
    ['책상', '주로 글을 읽거나 쓸 때에 이용하기 위한 상', false],
    ['색연필', '빛깔이 있는 심을 넣어 만든 연필', false],
    ['쓰레기통', '쓰레기를 담거나 모아 두는 통', false],
    ['우산', '비가 올 때 머리에 받쳐 비를 가리는 물건', false],
    ['공책', '무엇을 쓰거나 그릴 수 있도록 매어 놓은 백지 묶음', false],
    ['책꽂이', '책을 세워서 꽂아 두는 물건이나 장치', false],
  ];

  int randomSend = 0;
  String _buttonText = 'hint 받기';
  int timesController = 0;
  final _controller = TextEditingController();
  String _quizWord = '';
  Color isHintClicked = Colors.white;

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

  void _generateGameWordList() {
    final random = Random();
    final uniqueWordIndices = <int>{}; // 단어가 중복으로 저장되지 않도록 하는 set

    // 저장된 단어가 10개보다 많은 경우 starredWords에서 랜덤으로 단어 가져옴
    // 저장된 단어가 10개보다 적은 경우 gameBasicWordList 사용
    for (int i = 0; i < quizNumber; i++) {
      if (i < starredWords.length) {
        int index;
        do {
          index = random.nextInt(starredWords.length);
        } while (uniqueWordIndices.contains(index));
        uniqueWordIndices.add(index);
        gameWordList[i] = [
          starredWords[index]['word'],
          starredWords[index]['meaning'],
          false,
        ];
      } else {
        gameWordList[i] = gameBasicWordList[i];
      }
    }
    print(gameWordList);
    _getQuizWord();
  }

  void _getCorrectAnswer() {
    setState(() {
      gameWordList[index][2] = true;
      _controller.clear();
      _buttonText = 'hint 받기';
      timesController = 0;
      isHintClicked = Colors.white;

      if (index < quizNumber - 1) {
        index++;
        _getQuizWord();
      } else {
        endGameReady = true;
      }

      if (endGameReady) {
        Navigator.pushReplacementNamed(
            context, GameResultScreen.GameResultScreenRouteName,
            arguments: GameResultScreen(GameResultScreenText: gameWordList));
      }
    });
  }

  void _getWrongAnswer() {
    if (timesController == 1) {
      setState(() {
        gameWordList[index][2] = false;
        _controller.clear();
        // _buttonText = 'hint 받기';
        timesController = 0;
        isHintClicked = Colors.white;

        if (index < quizNumber - 1) {
          index++;
          _getQuizWord();
        } else {
          endGameReady = true;
        }

        if (endGameReady) {
          Navigator.pushReplacementNamed(
              context, GameResultScreen.GameResultScreenRouteName,
              arguments: GameResultScreen(GameResultScreenText: gameWordList));
        }
      });
    } else {
      timesController++;
    }
  }

  // 답 체크
  bool _checkAnswer(String input) {
    bool answer =
        _isKorean(input) && _controller.text == gameWordList[index][0];
    return answer;
  }

  bool _isKorean(String str) {
    final regex = RegExp('[\\uAC00-\\uD7AF]+');
    return regex.hasMatch(str);
  }

  // 초성 추출 함수
  String? _getFirstConsonant(String str) {
    final Map<int, String> initialConsonants = {
      4352: 'ㄱ',
      4353: 'ㄲ',
      4354: 'ㄴ',
      4355: 'ㄷ',
      4356: 'ㄸ',
      4357: 'ㄹ',
      4358: 'ㅁ',
      4359: 'ㅂ',
      4360: 'ㅃ',
      4361: 'ㅅ',
      4362: 'ㅆ',
      4363: 'ㅇ',
      4364: 'ㅈ',
      4365: 'ㅉ',
      4366: 'ㅊ',
      4367: 'ㅋ',
      4368: 'ㅌ',
      4369: 'ㅍ',
      4370: 'ㅎ'
    };

    if (str == null) {
      throw Exception('한글이 아닙니다');
    } else {
      List<int> runes = str.runes.toList();
      String result = '';

      for (int i = 0; i < runes.length; i++) {
        int unicode = runes[i];
        if (unicode < 44032 || unicode > 55203) {
          throw Exception('한글이 아닙니다');
        }
        int index = (unicode - 44032) ~/ 588;
        result += initialConsonants[4352 + index]!;
      }
      return result;
    }
  }

  // 힌트

  void _getQuizWord() {
    _quizWord = _getFirstConsonant(gameWordList[index][0]) ?? '';
    print('***  setQuizWord_quizWord  *** ' + _quizWord);
  }

  void _getHint() {
    _quizWord = _quizWord.replaceFirst(_quizWord[0], gameWordList[index][0][0]);
    print('***  _quizWord  *** ' + _quizWord.toString());
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
        backgroundColor: Color(0xffd9ebe5),
        appBar: AppBar(
          backgroundColor: Color(0xFFD9EBE5),
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Tooltip(
                richMessage: WidgetSpan(
                    child: Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: const Text(
                            "초성 게임",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: const Text(
                              "초성 게임을 통해 단어를 공부할 수 있어요. 힌트를 얻고 싶다면 열쇠 버튼을 눌러 보세요.",
                              style: TextStyle(color: Colors.black, fontSize: 14)),
                        )
                      ],
                    )),
                triggerMode: TooltipTriggerMode.tap,
                showDuration: Duration(seconds: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    color: Color(0xFF74B29E), // Border color
                    width: 1.0, // Border width
                  ),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: Colors.black,
                ),
              ),
              onPressed: () {},
            ),
          ],
          // title:Image.asset("assets/images/i_hangul.png"),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),),
              width: width * 0.85,
              height: height * 0.55,

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
        )
    );
  }

  Widget _buildQuizCard(List gameWordList, double width, double height) {
    return Container(
        height: height * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Color(0xFF74B29E), width: 3),
          color: Color(0xFF74B29E),
        ),
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0, top: 10.0), // all 16
                    child: Column(
                      children: <Widget>[
                        Text('퀴즈 ' + (index + 1).toString(), //퀴즈 번호
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: _quizWord.runes.map((int codeUnit) {
                            final character = String.fromCharCode(codeUnit);
                            return Container(
                              alignment: Alignment.center,
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              // padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                character,
                                style: const TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.bold,
                                  // color: Color(0xFF74B29E)
                                ),
                              ),
                            );
                          }).toList(),
                        ), // 퀴즈 초성
                        SizedBox(height: 20),
                        Text(
                          gameWordList[index][1],
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ), // 퀴즈 단어의 뜻
                        SizedBox(height: 40),
                        SizedBox(
                          width: width * 0.5,
                          child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                //hintText: _controller.text.isEmpty ? '정답을 입력해 주세요' : '',
                                //hintStyle: TextStyle(fontSize: 20),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(fontSize: 25),
                              textAlign: TextAlign.center,
                              cursorColor: Colors.black,
                              onSubmitted: (input) {
                                if (_checkAnswer(input)){ // true - 정답인 경우
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const Dialog(
                                        backgroundColor: Colors.transparent, // Transparent background
                                        elevation: 0, // No shadow
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.circle_outlined,
                                              size: 200,
                                              color: Colors.blue,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                  Future.delayed(Duration(milliseconds: 1000), () {
                                    Navigator.of(context).pop();
                                    _getCorrectAnswer();
                                  });
                                } else { // false - 오답인 경우
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const Dialog(
                                        backgroundColor: Colors.transparent, // Transparent background
                                        elevation: 0, // No shadow
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.close,
                                              size: 200,
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                  Future.delayed(Duration(milliseconds: 1500), () {
                                    Navigator.of(context).pop();
                                    _getWrongAnswer();
                                  });
                                }
                              }
                          ),
                        ),
                        SizedBox(height: 20),
                        InkWell(
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(
                                isHintClicked == Colors.white ? [
                                  1, 0, 0, 0, 0,
                                  0, 1, 0, 0, 0,
                                  0, 0, 1, 0, 0,
                                  0, 0, 0, 1, 0,
                                ] : [ // 필터 없는 경우
                                  0.2126,0.7152,0.0722,0,0,
                                  0.2126,0.7152,0.0722,0,0,
                                  0.2126,0.7152,0.0722,0,0,
                                  0,0,0,1,0,
                                ] // 회색 필터
                            ),
                            child: Image.asset(
                              'assets/images/key_color.png',
                              height: 50,
                              width: 50,
                            ),
                          ),
                          onTap: () {
                            // 힌트 1번만 클릭 가능
                            if (isHintClicked != Colors.white) {
                              return;
                            }
                            isHintClicked = Colors.grey;
                            setState(() {});
                            _getHint();
                          },
                        ),
                      ],
                    )
                ),
              ]),
        )
    );
  }
}